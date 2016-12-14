# Bayesian-MCMC-Regressions
R, Python, and Matlab templates to estimate Bayesian regression models using Marko Chain Monte Carlo sampling.

This repository includes template scripts in various languages (R, Matlab, Python) that can be used to define, modify, estimate, and visualize Bayesian regression (linear or logistic) models. 

The R and Matlab templates rely on JAGS (http://mcmc-jags.sourceforge.net/) through the R2jags (https://cran.r-project.org/web/packages/R2jags/index.html) and MATJAGS (http://psiexp.ss.uci.edu/research/programs_data/jags/) libraries, respectively.

The upcoming Python template will rely on the Python module bambi found here (https://github.com/bambinos/bambi).

The templates are based on linear and logistic regression models based on experimental data on social decision making collected by Giovanni Gentile in collaboration with Antonio Rangel at the California Institute of Technology.

Please contact the author (gentile.giovanni@gmail.com, ggentile@caltech.edu) for details on the experimental paradigms or if interested in receiving a copy of the dataset (the dataset and more analysis code will be uploaded in a separate repository soon).

The template scripts can be easily modified to operate on different datasets, different sets of predictor variables, and different model specifications (likelihood functions, prior distributions etc.)



