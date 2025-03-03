library(broom)
library(here)
library(tictoc)
library(tidyverse)

wd = getwd()

if(substring(wd, 2, 6) == "Users"){
  doLocal = TRUE
}else{
  doLocal = FALSE
}

###############################################################
## define or source functions used in code below
###############################################################

source(here("source", "01_simulate_data.R"))
source(here("source", "02_apply_methods.R"))
source(here("source", "03_extract_estimates.R"))

###############################################################
## set simulation design elements
###############################################################

nsim = 475
n = c(20)
beta_true = c(0, 0.5)
family = c("normal", "gamma")

params = expand.grid(n = n,
                     beta_true = beta_true,
                     family = family)

###############################################################
## start simulation code
###############################################################

# define number of simulations and parameter scenarios
if(doLocal) {
  scenario = 1
  nsim = 2
}else{
  # defined from batch script params
  scenario <- as.numeric(commandArgs(trailingOnly=TRUE))
}

# define simulation scenario
param <- params[scenario, ]

# generate a random seed for each simulated dataset
seed <- floor(runif(nsim, 1, 900))
results = vector("list", length = nsim)

# use parallel computing for the simulations
for(i in 1:nsim){

  set.seed(seed[i])
  
  ####################
  # simulate data
  simdata <- get_simdata(n = param$n,
                         beta_treat = param$beta_true,
                         family = param$family)
  
  ####################
  # apply method
  fit <- fit_model(simdata)
  
  ####################
  # get beta_hat, bias, Wald standard error, coverage, computation time
  tic()
  wald_res <- tidy(fit, conf.int = TRUE) %>%
    filter(term == "x") %>%
    mutate(bias = estimate - param$beta_true,
           coverage_wald = ifelse(param$beta_true >= conf.low & param$beta_true <= conf.high, 1, 0)) %>%
    rename(beta_hat = estimate, se_wald = std.error) %>%
    select(beta_hat, bias, se_wald, coverage_wald)
  time_stamp <- toc(quiet = TRUE)
  time_wald <- time_stamp$toc - time_stamp$tic
  
  # get bootstrap standard error, coverage, computation time
  boot_res <- do_bootstrap(simdata, beta_true = param$beta_true, beta_hat = wald_res$beta_hat)
  
  ####################
  # store results
  res <- data.frame(param,
                    seed = seed[i],
                    wald_res,
                    se_boot = boot_res[[1]],
                    coverage_percentile = boot_res[[2]],
                    time_wald,
                    time_percentile = boot_res[[3]])
  
  results[[i]] <- res
}

results_df <- bind_rows(results)

####################
# save results
filename <- paste0("scenario_", scenario, ".RDA")
save(results_df, file = here("results", filename))

