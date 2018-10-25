function [result, Dataset] = logit_model(Dataset, params)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

Xd = Dataset.Xd;
specification = params.specification;
mean_utility = get_mean_utility(Dataset, params);


switch specification
    case 'demand'
        % OLS of mean_utility
        
        [beta,ci,xi,~,stats] = regress(mean_utility,Xd);
        
        result.demand.xi = xi;
        result.demand.beta = beta;
        result.demand.alpha = beta(end);
        result.demand.ci = ci;
        result.demand.stats = stats;
        
        [b, e] = get_markup(Dataset, params, result);
                
        Dataset.mean_utility = mean_utility;
        result.demand.elasticities = e;
        
    otherwise
        Xd = Dataset.Xd ;
        Xs = Dataset.Xs ;
        
        [beta,ci_d,xi,~,stats_d] = regress(mean_utility,Xd);
        
        result.demand.xi = xi;
        result.demand.beta = beta;
        result.demand.alpha = beta(end);
        result.demand.ci = ci_d;
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
 
end

end
