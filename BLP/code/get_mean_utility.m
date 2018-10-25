function mean_utility = get_mean_utility(Dataset, params, Draws, theta)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
model = params.model;
tol = params.mean_utility_tol;
max_ite = params.max_ite;

shares = Dataset.shares;
mean_utility = zeros(size(shares));

switch model 
    case 'logit'
        ite = 0;
        tol_crit = 1;
        while tol_crit>tol && ite <= max_ite
            shares_sim = get_shares(mean_utility, Dataset, params);
            mean_utility = mean_utility + log(shares) - log(shares_sim);
            
            ite = ite + 1;
            tol_crit = norm(shares-shares_sim);
            
            %fprintf('Iteration: %1$d Criteria: %2$e \n', ite,tol_crit)
        end
    case 'BLP'
        ite = 0;
        tol_crit = 1;
        while tol_crit>tol && ite <= max_ite
            shares_sim = get_shares(mean_utility, Dataset, params, theta, Draws);
            mean_utility = mean_utility + log(shares) - log(shares_sim);
            
            ite = ite + 1;
            tol_crit = norm(shares-shares_sim);
            %fprintf('Iteration: %1$d Criteria: %2$e \n', ite,tol_crit)
        end
    otherwise
        warning('No model')
end
end

