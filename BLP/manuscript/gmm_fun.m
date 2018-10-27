function [objective_val, est] = gmm_fun(theta, Dataset, params, Draws)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

IV = Dataset.IV;
Xd = Dataset.Pz*Dataset.Xd;
W = Dataset.W;
hessian = params.hessian;
tval = tinv(.95,size(Xd,1)-size(Xd,2));
se = sqrt(diag(inv(hessian)));
ci_theta = [theta-se*tval theta+se*tval];

mean_utility = get_mean_utility(Dataset, params, Draws, theta);

[beta,ci,xi,~,stats] = regress(mean_utility,Xd);
est.beta = [beta; theta];
est.stats = stats;
est.ci = [ci; ci_theta];
est.alpha = [beta(end) theta];
Dataset.mean_utility;

[b,e,~] = get_markup(Dataset, params, est, Draws);
est.elasticities = e;


objective_val = (IV' * xi)'* W * (IV' * xi);


end

