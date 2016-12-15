%% Template script
%% Estimate Bayesian hierarchical logistic regression model using MCMC sampling

close all; clc;

%% Load dataset
data = csvread('MY_DATASET');

% Specify input data to JAGS model(s)
% Note: this template assumes your dataset is already in good shape
% For this template, let's assume you want to fit a logistic regression with:
% y: a binary outcome variable (for example, a binary choice)
% alpha: the intercept
% X: x1, x2, and x3, three predictor variables (easy to scale)

y  = data(:, OUTCOME_VARIABLE_COLUMN);
x1 = data(:, PREDICTOR_VARIABLE_1_COLUMN);
x2 = data(:, PREDICTOR_VARIABLE_2_COLUMN);
x3 = data(:, PREDICTOR_VARIABLE_3_COLUMN);

% Number of observations
Nobs = max(size(data));

% Subject ID variables (to define hierarchical model structure)
subjID = data(:, SUBJECT_ID_VARIABLE_COLUMN);
Nsubj  = max(subjID);

% Combine input data
input_data = struct('y', y, 'Nobs', Nobs, 'Nsubj', Nsubj, 'x1', x1, 'x2', x2, 'x3', x3);

%% Specify JAGS MCMC parameters
nchains  = 4;       % How Many Chains?
nburnin  = 250000;  % How Many Burn-in Samples?
nsamples = 50000;   % How Many Recorded Samples?
nthin    = 5;       % How Much to Thin by?

%% Initialize MCMC chains (same for both conditions)
% Here you initialize the population (or group) level parameters
% For the logistic regression example, we will estimate both the
% mean and the precision of the model coefficients.

% Note: for simplicity, all the initial values here are the same across chains (change!)
for i = 1 : nchains
    % Population-level intercept
    S.alphagmean = 0;
    S.alphagprec = 0.001;
    % Population-level beta means
    S.beta1gmean = 0;
    S.beta2gmean = 0;
    S.beta3gmean = 0;
    % Population-level beta precisions
    S.beta1gprec = 0.001;
    S.beta2gprec = 0.002;
    S.beta3gpreg = 0.001;
    init0(i) = S; 
end

%% Specify text file with model specification
model_name = 'bayesian_logistic_regression_model.txt';

%% Specify which model parameters to store
model_params = {'alphagmean', 'beta1gmean', 'beta2gmean', 'beta3gmean', 'alphagprec', 'beta1gprec', 'beta2gprec', 'beta3gprec', 'alpha', 'beta1', 'beta2', 'beta3'};

%% Parallel computing settings
doparallel = 1;

if doparallel
   if isempty(gcp('nocreate'))
      pool = parpool(4);
   end
end

%% Fit model and store samples
[samples, stats, structArray] = matjags( ...
input_data, ...                     % Observed data
fullfile(pwd, model_name), ...      % File that contains model definition
init0, ...                          % Initial values for model variables
'doparallel' , doparallel, ...      % Parallelization flag
'nchains', nchains,...              % Number of MCMC chains
'nburnin', nburnin,...              % Number of burnin steps
'nsamples', nsamples, ...           % Number of samples to extract
'thin', nthin, ...                  % Thinning parameter
'monitorparams', model_params, ...  % List of model coefficients to monitor
'savejagsoutput' , 0 , ...          % Save command line output produced by JAGS?
'verbosity' , 2 , ...               % 0=do not produce any output; 1=minimal text output; 2=maximum text output
'cleanup' , 1);

%% Basic visualization: posterior distributions from MCMC samples
% Note: will be adding more advanced visualization soon
figure;
subplot(2,4,1), hist(samples.alphagmean(:), 100), title('Mean Intercept')
subplot(2,4,2), hist(samples.beta1gmean(:), 100), title('Mean Beta1: x1')
subplot(2,4,3), hist(samples.beta2gmean(:), 100), title('Mean Beta2: x2')
subplot(2,4,4), hist(samples.beta3gmean(:), 100), title('Mean Beta3: x3')
subplot(2,4,5), hist(samples.alphagprec(:), 100), title('Prec Intercept')
subplot(2,4,6), hist(samples.beta1gprec(:), 100), title('Prec Beta1: x1')
subplot(2,4,7), hist(samples.beta2gprec(:), 100), title('Prec Beta2: x2')
subplot(2,4,8), hist(samples.beta3gprec(:), 100), title('Prec Beta3: x3')
