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
prod_char = [Dataset.data.weight Dataset.data.hp Dataset.data.AC];

%% Vertical Model (Question 1)
params.lambda = 4e-6;

Dataset.Xd = [ones(params.nb_cars,1) prod_char];
[result, Dataset] = vertical_model(Dataset, params);
result.beta

%% Question 2

% Elasticities
%% Question 3

%% Logit

params.model = 'logit';

for i = 1:params.nb_cars
    sum_within(i,:) = sum(prod_char(Dataset.data.firm==Dataset.data.firm(i),:),1);
    sum_outside(i,:) = sum(prod_char(Dataset.data.firm~=Dataset.data.firm(i),:),1);
end

sum_within = sum_within-prod_char;

Dataset.IV = [ones(params.nb_cars,1) prod_char sum_outside];
Dataset.Xd = [ones(params.nb_cars,1) -Dataset.data.price prod_char];

Dataset.W = inv(Dataset.IV'*Dataset.IV);
Dataset.Xdhat = Dataset.IV* Dataset.W * Dataset.IV' * Dataset.Xd ;


Dataset.mean_utility = get_mean_utility(Dataset, params);
[beta,ci,xi,~,stats] = regress(Dataset.mean_utility,Dataset.Xdhat);

result.beta = beta
result.ci = ci;
result.stats = stats;

%% BLP
params.model = 'BLP';
params.nb_draws = 1000;
params.income_mean = 35000;
params.income_sd = 45000;
params.nK = 1;

% Draw income from lognormal
mu = log((params.income_mean^2)/sqrt(params.income_sd^2+params.income_mean^2));
sigma = sqrt(log(params.income_sd^2/(params.income_mean^2)+1));

Draws.income = lognrnd(mu,sigma,1,params.nb_draws);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step 1: Estimation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%================  1.1: Matrix of Theta ==========================
%theta=[alpha; sigma_p; lambda]
params.nb_init = 1000;

% Set particular inital values
theta_start = 1;

% Set bounds
lower_bound = 0;
upper_bound = 1000;

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
    [theta_mat(i,1)] = fmincon('gmm_fun', theta_init(i), [],[],[],[],...
        lower_bound,upper_bound,[], options, Dataset, params, Draws);
end


save output/result.mat
