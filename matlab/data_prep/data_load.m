function Data = data_load(datanm)
% DATALOAD   Load SEE data and proceed data preprocess
% 
% INPUT ARGUMENT
%   datanm  the full dataset name in the "data" file
% 
% OUTPUT ARGUMENTS
%   Data    the whole set of original data in (X, y)
% 
% Copyright 2021-5: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

% the folder name containing the data should not be changed
from_dir = ['..', filesep, 'data_example',filesep];

% load SEE data
flnm = [from_dir, datanm];
if exist(flnm, 'file')
    Data = load(flnm);
else
    error(['Error: ', flnm, ' not included.']);
end

end%

