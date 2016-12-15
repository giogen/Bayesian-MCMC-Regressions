rm(list = ls())

# Load necessary libraries
library(R2jags) # Interface with JAGS (fit models using MCMC Gibbs sampling)
library(lme4)   # For comparison purposes (mixed-effects regression models)
library(dplyr)  # Data wrangling

# For reproducibility purposes
seed <- 123
set.seed(seed)

#################################################################################
# Load dataset
setwd("MY_WORKING_DIRECTORY") 
data <- read.csv("MY_DATASET.csv")
#################################################################################

#################################################################################
# Specify input data to JAGS model(s)
# Note: this template assumes your dataset is already in good shape
# For this template, let's assume you want to fit a logistic regression with:
# y: a binary outcome variable (for example, a binary choice)
# alpha: the intercept
# X: x1, x2, and x3, three predictor variables (easy to scale)

y  <- data %>% select(MY_OUTCOME_VARIABLE)
x1 <- data %>% select(MY_PREDICTOR_VARIABLE_1)
x2 <- data %>% select(MY_PREDICTOR_VARIABLE_2)
x3 <- data %>% select(MY_PREDICTOR_VARIABLE_3)

# Number of observations
Nobs <- length(y)

# Subject ID variables (to define hierarchical model structure
subjID <- data %>% select(MY_SUBJECT_ID_VARIABLE)
Nsubj  <- max(subjID)

# Combine input data
model.data <- c("y", "x1", "x2", "x3", "Nobs", "Nsubj", "subjID")
#################################################################################

#################################################################################
# Specify JAGS parameters
n.chains <- 4        # Number of chains
n.iter   <- 250000   # Number of samples
n.burnin <- 50000    # Number of burn-in samples
n.thin   <- 5        # Thinning parameter
#################################################################################

#################################################################################
# Initialize MCMC chains (same for both conditions)
# Here you initialize the population (or group) level parameters
# For the logistic regression example, we will estimate both the
# mean and the precision of the model coefficients.

# Note: for simplicity, all the initial values here are the same across chains (change!)

inits1 <- list("alphagmean"=0, "alphagprec"=0.001, "beta1gmean"=0, "beta2gmean"=0, "beta3gmean"=0, "beta1gprec"=0.001, "beta2gprec"=0.001, "beta3gprec"=0.001)
inits2 <- list("alphagmean"=0, "alphagprec"=0.001, "beta1gmean"=0, "beta2gmean"=0, "beta3gmean"=0, "beta1gprec"=0.001, "beta2gprec"=0.001, "beta3gprec"=0.001)
inits3 <- list("alphagmean"=0, "alphagprec"=0.001, "beta1gmean"=0, "beta2gmean"=0, "beta3gmean"=0, "beta1gprec"=0.001, "beta2gprec"=0.001, "beta3gprec"=0.001)
inits4 <- list("alphagmean"=0, "alphagprec"=0.001, "beta1gmean"=0, "beta2gmean"=0, "beta3gmean"=0, "beta1gprec"=0.001, "beta2gprec"=0.001, "beta3gprec"=0.001)

model.inits <- list(inits1, inits2, inits3, inits4)
#################################################################################

#################################################################################
# Specify which parameters to monitor and store
model.params <- c("beta1gmean", "beta2gmean", "beta3gmean", "beta1gprec", "beta2gprec", "beta3gprec", "beta1", "beta2", "beta3")
#################################################################################

#################################################################################
# Model specification
# Note: you can also specify the model in a separate text file (see files in repository)
logistic.regression.model <- function() {
  
  # Model observations
  for (obs in 1:Nobs) {
    
    # Binary choice data (accept = 1 / reject = 0) ~ Bernoulli
    y[obs] ~ dbern(prob[obs])
    
    # Logistic regression model
    logit(prob[obs]) <- alpha[subjID[obs]] + beta1[subjID[obs]]*x1[obs] + beta2[subjID[obs]]*x2[obs] + beta3[subjID[obs]]*x3[obs]
    
  }
  
  # Specify prior for lower-level parameters (individual subjects)
  for (subj in 1:Nsubj.other) {
    
    alpha[subj] ~ dnorm(alphagmean, alphagprec)
    beta1[subj] ~ dnorm(beta1gmean, beta1gprec)
    beta2[subj] ~ dnorm(beta2gmean, beta2gprec)
    beta3[subj] ~ dnorm(beta3gmean, beta3gprec)

  }
  
  # Specify hierarchical priors (population-level parameters)
  # Means
  alphagmean ~ dnorm(0, 0.001)
  beta1gmean ~ dnorm(0, 0.001)
  beta2gmean ~ dnorm(0, 0.001)
  beta3gmean ~ dnorm(0, 0.001)
  # Precisions
  alphagprec ~ dgamma(.1, .1)
  beta1gprec ~ dgamma(.1, .1)
  beta2gprec ~ dgamma(.1, .1)
  beta3gprec ~ dgamma(.1, .1)
  
}
#################################################################################

#################################################################################
# Fit model: run JAGS and update until convergence
model.fit  <- jags(data = model.data, inits = model.inits, parameters.to.save = model.params,
                   n.chains = n.chains, n.iter = n.iter, n.burnin = n.burnin, n.thin = n.thin,
                   model.file = logistic.regression.model, jags.seed = seed)

n.iter.upd <- 100000
n.thin.upd <- 10
Rhat       <- 1.10
n.update   <- 2
model.fit.upd  <- autojags(model.fit,  n.iter = n.iter.upd, n.thin = n.thin.upd, Rhat = Rhat, n.update = n.update, progress.bar = "text")
#################################################################################

# Print summary of model fits
summary(model.fit)
summary(model.fit.upd)
  
# COMING SOON: VISUALIZATION OF MODEL FITTING RESULTS