function [b, e, delta] = get_markup(Dataset, params, result, Draws)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

model = params.model;
specification = params.specification;

switch model
    case 'vertical'
        lambda = params.lambda;
        shares = Dataset.shares;
        price = Dataset.data.price;
        
        % Add outside option price and share
        shares = [1-sum(shares); shares];
        price = [0; price];
        
        % Compute mean utility for alpha ~ exponential
        share_cumsum = cumsum(shares);
        price_diff = diff(price);
        
        temp = share_cumsum(1:end-1,1)./(price_diff).^2;
        
        delta = zeros(size(temp,1)+1);
        
        delta(1:end-1,1:end-1) = -lambda*diag(temp) + delta(1:end-1,1:end-1);
        delta(2:end,2:end) = -lambda*diag(temp) + delta(2:end,2:end);
        delta(1:end-1,2:end) = lambda*diag(temp) + delta(1:end-1,2:end);
        delta(2:end,1:end-1) = lambda*diag(temp) + delta(2:end,1:end-1);
        
        
        delta = delta(2:end,2:end);
        price = price(2:end,1);
        shares = shares(2:end,1);
        e = delta.*(price'./shares);
        
    case 'logit'
        shares = Dataset.shares;
        price = Dataset.data.price;
        alpha = result.demand.alpha;
        
        delta = alpha*(shares.*shares'-diag(shares));
        e = delta.*(price'./shares);
    case 'BLP'
        shares = Dataset.shares;
        price = Dataset.data.price;
        mean_utility = Dataset.mean_utility;
        alpha = result.alpha;
        yi = Draws.income;
        nb_draws = size(yi,2);
        
        Numerator = exp(mean_utility - alpha(2)*price./yi);
        ind_prob = bsxfun(@rdivide, Numerator, 1+sum(Numerator,1));
        delta = zeros(size(ind_prob,1));
        
        for i = 1:nb_draws
            temp = ind_prob(:,i);
            D = (alpha(1)+alpha(2)/yi(:,i))*(temp.*temp'-diag(temp));
            
            delta = delta + D;
        end
        delta = delta/nb_draws;
        e = delta.*(price'./shares);
end

switch specification
    case 'single'
        b = (eye(size(delta)).*delta)\shares;
    case 'multiple'
        b  = (dummyvar(Dataset.data.firm)*dummyvar(Dataset.data.firm)'.*delta)\shares;
    case 'collusion'
        b = (ones(size(delta)).*delta)\shares;
    otherwise
        b = 0;
end


end

