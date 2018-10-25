function [objective_val, est] = gmm_fun(theta, Dataset, params, Draws)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

IV = Dataset.IV;
Xd = Dataset.Pz*Dataset.Xd;
W = Dataset.W;

mean_utility = get_mean_utility(Dataset, params, Draws, theta);

[beta,ci,xi,~,stats] = regress(mean_utility,Xd);
est.beta = beta;
est.ci = ci;
est.stats = stats;
est.alpha = [beta(end) theta];
Dataset.mean_utility;

[b,e,~] = get_markup(Dataset, params, est, Draws);
est.elasticities = e;

objective_val = (IV' * xi)'* W * (IV' * xi);


end

