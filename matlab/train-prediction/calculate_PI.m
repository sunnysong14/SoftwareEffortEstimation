function PI = calculate_PI(cl, y_pre_mean, y_pre_std)
% CALCULATE_PI
%   Calculate PI in line with a given cl produced by SynB-RVM.
%
% INPUT ARGUMENTS
%   cl           \in (0,1), the given confidence level
%   y_pre_mean   scalar / vector containing the estimated effort mean(s)
%   y_pre_std    scalar / vector containing the estimated effort std(s)
% 
% OUTPUT ARGUMENTS
%   PI          prediction interval regarding the given cl. It is a scalar
%               when only one test project is proceeded; it is a vector
%               when a batch of test projects are produced.

% Copyright 2021-5: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

% theory: cl = 2*normcdf(kl,0,1)-1;
kl = norminv((cl+1)/2,0,1);  % 1-normcdf(kl)=1-(1-cl)/2.

% PIs
PI = [max( 0,y_pre_mean- kl*y_pre_std ), y_pre_mean+ kl*y_pre_std];  % kl-Sigma

end%