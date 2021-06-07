function width_best = config_RVM_best_width(datanm)
% CONFIG_RVM_BEST_WIDTH     
%   Preknowledge on the best width of RVM from our previous paper
%   PROMISE'14 [The Potential Benefit of Relevance Vector Machine to
%   Software Effort Estimation]
% 
% INPUT ARGUMENT
%   datanm      full name of the dataset stored in the "data" folder
% 
% OUTPUT ARGUMENT
%   width_best  return the optimal width for RVM acc PROMISE'14 

% Copyright 2014: Liyan Song

% get data name
switch lower(datanm)
    case lower('maxwell')
        width_best = 5.5;
        
    case lower('kitchenham')
        width_best = 9.3;

    case lower('coc81_1_1_numeric_edited')
        width_best = 2.7;
        
    case lower('nasa93_edited')
        width_best = 4.3;
        
    % ------------ 2021-5 newly tune
    case lower('desharnais_edited')
        width_best = 4.2;
        
    case lower('cocomonasa')
        width_best = 4.5;
        
    otherwise
        fprintf('None pre-knowledge on the optimal width of RVM in %s.\n', datanm);
        fprintf('Better to pre-tune the RVM parameter. \n')
        width_best = 5.5; 
        fprintf('For now, let us adopt a impetuous setting of %0.2f:\n', width_best);
end
end