%% Prepare Data
clc
clear

%% Change Folder
% Get folder where J0_prepare_data is located
folder = fileparts(which('prepare_data')) ;
% Change to parent folder and add subfolders to path
cd(folder);
cd('..');
addpath(genpath(cd));

prepare_data

%% Load data

load Dataset
params.number_product = size(Dataset.data,1);
params.mean_utility_tol = 1e-12;
params.max_ite = 5000;
params.M = 100000000;
params.nb_cars = size(Dataset.data.price,1);

% Sort by price
Dataset.data = sortrows(Dataset.data,1);

% Compute shares
Dataset.shares = Dataset.data.quantity/params.M;

% 
firm_dummy = dummyvar(Dataset.data.firm);
prod_char = [Dataset.data.weight Dataset.data.hp Dataset.data.AC];

%% Vertical Model (Question 1)
params.lambda = 4e-6;
params.model = 'vertical';
params.specification = '';

% Define 
Dataset.Xd = [ones(params.nb_cars,1) prod_char firm_dummy(:,2:end)];

% Estimate model
[est, Dataset] = vertical_model(Dataset, params);
result.vertical = est;

%% Question 2
% Elasticities
disp(result.vertical.elasticities);


%% Question 3
params.IV_type = 'BLP';
Dataset.Xd = [ones(params.nb_cars,1) prod_char firm_dummy(:,2:end)];
Dataset.Xs = [ones(params.nb_cars,1) prod_char firm_dummy(:,2:end) Dataset.data.quantity];

Dataset = create_iv(Dataset, params);

Dataset.Xd_hat = Dataset.IV* Dataset.W * Dataset.IV' * Dataset.Xd ;
Dataset.Xs_hat = Dataset.IV* Dataset.W * Dataset.IV' * Dataset.Xs ;

% Competition
params.specification = 'competition';
[est, Dataset] = vertical_model(Dataset, params);
result.vertical.competition = est;

% Single
params.specification = 'single';
[est, Dataset] = vertical_model(Dataset, params);
result.vertical.single = est;


% Multiple
params.specification = 'multiple';
[est, Dataset] = vertical_model(Dataset, params);
result.vertical.multiple = est;

% Collusion
params.specification = 'collusion';
[est, Dataset] = vertical_model(Dataset, params);
result.vertical.collusion = est;


%% Logit

params.model = 'logit';

Dataset.Xd = [ones(params.nb_cars,1) prod_char  firm_dummy(:,2:end) -Dataset.data.price];

Dataset = create_iv(Dataset, params);

Dataset.W = inv(Dataset.IV'*Dataset.IV);
Dataset.Xd_hat = Dataset.IV* Dataset.W * Dataset.IV' * Dataset.Xd ;


Dataset.mean_utility = get_mean_utility(Dataset, params);
[beta,ci,xi,~,stats] = regress(Dataset.mean_utility,Dataset.Xdhat);

result.logit.beta = beta;
result.logit.ci = ci;
result.logit.stats = stats;

save output/result.mat

%% BLP
params.model = 'BLP';
params.nb_draws = 1000;
params.income_mean = 35000;
params.income_sd = 45000;
params.nK = 1;

% Draw income from lognormal
mu = log((params.income_mean^2)/sqrt(params.income_sd^2+params.income_mean^2));
sigma = sqrt(log(params.income_sd^2/(params.income_mean^2)+1));

Dataset.IV = [ones(params.nb_cars,1) prod_char sum_outside];
Dataset.Xd = [ones(params.nb_cars,1) prod_char -Dataset.data.price];

Draws.income = lognrnd(mu,sigma,1,params.nb_draws);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%================  1.1: Matrix of Theta ==========================
%theta=[alpha; sigma_p; lambda]
params.nb_init = 100;

% Set particular inital values
theta_start = 1;

% Set bounds
lower_bound = 0;
upper_bound = 100;

theta_init = linspace(lower_bound,upper_bound, params.nb_init);

% Combine inital value and random grid points
theta_init=[theta_start, theta_init];


%================  1.2. Optimal GMM ==========================
options = optimoptions('fmincon','Display','iter', ...
        'SpecifyObjectiveGradient',false,'CheckGradients',false, ...
        'FiniteDifferenceType', 'central', ...
        'FiniteDifferenceStepSize', 1e-10,'StepTolerance',1e-10, ...
        'MaxFunEval', inf, 'MaxIter', inf);
    
%%%%%%% Find estimates using different initial values
theta_mat = zeros(params.nb_init, params.nK);

for i=1:params.nb_init
    % Estimation
    theta_mat(i) = fmincon('gmm_fun', theta_init(i), [], [], [], [], ...
                            lower_bound, upper_bound, [], options, ...
                            Dataset, params, Draws);
                        
    [objective_val, est] = gmm_fun(theta_mat(i), Dataset, params, Draws);
    result.blp{i}.start = theta_init(i);
    result.blp{i}.theta = theta_mat(i);
    result.blp{i}.beta = est.beta;
    result.blp{i}.ci = est.ci;
    result.blp{i}.stats = est.stats;
end



