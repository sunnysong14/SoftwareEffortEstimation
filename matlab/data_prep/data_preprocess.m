function [years, X, y] = data_preprocess(Data)
% DATA_PREPROCESS       
%   Get the features and efforts of projects for a given dataset,and
%   pr-eprocess the features with z-score.
% 
% INPUT ARGUMENT
%   Data    the whole set of original data in (X, y)
% 
% OUTPUT ARGUMENTS
%   years   years of development (suppose it to be the finished year)
%   X       features of SEE projects after being pre-processed
%   y       A vector of effort values for each projects
 
% Copyright 2018-4: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

% extract data infor
d = size(Data, 2);
years = Data(:, 1);
X = Data(:, 2:d-1);
y = Data(:, d);

% remove 3 outliers of nasa93
% histogram(y)
retain_bool = y <= 3000;  % threshold 3000 is for Nasa93
years = years(retain_bool);
X = X(retain_bool, :);
y = y(retain_bool);

% pr-eprocess X with zScore
[temp, PS1] = mapstd(X');
X = temp';

end%