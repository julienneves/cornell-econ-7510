function [result, Dataset] = vertical_model(Dataset, params)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
lambda = params.lambda;
specification = params.specification;

shares = Dataset.shares;
price = Dataset.data.price;
Xd = Dataset.Xd;

% Add outside option price and share
shares = [1-sum(shares); shares];
price = [0; price];

% Compute mean utility for alpha ~ exponential
share_cumsum = cumsum(shares);
price_diff = diff(price);

mean_utility = -log(share_cumsum(1:end-1,1)).*price_diff/lambda;
mean_utility = cumsum(mean_utility);

switch specification
    case 'demand'
        % OLS of mean_utility
        [beta,ci,xi,~,stats] = regress(mean_utility,Xd);
        
        [b, e] = get_markup(Dataset, params);
        result.demand.elasticities = e;
        
        Dataset.mean_utility = mean_utility;
        result.demand.elasticities = e;
        result.demand.xi = xi;
        result.demand.beta = beta;
        result.demand.ci = ci;
        result.demand.stats = stats;
        
    otherwise
        Xd = Dataset.Xd ;
        Xs = Dataset.Xs ;
        
        [beta,ci_d,xi,~,stats_d] = regress(mean_utility,Xd);
        
        result.demand.xi = xi;       
        result.demand.beta = beta;
        result.demand.ci = ci_d;
        result.demand.stats = stats_d;
        
        [b, e] = get_markup(Dataset, params);
        
        marginal_cost = Dataset.data.price-b;
        
        [gamma,ci_s,wi,~,stats_s] = regress(marginal_cost,Xs);
        
        result.supply.markup = b;
        result.supply.elasticities = e;
        result.supply.wi = wi;
        result.supply.beta = gamma;
        result.supply.ci = ci_s;
        result.supply.stats = stats_s;
 
end

end

