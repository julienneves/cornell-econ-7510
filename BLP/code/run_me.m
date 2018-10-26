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


%% Prepare data
prepare_data

load Dataset
params.number_product = size(Dataset.data,1);
params.mean_utility_tol = 1e-12;
params.max_ite = 5000;
params.M = 100000000;
params.nb_cars = size(Dataset.data.price,1);
params.IV_type = 'Houde';


% Sort by price
Dataset.data = sortrows(Dataset.data,1);

% Compute shares
Dataset.shares = Dataset.data.quantity/params.M;

% 
dummy_firm = dummyvar(Dataset.data.firm);
prod_char = [Dataset.data.weight Dataset.data.hp Dataset.data.AC];
Dataset.X = [ones(params.nb_cars,1) prod_char dummy_firm(:,2:end)];
Dataset = create_iv(Dataset, params);

%% Vertical Model (Question 1)
params.lambda = 4e-6;
params.model = 'vertical';
params.specification = 'demand';

% Define 
Dataset.Xd = Dataset.X;

% Estimate model
[est, Dataset] = vertical_model(Dataset, params);
result.vertical= est;

%% Question 2
% Elasticities
disp(result.vertical.demand.elasticities);


%% Question 3

Dataset.Xd = Dataset.X;
Dataset.Xs = [Dataset.X Dataset.data.quantity];


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
params.specification = 'demand';

Dataset.Xd = [Dataset.X -Dataset.data.price];
[est, Dataset] = logit_model(Dataset, params);

result.logit= est;

% Multiple

params.nb_init = 20;
params.theta_start = 1;
params.lower_bound = 0;
params.upper_bound = 50;
params.nK = size(params.theta_start,1);

params.specification = 'multiple';
Dataset.Xd = [Dataset.X];
Dataset.Xs = [Dataset.X Dataset.data.quantity];
[est, Dataset] = logit_model(Dataset, params);
result.logit.multiple = est;

%% BLP
params.model = 'BLP';
params.specification = 'demand';
params.nb_draws = 1000;
params.income_mean = 35000;
params.income_sd = 45000;

params.nb_init = 100;
params.theta_start = 22;
params.lower_bound = 0;
params.upper_bound = 50;
params.nK = size(params.theta_start,1);

% Draw income from lognormal
mu = log((params.income_mean^2)/sqrt(params.income_sd^2+params.income_mean^2));
sigma = sqrt(log(params.income_sd^2/(params.income_mean^2)+1));

Draws.income = lognrnd(mu,sigma,1,params.nb_draws);

%
Dataset.Xd = [Dataset.X -Dataset.data.price];

[est, Dataset] = blp_model(Dataset, params, Draws);
result.blp = est;

for i = 1:params.nb_init
    B(i,:)=est{i}.alpha; 
end
hist(B(:,1))
hist(B(:,2))

save output/result.mat
