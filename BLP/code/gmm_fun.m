function [objective_val, est] = gmm_fun(theta, Dataset, params, Draws)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

IV = Dataset.IV;
Xd_hat = Dataset.Xd_hat;
W = Dataset.W;

mean_utility = get_mean_utility(Dataset, params, Draws, theta);

[beta,ci,xi,~,stats] = regress(mean_utility,Xd_hat);
est.beta = beta;
est.ci = ci;
est.stats = stats;

objective_val = (IV' * xi)'* W * (IV' * xi);


end

