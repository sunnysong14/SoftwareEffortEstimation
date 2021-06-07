function [hit_rate, relative_width] = eval_PI_pf(PI, y_pre_mean, y_true)
% EVAL_PI_PF
%   Evaluate the probabilistic prediction PF with respect to PIs of a CL
%   for the test projects. The uncertain PF is measured in two metrics,
%   namely hit rate and relative width.
% 
%   If the number of test projects is small, one cannot get a precise PF
%   metric with hit rate or relative width, though one can still refer to
%   such metrics.
% 
% INPUT ARGUMENTS
%   PI              PI with a certain cl for some test projects
%   y_pre_mean      estimated mean efforts of those test projects
%   y_true          true efforts for these test projects
% 
% OUTPUT ARGUMENTS
%   hit_rate and relative_width         two pf metrics for uncertain pred

% Copyright 2021-5: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

n_test = length(y_true);

% hit rates
hit_rate = length(find(PI(:,1)<=y_true & y_true<=PI(:,2))) / n_test;

% relative widths
relative_width_arr = (PI(:,2)-PI(:,1))./abs(y_pre_mean);
relative_width = mean(relative_width_arr);

end%

