function [PF_struct, mae] = eval_point_pf(y_tru, y_pre)
% EVAL_POINT_PF
%   Evaluate the point performance of SEE method. 
%   When isempty(y_tru), the result is NaN and needs to be handled outside. 
% 
% INPUT ARGUMENTS
%   y_tru   a column vector consisting of the true effort values
%   y_pre   a column vector consisting of the estimated effort values
% 
% OUTPUT ARGUMENTS
%   PF_struct   a structure that contains the point PF of a few metrics
%   mae         MAE of the point prediction PF
% 
% REFERENCE
%   for SA      Evaluating prediction systems in software project estimation, M.
%   Shepperd and Steve MacDonell, IST, 2012 

% Copyright 2017-12: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

N = length(y_tru); 

% AE
AE = abs(y_tru - y_pre); % absolute error

% MAE
mae = mean(AE);
PF_struct.mae = mae;

% MdAE
PF_struct.mdae = median(AE);

% lg.MAE
PF_struct.mlgae = mean(log(AE));

% median.lg.MAE
PF_struct.mdlgae = median(log(AE));

% MMRE
MRE = AE ./ y_tru;
PF_struct.mmre = mean(MRE);

% MdMRE
mdmre = median(MRE);
PF_struct.mdmre = mdmre;

% PRED(25)
PF_struct.pred25 = mean(MRE <= 0.25)*100;

% PRED(15)
PF_struct.pred15 = mean(MRE <= 0.15)*100;

% PRED(10)
PF_struct.pred10 = mean(MRE <= 0.1)*100;

% Coor
cYtru = mean(y_tru);
cYpre = mean(y_pre);
PF_struct.coor = (sum((y_pre-cYpre).*(y_tru-cYtru))) / sqrt(sum((y_pre-cYpre).^2).*sum((y_tru-cYtru).^2));

% LSD
if ~isempty(y_tru) %normal
    vld_id = y_pre>0;    
    e_arr = log(y_tru(vld_id)) - log(y_pre(vld_id));
    s2 = var(e_arr);
    PF_struct.lsd = sqrt(sum((e_arr + s2/2).^2) / (N-1));
    
else
    PF_struct.lsd = NaN;
end

% RMSE
PF_struct.rmse = sqrt(mean(AE.^2));

% RMdSE
PF_struct.rmdse = sqrt(median(AE.^2));

% % SA (Standard accuracy)
rng('default') % random control <-- randomness exists in randi()

if ~isempty(y_tru)    
    % mae of random guess
    tm = 1000;  % #=1000 suggested in the paper
    tMae = zeros(tm,1);
    for t = 1:tm 
        %tYpre = Ytru(randperm(N)); %core--[2018/04/18] wrong
        tYpre = y_tru(randi(N,N,1)); %core
        tMae(t) = mean(abs(y_tru-tYpre)); %mae
    end    
    % core
    PF_struct.sa = 1 - mae/mean(tMae); %the bigger the better
else
    PF_struct.sa = NaN;
end

end
