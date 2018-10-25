function [result, Dataset] = logit_model(Dataset, params)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
specification = params.specification;
mean_utility = get_mean_utility(Dataset, params);


switch specification
    case 'demand'
        % OLS of mean_utility
        Xd = Dataset.Pz*Dataset.Xd;
        
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
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Step 1: Estimation
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %================  1.1: Matrix of Theta ==========================
        %theta=[alpha; sigma_p; lambda]
        nb_init = params.nb_init;
        nK = params.nK;
        
        % Set particular inital values
        theta_start= params.theta_start;
        
        % Set bounds
        lower_bound = params.lower_bound;
        upper_bound =params.upper_bound;
        
        theta_init = linspace(lower_bound,upper_bound, nb_init);
        
        % Combine inital value and random grid points
        theta_init=[theta_start, theta_init];
        
        
        %================  1.2. Optimal GMM ==========================
        options = optimoptions('fmincon','Display','iter', ...
            'SpecifyObjectiveGradient',false,'CheckGradients',false, ...
            'FiniteDifferenceType', 'central', ...
            'FiniteDifferenceStepSize', 1e-10,'StepTolerance',1e-10, ...
            'MaxFunEval', inf, 'MaxIter', inf);
        
        %%%%%%% Find estimates using different initial values
        theta_mat = zeros(nb_init, nK);
        
        for i=1:params.nb_init
            % Estimation
            theta_mat(i) = fmincon('gmm_logit', theta_init(i), [], [], [], [], ...
                lower_bound, upper_bound, [], options, ...
                Dataset, params);
            
            [fval, est] = gmm_logit(theta_mat(i), Dataset, params);
            result{i}= est;
            result{i}.start = theta_init(i);
            result{i}.theta = theta_mat(i);
            result{i}.fval = fval;
            clc;
        end
        
end

end
