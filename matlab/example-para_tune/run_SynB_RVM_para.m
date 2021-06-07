function y_pre_mean_ht2d = run_SynB_RVM_para(...
    m_bags, tho, pru_m, X_train_val, y_train_val, X_val, width_use)
% RUN_SYNB_RVM_PARA
%       Run SynB-RVM for parameter tuning that is particularly applied
%       in "experiment_para_tune.m"
% 
% INPUT ARGUMENTS
%   m_bags, tho, pru_m          hyper-parameters of SynB-RVM
%   X_train_val, y_train_val    training projects
%   X_val                       validation projects
%   
%   width_use                   the parameter of RBF kernel in RVM
% 
% OUTPUT ARGUMENTS
%   pre_mean_ht2d               mean prediction of SynB-RVM_ht2d
% 

% Copyright 2021-6: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

% a column vector with the training error of each RVM
mae_train = zeros(m_bags, 1);

% a matrix of size (n_test, m_bags)
[y_tst_pre_mean, y_tst_pre_std] = deal(zeros(size(X_val, 1), m_bags));

% prediction of (mean, std)
n_test = size(X_val, 1);
[y_pre_mean_spMn, y_pre_std_spMn, y_pre_mean_ht1d, y_pre_std_ht1d, ...
    y_pre_mean_ht2d, y_pre_std_ht2d] = deal(zeros(n_test, 1));


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% The training algorithm

% random control
seed = 100;  % rng shuffle; seed = randi(100,1);

% Bootstrap re-sampling
n_train = length(y_train_val);
rng(seed);  % random control
[~, id_BootSampling] = bootstrp(m_bags, [], 1:n_train);

% for each Bootstrap bag 
for m = 1 : m_bags 
    
    % Bootstrap training bag construction
    id_m_train_bag = sort(id_BootSampling(:, m), 'ascend');
    
    % synthetic project displacement
    [m_X_train, m_y_train] = ...
        synthetic_project_displace(id_m_train_bag, X_train_val, y_train_val, tho);

    % RVM train
    kernel	= 'gauss';
    [Weights, Used, bias, beta, Sigma] = trainRVM(m_X_train, m_y_train, kernel, width_use); %core
    
    % calculate the training error for this Bootstrap training bag
    m_y_pre = predRVM(m_X_train, m_X_train, kernel, width_use, Weights, Used, bias, beta, Sigma);
    
    % calculate the training error for this Bootstrap training bag
    [~, m_mae] = eval_point_pf(m_y_pre,m_y_train);
    
    mae_train(m) = m_mae;  % assign
    
    
    % % % % % % % % % % % % % % % % % % % % % % % % % % % %
    %  For prediction algorithm of SynB-RVM
    
    % multiple uncertain prediction using the m^th trained RVM
    [m_y_tst_mean, m_y_tst_std] = predRVM(m_X_train,...
        X_val, kernel, width_use, Weights, Used, bias, beta, Sigma);
    
    % assign
    y_tst_pre_mean(:, m) = m_y_tst_mean;
    y_tst_pre_std(:, m) = m_y_tst_std;  
    % if result is not a real value, apply "real(y_tst_pre_std)"
    
end



% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Prediction algorithm of SynB-RVM

% model pruning -- bad training PF acc pru_m
[~, rank_rvms] = sort(mae_train, 'ascend');
id_retain_bags = rank_rvms(1 : round(m_bags*(1-pru_m)));

% each test project
for nn = 1:n_test
   
    % model pruning -- bad training PF: extract uncertain
    % estimates for this test project
    yn_pre_mean = y_tst_pre_mean(nn, id_retain_bags)';  % overwrite
    yn_pre_std = y_tst_pre_std(nn, id_retain_bags)';  % overwrite

    % Bootstrap estimate pruning -- negative estimated mean
    id_retain_ = yn_pre_mean > 0;
    yn_pre_mean = yn_pre_mean(id_retain_);  % overwrite
    yn_pre_std = yn_pre_std(id_retain_);    % overwrite
    
    
    % % % % integrating the remaining estimates -- three ways
    m_bag_retain = length(yn_pre_mean);
    
    % 1) empirical mean
    y_pre_mean_spMn(nn) = mean(yn_pre_mean);
    y_pre_std_spMn(nn) = mean(yn_pre_std);

    % 2) uni-variate empirical PDFs
    [YBinVal,YBinEdge] = histcounts(yn_pre_mean);
    HistStepYn = (YBinEdge(2)-YBinEdge(1))/2;
    [SigBinVal,SigBinEdge] = histcounts(yn_pre_std);
    HistStepSIGn = (SigBinEdge(2)-SigBinEdge(1))/2;
    
    % emperical {Yn,P(Yn)}
    Yn_hst = YBinEdge(1:end-1)+HistStepYn; %[vip]
    PYn_hst = YBinVal./m_bag_retain; %[vip]
    
    % emperical {Sig,P(Sig)}
    Sig_hst = SigBinEdge(1:end-1)+HistStepSIGn;
    PSig_hst = SigBinVal./m_bag_retain;
    % final prediction
    y_pre_mean_ht1d(nn) = sum(Yn_hst.*PYn_hst);
    y_pre_std_ht1d(nn) = sum(Sig_hst.*PSig_hst);

    % 3) bi-variate empirical PDFs
    [YSigBinVals,YBinEdge,SigBinEdge] = histcounts2(yn_pre_mean,yn_pre_std);
    YBinWidth = (YBinEdge(2)-YBinEdge(1))/2;
    SigBinWidth = (SigBinEdge(2)-SigBinEdge(1))/2;
    
    % empirical (Yn,SigN)
    for b1=1:size(YSigBinVals,1)
        for b2=1:size(YSigBinVals,2)
            YSig_val{b1,b2}=[YBinEdge(b1)+YBinWidth,...
                SigBinEdge(b2)+SigBinWidth];
        end
    end
    
    % empirical P(Yn,SigN)
    YSig_pdf = YSigBinVals./m_bag_retain;
    
    % final prediction
    Exp_nYSig=[0,0];
    for b1=1:size(YSigBinVals,1)
        for b2=1:size(YSigBinVals,2)
            Exp_nYSig = Exp_nYSig + YSig_val{b1,b2}.*YSig_pdf(b1,b2);
        end
    end
    y_pre_mean_ht2d(nn) = Exp_nYSig(1);
    y_pre_std_ht2d(nn) = Exp_nYSig(2);
    
end


end%
