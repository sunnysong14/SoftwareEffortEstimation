% Experience_1
%   Integration of data preparation, training and prediction algorithms,
%   and the evalution for SynB-RVM. Readers can refer to this script to get
%   an overall impression of how to run this tool. 
% 
% NOTE
%   Evaluation of the derived prediction intervals in terms of hit rate and
%   relative width may not be adequately precise to reflect the true
%   performance because the number of test examples is not large enough.
%   Performance evaluation presented here is used to show how to run these
%   functions of this tool.
% 
% RESULT EXAMPLE
%     ========================================
%     Predictive PF of "Nasa93" with SynB_RVM_ht2d.
%     ----------------------------------------
%     Overall predictive PF is as below:
%          mae = 58.6 
%          hit_rate = 1.00 
%          relative width = 1.72 
%     ----------------------------------------
%     Prediction intervals of CL=0.85 of all test projects are as:
%        id    actual  predicted   prediction interval      hit/not 
%         1    210.00     233.33    109.37 -    357.29 		 1 
%         2     48.00     133.33      1.38 -    265.29 		 1 
%         3     50.00      55.00      0.00 -    162.96 		 1 
%         4     60.00      65.00      0.00 -    172.96 		 1 
%         5     42.00     122.22      6.26 -    238.18 		 1 
%         6     60.00     144.44     28.48 -    260.41 		 1 
%         7    444.00     516.67    408.70 -    624.63 		 1 
%         8     42.00     144.44     28.48 -    260.41 		 1 
%         9    114.00     183.33     67.37 -    299.30 		 1 
% 

% Copyright 2021-6: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 
 
clear, 
clc

% % % % get the train-test dataset for nasa93
[X_train, y_train, X_test, y_test] = get_nasa93();


% % % % the training and prediction algorithms of SynB-RVM

% SynB-RVM's hyper-parameters
width_use = 4.3;    % width of the RBF kernel in RVM
m_bags = 10;        % #(Bootstrap Bags)
tho = 0.01;         % syn displace; tho=0: without Syn
pru_m = 0.1;        % prune rate


% confidence level
cl = 0.85;

% the training and prediction algorithms
[y_pre_mean_spMn, PI_spMn, y_pre_mean_ht1d, PI_ht1d, y_pre_mean_ht2d, PI_ht2d] ...
    = SynB_RVM(cl, m_bags, tho, pru_m, X_train, y_train, X_test, width_use);


% % % % point PF evaluation, show MAE as an exmample
[PF_spMn, mae_spMn] = eval_point_pf(y_test, y_pre_mean_spMn);
[PF_ht1d, mae_ht1d] = eval_point_pf(y_test, y_pre_mean_ht1d);
[PF_ht2d, mae_ht2d] = eval_point_pf(y_test, y_pre_mean_ht2d);

% % uncertain PF evaluation
[hit_rate_spMn, relative_width_spMn] = eval_PI_pf(PI_spMn, y_pre_mean_spMn, y_test);
[hit_rate_ht1d, relative_width_ht1d] = eval_PI_pf(PI_ht1d, y_pre_mean_ht1d, y_test);
[hit_rate_ht2d, relative_width_ht2d] = eval_PI_pf(PI_ht2d, y_pre_mean_ht2d, y_test);


% % % % Result showcase

% choose one form of SynB-RVM
our_type_char = lower('ht2D');  % % spMn, ht1d, ht2d
% 
fprintf(['\n', repmat('=', 1, 40), '\n']);
fprintf('Predictive PF of "%s" with SynB_RVM_%s.\n', 'Nasa93', our_type_char);

% set up the reported result
eval(['mae = mae_', our_type_char, ';']);               % mae
eval(['y_pre_mean = y_pre_mean_', our_type_char, ';'])  % y_pre_mean
eval(['hit_rate = hit_rate_', our_type_char, ';'])      % hit_rate
eval(['PIs = PI_', our_type_char, ';'])                 % PIs
eval(['relative_width = relative_width_', our_type_char, ';'])  % relative_width

% overall PF
fprintf([repmat('-', 1, 40), '\n']);
fprintf('Overall predictive PF is as below:\n');
fprintf('\t mae = %0.1f \n\t hit_rate = %0.2f \n\t relative width = %0.2f \n', mae, hit_rate, relative_width);

% PIs of test examples
fprintf([repmat('-', 1, 40), '\n']);
fprintf('Prediction intervals of CL=%0.2f of all test projects are as:\n', cl)
hit_bool = PIs(:,1) < y_test & y_test < PIs(:,2);
fprintf('%5s%10s %10s %21s %12s \n', 'id', 'actual', 'predicted', 'prediction interval', 'hit/not');
report_data = [(1:length(y_test))', y_test, y_pre_mean, PIs, hit_bool];
fprintf('%5d%10.2f %10.2f %9.2f -%10.2f \t\t %1d \n', report_data');

