function example_run_SynB_RVM()
% EXAMPLE_RUN_SYNB_RVM
%   Example of running the training and prediction algorithms on Nasa93.
%   Hyper-parameters of SynB-RVM are set up from experience.
% 
% OUTPUT EXAMPLE
%     ========================================
%     Prediction intervals with CL 0.85 of test projects in Nasa93 are:
%        id      actual   point estimate   prediction interval      hit/not 
%         1      210.00       233.33        109.37 -   357.29 		 1 
%         2       48.00       133.33          1.38 -   265.29 		 1 
%         3       50.00        55.00          0.00 -   162.96 		 1 
%         4       60.00        65.00          0.00 -   172.96 		 1 
%         5       42.00       122.22          6.26 -   238.18 		 1 
%         6       60.00       144.44         28.48 -   260.41 		 1 
%         7      444.00       516.67        408.70 -   624.63 		 1 
%         8       42.00       144.44         28.48 -   260.41 		 1 
%         9      114.00       183.33         67.37 -   299.30 		 1 
% 
% Copyright 2021-5: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

% get the train-test dataset for nasa93
[X_train, y_train, X_test, y_test] = get_nasa93();

% SynB-RVM's hyper-parameters
m_bags = 10;        %  #(Bootstrap Bags)
pru_m = 0.1;        % prune rate
tho = 0.01;         % synthetic displacement
% 
width_best = 4.3;   % can be independently tuned with a validation set

% confidence level
cl = 0.85;

% the training and prediction algorithms of SynB-RVM
[y_pre_mean_spMn, PI_spMn, y_pre_mean_ht1d, PI_ht1d, y_pre_mean_ht2d, PI_ht2d] ...
    = SynB_RVM(cl, m_bags, tho, pru_m, X_train, y_train, X_test, width_best);


% % % % print the prediction

% choose one form of SynB-RVM
our_type_char = lower('ht2D');  % % spMn, ht1d, ht2d
eval(['y_pre_mean = y_pre_mean_', our_type_char, ';'])  % y_pre_mean
eval(['PIs = PI_', our_type_char, ';'])                 % PIs

% PIs of test examples
fprintf(['\n', repmat('=', 1, 40), '\n']);
fprintf('Prediction intervals with CL %0.2f of test projects in Nasa93 are:\n', cl)
hit_bool = PIs(:,1) < y_test & y_test < PIs(:,2);
fprintf('%5s%12s %16s %21s %12s \n', 'id', 'actual', 'point estimate', 'prediction interval', 'hit/not');
report_data = [(1:length(y_test))', y_test, y_pre_mean, PIs, hit_bool];
fprintf('%5d%12.2f %12.2f %13.2f -%9.2f \t\t %1d \n', report_data');

end%