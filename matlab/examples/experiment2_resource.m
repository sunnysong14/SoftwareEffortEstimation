function experiment2_resource(resource_constraint)
% EXPERIMENT_2_RESOURCE
%   Experimental showcase to reconstruct development resource related data
%   features with their highest / lowest values, in the dataset Nasa93. 
%   This can investigate the extreme development scenarios where the lowest
%   or highest computational and storage resources can be adopted, and get
%   the impression approximately to what extent SynB-RVM would predict
%   the efforts to develop software under such circumstance.
% 
% INPUT ARGUMENTS
%   resource_constraint     To reconstruct the scenario where we have the
%                           most / least / balanced development resources
%                           for the software  development in Nasa93. 
%                           Resource related features include 'stor' (main
%                           memory constraint), 'data' (data base size
%                           constrain) and 'time' (time constraint for cpu). 
% 
%                           Correspondingly, |resource_constraint| has three values: 
%                           1) 'lowest' -- the lowest resources constraint;
%                           2) 'highest' -- the highest resources constraint;
%                           3) 'balanced' -- the balanced resource constraint.
%   
% NOTE
%   Evaluation process is omitted in this script as the actual effort to
%   develop these revised software projects are unknown. 
% 
% 
% EXAMPLE 1       Highest constraint on the resources
%     >> experiment2_resource('highest')
% 
%     ========================================
%     SynB-RVM_ht2d's prediction on the test projects in Nasa93 
%     that are reconstructed with the highest resource constraint.
%     Prediction intervals are with confidence level of 0.85.
%        id predicted   prediction interval 
%         1    805.56    689.59 -    921.52 
%         2    472.22    372.25 -    572.19 
%         3    516.67    424.70 -    608.64 
%         4    516.67    424.70 -    608.64 
%         5    638.89    522.93 -    754.85 
%         6    527.78    411.82 -    643.74 
%         7    750.00    642.04 -    857.96 
%         8    527.78    411.82 -    643.74 
%         9    527.78    411.82 -    643.74 
% 
% 
%  EXAMPLE 2      Lowest constraint on the resources
%     >> experiment2_resource('lowest')
% 
%     ========================================
%     SynB-RVM_ht2d's prediction on the test projects in Nasa93 
%     that are reconstructed with the lowest resource constraint.
%     Prediction intervals are with confidence level of 0.85.
%        id predicted   prediction interval 
%         1    166.67     50.70 -    282.63 
%         2    128.57     10.32 -    246.82 
%         3     55.00      0.00 -    162.96 
%         4     65.00      0.00 -    172.96 
%         5    125.00      8.04 -    241.96 
%         6    144.44     36.48 -    252.41 
%         7    455.56    347.59 -    563.52 
%         8    125.00     17.04 -    232.96 
%         9    144.44     36.48 -    252.41 
% 
% 
% EXAMPLE 3       Balanced constraint on the resources
%     >> experiment2_resource('balanced')
%     ========================================
%     SynB-RVM_ht2d's prediction on the test projects in Nasa93 
%     that are reconstructed with the balanced resource constraint.
%     Prediction intervals are with confidence level of 0.85.
%        id predicted   prediction interval 
%         1    433.33    301.38 -    565.29 
%         2    188.89     72.93 -    304.85 
%         3    277.78    169.81 -    385.74 
%         4    300.00    192.04 -    407.96 
%         5    383.33    267.37 -    499.30 
%         6    283.33    167.37 -    399.30 
%         7    616.67    508.70 -    724.63 
%         8    300.00    192.04 -    407.96 
%         9    316.67    200.70 -    432.63 

% Copyright 2021-6: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 


% % % % reconstruct nasa93 and get the train-test dataset
[X_train, y_train, X_test_recon] = get_nasa93_resource(resource_constraint);


% % % % the training and prediction algorithms of SynB-RVM

% SynB-RVM's hyper-parameters
width_use = 4.3;    % width of the RBF kernel in RVM
m_bags = 10;        %  #(Bootstrap Bags)
tho = 0.01;         % syn displace; tho=0: without Syn
pru_m = 0.1;        % prune rate

% confidence level
cl = 0.85;

% the training and prediction algorithms
[y_pre_mean_spMn, PI_spMn, y_pre_mean_ht1d, PI_ht1d, y_pre_mean_ht2d, PI_ht2d] ...
    = SynB_RVM(cl, m_bags, tho, pru_m, X_train, y_train, X_test_recon, width_use);


% % % % Result showcase

% choose one form of SynB-RVM
our_type_char = lower('ht2D');  % % spMn, ht1d, ht2d
% set up the reported result
eval(['y_pre_mean = y_pre_mean_', our_type_char, ';'])  % y_pre_mean
eval(['PIs = PI_', our_type_char, ';'])                 % PIs

% PIs of test examples
fprintf([repmat('=', 1, 40), '\n']);
fprintf('SynB-RVM_%s''s prediction on the test projects in Nasa93 that \nare reconstructed with the %s resource constraint.\n', ...
    our_type_char, resource_constraint);
fprintf('Prediction intervals are with the confidence level of %0.2f.\n', cl);
fprintf('%5s%10s %21s \n', 'id', 'predicted', 'prediction interval');
report_data = [(1:length(y_pre_mean))', y_pre_mean, PIs];
fprintf('%5d%10.2f %9.2f -%10.2f \n', report_data');

end%
