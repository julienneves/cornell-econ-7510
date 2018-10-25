function market_share = get_shares(mean_utility, Dataset, params, theta, Draws)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
model = params.model;

switch model 
    case 'logit'
        Numerator = exp(mean_utility);
        market_share = bsxfun(@rdivide, Numerator, 1+sum(Numerator));
    case 'BLP'
        price = Dataset.data.price;
        yi = Draws.income;
        
        Numerator = exp(mean_utility - theta(1)*price./yi);
        ind_prob = bsxfun(@rdivide, Numerator, 1+sum(Numerator,1));
        market_share = sum(ind_prob,2);
    otherwise
        warning('No model')
end


end

