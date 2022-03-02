function experiment_para_tune()
% EXPERIMENT_PARA_TUNE         
%     Experiment to show how to make parameter tuning for SynB-RVM.
% 
%     The tuning is based on point PF in validation sets being split from
%     the training set. The best parameter setting is chosen from a batch
%     of parameters to be the one that can produce the best MAE on the
%     validation set -- other PF metric can  also be referred according to
%     the practitioners' preference. MAE is chosen as the baseline PF for
%     being unbiased towards over/under-estimation.  
% 
%     % 'width' is a hyper-para of RBF kernel in RVM. It had shown to play
%     an important role on predictive PF of RVM related approaches (of
%     course include the proposed SynB-RVM).  
%     It can be tuned beforehand proceeding SynB-RVM. In other words, one
%     can tune 'width' as if one is using RVM itself for SEE.  
%     In this showcase experiment, we set |width = 4.3| based on our
%     previous study as the reference [1].
%  
%     In this experiment, we spare 10% of the training set as a validation
%     set, and run SynB-RVM to get the point PF on this set. This process
%     is conducted 10 times, attaining 10 PF evaluations of the
%     corresponding to the candidate parameter setting. The average point
%     PF is then used as the indicator for selecting the best parameter
%     setting. 
% 
%     Among the three types of SynB-RVM, SynB-RVM_ht2d is chosen for this
%     parameter tuning process. Readers can use another version of SynB-RVM,
%     and we expect that not to have significant impact. 
% 
% 
% RESULT EXAMPLE
%     ========================================
%     The best parameter setting based on this experiment is as below: 
%          the best number of Bootstrap bags is 30
%          the best degree of synthetic displacement is 0.01
%          the best pruning rate is 0.1
% 
%     ========================================
%     Predictive PF of "Nasa93" with SynB_RVM_ht2d.
%     ----------------------------------------
%     Overall predictive PF is as below:
%          mae = 64.1 
%          hit_rate = 1.00 
%          relative width = 1.88 
%     ----------------------------------------
%     Prediction intervals of CL=0.85 of all test projects are as:
%        id    actual  predicted   prediction interval      hit/not 
%         1    210.00     244.00    101.49 -    386.51 		 1 
%         2     48.00     166.67     17.57 -    315.76 		 1 
%         3     50.00      56.11      0.00 -    182.74 		 1 
%         4     60.00      67.78      0.00 -    194.40 		 1 
%         5     42.00     137.50      0.00 -    275.46 		 1 
%         6     60.00     146.15      7.74 -    284.57 		 1 
%         7    444.00     492.59    360.64 -    624.55 		 1 
%         8     42.00     140.00      0.37 -    279.63 		 1 
%         9    114.00     196.30     53.68 -    338.92 		 1 
% 
% REFERENCE
%     [1] L. Song, L. L. Minku, and X. Yao. 2014. The potential benefit of
%     relevance vector machine to software effort estimation. International
%     Conference on Predictor Models in Software Engineering (PROMISE��14).
%     52�C61. 

% Copyright 2021-6: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 
 
clear, clc

% get the train-test dataset for nasa93
[X_train, y_train, X_test, y_test] = get_nasa93();
n_train = length(y_train);

% experimental settings
p_vald = 0.1;       % percentage of the validation set in the training set
n_times = 10;       % how many times
width_use = 4.3;    % follow the parameter chosen in reference [1]

% candidate values of each parameter
m_bags_arr  = [10, 20, 30];         % #(Bootstrap Bags), default 10
tho_arr     = [0.01, 0.05, 0.1];    % syn displace; tho=0: without Syn, default 0.01
pru_m_arr   = [0.1, 0.2, 0.4];      % prune rate, default 0.1

% get para-pairs. NOTE (m_bags, tho, pru_m) in order
para_pairs = [myDecareProduct(m_bags_arr, tho_arr(1), pru_m_arr(1)); ...
    myDecareProduct(m_bags_arr(1), tho_arr, pru_m_arr(1)); ...
    myDecareProduct(m_bags_arr(1), tho_arr(1), pru_m_arr)];
% >>> output # = 9. To save computational time, we fix the default
% parameter values while changing across one parameter


% % % % % % % % % % % % % % % % % % % % % % % % % %
% predict the validation set with all para pairs
% % % % % % % % % % % % % % % % % % % % % % % % % %

