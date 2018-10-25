function [result, Dataset] = blp_model(Dataset, params, Draws)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

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
    theta_mat(i) = fmincon('gmm_fun', theta_init(i), [], [], [], [], ...
                            lower_bound, upper_bound, [], options, ...
                            Dataset, params, Draws);
                        
    [fval, est] = gmm_fun(theta_mat(i), Dataset, params, Draws);
    result{i}.start = theta_init(i);
    result{i}.theta = theta_mat(i);
    result{i}.fval = fval;
    result{i}.beta = est.beta;
    result{i}.ci = est.ci;
    result{i}.stats = est.stats;
    clc;
end


end
