function [result, Dataset] = logit_model(Dataset, params)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

Dataset.mean_utility = get_mean_utility(Dataset, params);
[beta,ci,xi,~,stats] = regress(Dataset.mean_utility,Dataset.Xd_hat);

result.beta = beta;
result.ci = ci;
result.stats = stats;
result.xi = xi;

end
