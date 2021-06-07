function [X_train, y_train, X_test, y_test] = get_nasa93()
% EXAMPLE_GET_NASA93        Get the train-test samples from Nasa93
%   Split the entire Nasa93 into the training (90%) and the test set (10%).
% 
% OUTPUT ARGUMENTS
%   X_train         features of the training examples
%   y_train         actual efforts of the training examples
%   X_test          features of the test examples
%   y_test          actual efforts of the test examples
% 
% Copyright 2021-5: Liyan Song
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

% training vs test separation
[~, id_asc] = sort(years, 'ascend');
n_train = round(p_train*n_data);
id_train = id_asc(1:n_train);
id_test = setdiff(1:n_data, id_train)';

% split into the train-vs-test sets
X_train = X(id_train, :);
y_train = y(id_train);
X_test = X(id_test, :);  
y_test = y(id_test);

end%