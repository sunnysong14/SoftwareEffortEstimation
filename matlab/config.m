function config()
% CONFIG    Configurate the file paths for experiments.
% 
% Copyright 2016: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

% set curPath to this .m
if(~isdeployed)
    cd(fileparts(which(mfilename)));
end

% path.codes
addpath(genpath(['.', filesep]));    
%genpath: generate a list of directories containted in this directory

fprintf('\nCode folders are settled up successfully.\n') 
fprintf('"%s" is the current directory.\n',pwd)

end%FUNCTION
