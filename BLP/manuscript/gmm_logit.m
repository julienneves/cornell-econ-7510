function [objective_val, result] = gmm_logit(theta, Dataset, params)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

alpha = theta;
result.demand.alpha = alpha;
Xd = Dataset.Pz*Dataset.Xd ;
Xs = Dataset.Pz*Dataset.Xs ;

hessian = params.hessian;
tval = tinv(.95,(size(Xd,1)-size(Xd,2)));
se = sqrt(diag(inv(hessian)));
ci_theta = [theta-se*tval theta+se*tval];

mean_utility = get_mean_utility(Dataset, params);

Yd = mean_utility + alpha*Dataset.data.price;

[beta,ci_d,xi,~,stats_d] = regress(Yd,Xd);

result.demand.xi = xi;
result.demand.beta = [beta; alpha];
result.demand.ci = [ci_d; ci_theta];
result.demand.stats = stats_d;

[b, e] = get_markup(Dataset, params, result);
marginal_cost = Dataset.data.price-b;

[gamma,ci_s,wi,~,stats_s] = regress(marginal_cost,Xs);

Dataset.mean_utility = mean_utility;
result.demand.elasticities = e;
result.supply.markup = b;
result.supply.elasticities = e;
result.supply.wi = wi;
result.supply.gamma = gamma;
result.supply.ci = ci_s;
result.supply.stats = stats_s;


IV = blkdiag(Dataset.IV, Dataset.IV);
residual = [xi; wi];
W = blkdiag(Dataset.W, Dataset.W);

% Need to check this
objective_val = (IV' * residual)'* W * (IV' * residual);


end