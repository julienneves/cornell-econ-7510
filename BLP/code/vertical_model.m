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

[b, e] = get_markup(Dataset, params);
result.markup = b;
result.elasticities = e;

marginal_cost = Dataset.data.price-b;
switch specification
    case 'single'
        b = (eye(size(delta)).*delta)\shares;
    case 'multiple'
        b  = (dummyvar(Dataset.data.firm)*dummyvar(Dataset.data.firm)'.*delta)\shares;
    case 'collusion'
        b = (ones(size(delta)).*delta)\shares;
    case 'competition'
        b = 0;

        
    otherwise
        % OLS of mean_utility
        [beta,ci,xi,~,stats] = regress(mean_utility,Xd);
        
        % Save
        Dataset.xi = xi;
        Dataset.mean_utility = mean_utility;
        result.beta = beta;
        result.ci = ci;
        result.stats = stats;
        
end

end

