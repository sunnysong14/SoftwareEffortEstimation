function [X_train, y_train, X_test_recon] = get_nasa93_resource(resource_constraint)
% GET_NASA93_TEAM_EXPERTISE
% 
% USAGE EXAMPLE
%   >> get_nasa93_resource('highest')  % OR
%   >> get_nasa93_resource('lowest')   % OR
%   >> get_nasa93_resource('balanced')
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
% OUTPUT ARGUMENTS
%   X_train         features of the training examples
%   y_train         actual efforts of the training examples
%   X_test_recon    test projects with reconstructed resources features 
% 

% Copyright 2021-6: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

% setting up
datanm = 'nasa93_edited';
p_train = 0.9;         % training percentage

% get the whole data of (X, y)
Data = data_load(datanm);

% pre-process: the input features and return X
[years, X, y] = data_preprocess(Data);
n_data = length(y);

% split into the training and the test sets
[~, id_asc] = sort(years, 'ascend');
n_train = round(p_train*n_data);
id_train = id_asc(1:n_train);
id_test = setdiff(1:n_data, id_train)';

% split into the train-vs-test sets
X_train = X(id_train, :);
y_train = y(id_train);
X_test = X(id_test, :);  

% resource constraint features
id_resource = [3, 5, 6];        % development resource related features
%     3  |  data | data base size (constraint)
%     5  |  time | time constraint for cpu
%     6  |  stor | main memory constraint

% find the lowest / highest feature values
X_train_resource = X_train(:, id_resource);
min_resource = min(X_train_resource);
max_resource = max(X_train_resource);
% find the balanced feature value
get_median = @(ii) median(unique(X_train_resource(:,ii)));
med_resource = [get_median(1), get_median(2), get_median(3)];

% reconstruct test projects with the revised resources related features
n_test = length(id_test);
X_test_recon = X_test;

switch lower(resource_constraint)
    case 'lowest'
        X_test_recon(:, id_resource) = repmat(min_resource, n_test, 1);
    case 'highest'
        X_test_recon(:, id_resource) = repmat(max_resource, n_test, 1);
    case 'balanced'
        X_test_recon(:, id_resource) = repmat(med_resource, n_test, 1);
    otherwise
        error('Error: undefined resource_constraint_str value of %s.\n', resource_constraint);
end

end%
