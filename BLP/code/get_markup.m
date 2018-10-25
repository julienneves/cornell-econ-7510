function [b,e] = get_markup(Dataset, params, Draws)
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
        
        temp = delta.*(price'./shares);
        e = temp(2:end,2:end);
    case 'logit'
        shares = Dataset.shares;
        price = Dataset.data.price;
        alpha = result.beta(end);
        
        delta = alpha*(shares./shares'-diag(shares));
        e = delta.*(price'./shares);
    case 'blp'
        shares = Dataset.shares;
        price = Dataset.data.price;
        alpha = result.alpha;
        
        
        delta = alpha*(shares./shares'-diag(shares));
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

