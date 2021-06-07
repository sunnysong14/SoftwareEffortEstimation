function [Y_rvm,Std_rvm] = predRVM...
    (TrainX, TestX, kernel, width, weights, used, bias, beta, Sigma)
% PREDRVM
%   Prediction from RVM called after accomplishing RVM training.
%
% Copyright 2016-12: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

% point estimates
PHI = SB1_KernelFunction(TestX,TrainX,kernel,width);

% if return empty used_weight
if ~isempty(used)
    Y_rvm = PHI(:,used)*weights + bias; %normal
else
    Y_rvm = bias*ones(size(TestX,1),1); %no return, use bias
end

% std estimates
Std_rvm = -ones(size(TestX,1),1);
PHIt = SB1_KernelFunction(TestX,TrainX(used,:),kernel,width); % PHI of testing data
for jj=1:size(TestX,1) % predict Var one-by-one
    jPHIt = PHIt(jj,:);
    jVar = 1/beta+jPHIt*Sigma*jPHIt'; 
    %@real 'beta': beta_real=1/noise^2;jVar =1/beta_real+jPHIt*Sigma*jPHIt';
    Std_rvm(jj) = sqrt(jVar);
end

end%