% compute the point PF on validation sets of all parameter settings
mae_para = nan * ones(length(para_pairs), n_times);  % init
for time = 1:n_times
    
    % split the training set further into the training and validation sets
    [train_bool, validate_bool] = myCrossvalind('HoldOut', time, n_train, p_vald);
    
    X_train_val = X_train(train_bool, :);
    y_train_val = y_train(train_bool);
    X_val = X_train(validate_bool, :);
    y_val = y_train(validate_bool);
    
    % each para setting
    for pp = 1:length(para_pairs)
        para = para_pairs(pp, :);
        [m_bags, tho, pru_m] = deal(para(1), para(2), para(3));  % NOTE the order

        % train-validation
        y_val_pre = run_SynB_RVM_para(...
            m_bags, tho, pru_m, X_train_val, y_train_val, X_val, width_use);
        
        % mae in the validation set
        [~, mae_] = eval_point_pf(y_val, y_val_pre);
        
        % assign
        mae_para(pp, time) = mae_;
        
    end%para
end%times

% choose the best parameter setting of (m_bags, tho, pru_m)
mae_para_ave = mean(mae_para, 2);  % mae_para_std = std(mae_para')';  %#ok<UDIM>  % for checking
[~, id_min] = min(mae_para_ave);
para_best = para_pairs(id_min, :);
% NOTE (m_bags, tho, pru_m) in order
[m_bags_best, tho_best, pru_m_best] = deal(para_best(1), para_best(2), para_best(3));


% % % % % Result showcase %%%%
fprintf(['\n', repmat('=', 1, 40), '\n']);
fprintf('The best hyperparameter setting based on this experiment is as below: \n');
fprintf('\t the best number of Bootstrap bags is %d\n', m_bags_best);
fprintf('\t the best degree of synthetic displacement is %0.2f\n', tho_best);
fprintf('\t the best pruning rate is %0.1f\n\n', pru_m_best);


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %  
% Final prediction on the test set
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

% confidence level
cl = 0.85;

% the training & prediction algorithms
[y_pre_mean_spMn, PI_spMn, y_pre_mean_ht1d, PI_ht1d, y_pre_mean_ht2d, PI_ht2d] ...
    = SynB_RVM(cl, m_bags_best, tho_best, pru_m_best, X_train, y_train, X_test, width_use);

% point PF evaluation, show MAE as an exmample
[PF_spMn, mae_spMn] = eval_point_pf(y_test, y_pre_mean_spMn);
[PF_ht1d, mae_ht1d] = eval_point_pf(y_test, y_pre_mean_ht1d);
[PF_ht2d, mae_ht2d] = eval_point_pf(y_test, y_pre_mean_ht2d);

% uncertain PF evaluation
[hit_rate_spMn, relative_width_spMn] = eval_PI_pf(PI_spMn, y_pre_mean_spMn, y_test);
[hit_rate_ht1d, relative_width_ht1d] = eval_PI_pf(PI_ht1d, y_pre_mean_ht1d, y_test);
[hit_rate_ht2d, relative_width_ht2d] = eval_PI_pf(PI_ht2d, y_pre_mean_ht2d, y_test);


% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Result showcase
% % % % % % % % % % % % % % % % % % % % % % % % % % %

% choose one form of SynB-RVM
our_type_char = lower('ht2D');  % % spMn, ht1d, ht2d
% 
fprintf(['\n', repmat('=', 1, 40), '\n']);
fprintf('Predictive PF of "%s" with SynB_RVM_%s.\n', 'Nasa93', our_type_char);

% set up the reported result
eval(['mae_our = mae_', our_type_char, ';']);           % mae_our
eval(['y_pre_mean = y_pre_mean_', our_type_char, ';'])  % y_pre_mean
eval(['hit_rate = hit_rate_', our_type_char, ';'])      % hit_rate
eval(['PIs = PI_', our_type_char, ';'])                 % PIs
eval(['relative_width = relative_width_', our_type_char, ';'])  % relative_width

% overall PF
fprintf([repmat('-', 1, 40), '\n']);
fprintf('Overall predictive PF is as below:\n');
fprintf('\t mae = %0.1f \n\t hit_rate = %0.2f \n\t relative width = %0.2f \n', mae_our, hit_rate, relative_width);

% PIs of test examples
fprintf([repmat('-', 1, 40), '\n']);
fprintf('Prediction intervals of CL=%0.2f of all test projects are as:\n', cl)
hit_bool = PIs(:,1) < y_test & y_test < PIs(:,2);
fprintf('%5s%10s %10s %21s %12s \n', 'id', 'actual', 'predicted', 'prediction interval', 'hit/not');
report_data = [(1:length(y_test))', y_test, y_pre_mean, PIs, hit_bool];
fprintf('%5d%10.2f %10.2f %9.2f -%10.2f \t\t %1d \n', report_data');


% end%
