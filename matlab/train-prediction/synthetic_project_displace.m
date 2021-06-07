function [m_X_train, m_y_train] = ...
    synthetic_project_displace(id_m_train_bag, X_train, y_train, tho)
% SYNTHETIC_PROJECT_DISPLACEMENT
%   Replace replicated projects in a Boostrap training bag with their
%   corresponding synthetic counterparts, individually. This is inspired by
%   SMOTE (or jittering). By doing this, we would relieve the invertability
%   problem of RVM with repeated samples.
% 
% INPUT ARGUMENTS
% 
%   id_m_train_bag      training ID for projects in the m^th Bootsrap bag
%   X_train     features of the training projects
%   Y           efforts of the corresponding training projects
%   tho         in (0,1), the degree of synthetic displacement, 
%               the smaller, the more similar to the duplicated project
% 
% OUTPUT ARGUMENTS
%   m_X_train   features of the m^th Boostrap training bag, having beening
%               proceeded by synthetic project displacement
%   m_y_train   correspoinding effort values

% Copyright 2021-5: Liyan Song
% Contact the author: songly@sustech.edu.cn
% 

% % % % locate the duplicated projects

% calculate the times of each training example in the m^th Bootstrap bag
id_train_stat = tabulate(id_m_train_bag);
id_train_stat(id_train_stat(:,2)==0,:)=[];  % remove the empty entries

% find the replicated projects
id_train_duplicate = id_train_stat(id_train_stat(:,2)>1, 1);
m_X_duplicate = X_train(id_train_duplicate, :);

% compute the neighbors of duplicated projects (compute together for speed)
K_NEIGHBOR = 8;  % enlarge this value if be inadequate
id_train_knn = nearestneighbour(m_X_duplicate', X_train', 'NumberOfNeighbours', ...
    K_NEIGHBOR)';  % @transpose: nearestneighbour() requires data in col
% remove the dupilicated project itself
id_train_knn = id_train_knn(:, 2:end);

% % % % generate synthetic project for each duplicated project
X_syn = [];
y_syn = [];

% for each replicated project
for dp = 1 : length(id_train_duplicate)
    id_dup_ = id_train_duplicate(dp);
    
    X_dup_ = X_train(id_dup_,:);
    y_dup_ = y_train(id_dup_);
    
    % use 'furthest'
    n_syn = sum(id_dup_ == id_m_train_bag) - 1; 
    id_knn = id_train_knn(dp,end-n_syn+1:end);
    
    % one / multiple replications for a project
    for jj = 1 : length(id_knn)
       
        % produce synthetic features
        j_X_syn = (1-tho)*X_dup_ + tho*X_train(id_knn(jj), :); 
        
        % produce synthetic effort
        j_y_syn = (1-tho)*y_dup_ + tho*y_train(id_knn(jj)); 
        
        % update
        X_syn = [X_syn; j_X_syn];
        y_syn = [y_syn; j_y_syn];
    end
end

% construct the m^th Bootstrap training bag, the synthetic projects
m_X_train = [X_train(id_train_stat(:,1),:); X_syn];  % synthetic project appendix
m_y_train = [y_train(id_train_stat(:,1),:); y_syn];

end%if
