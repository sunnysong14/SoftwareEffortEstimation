function [weights,used,bias,beta,Sigma,tagBreakLoop] = trainRVM(X,T,kernel,width)
% TRAINRVM
%   Config Tipping's RVM codes. Specifically, I set up the default values 
%   of $initAlpha,initBeta,kernel,lengthScale,useBias,maxIts,monIts$ in
%   SB1_RVM() according to Tipping's SB1_ExampleRegress(). 
% 
% INPUT ARGUMENTS:
%   X -- The matrix containing features of all training samples. The
%   training samples are in rows, and features are in columns. 
%   T -- Target vector of training samples. Can be noisy or noise-free.
%   kernel -- The type of basis functions - 'gauss' by default.
%   width -- The width of Gauss kernel of RVM. the only manually tuned
%   parameter.
% 
% OUTPUT ARGUMENTS:
%   weights -- RVM's weight parameters. 
%   used -- ID of training samples $X$ that are support vectors.
%   bias -- RVM's bias parameter.
%   beta -- 'sqrt(1/beta)' indicates the estimated noise level, i.e. std(\eta).
%   tagBreakLoop -- see 'SB1_EstimateL()'.

% Copyright 2016-12: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

% Set verbosity of output (0 to 4)
setEnvironment('Diagnostic','verbosity',4);
% Set file ID to write to (1 = stdout)
setEnvironment('Diagnostic','fid',1);

N = size(X,1);

% Set up initial hyperparameters acc Tipping's suggestion
initAlpha = (1/N)^2;
epsilon	= std(T) * 10/100; % Initial guess of 10% noise-to-signal
initBeta = 1/epsilon^2;

useBias	= true;
maxIts = 1200;
monIts = round(maxIts/10);
if ~exist('kernel', 'var')
    kernel = 'gauss';
end

% "Train" a sparse Bayes kernel-based model (relevance vector machine)
[weights,used,bias,marginal,alpha,beta,gamma,Sigma,tagBreakLoop] = ...
    SB1_RVML(X,T,initAlpha,initBeta,kernel,width,useBias,maxIts,monIts);

end
