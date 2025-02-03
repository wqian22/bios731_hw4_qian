library(broom)
library(doParallel)
library(foreach)
library(here)
library(tictoc)
library(tidyverse)

###############################################################
## define or source functions used in code below
###############################################################

source(here("source", "01_simulate_data.R"))
source(here("source", "02_apply_methods.R"))
source(here("source", "03_extract_estimates.R"))

###############################################################
## set simulation design elements
###############################################################

nsim = 10
n = c(10, 50, 500)
beta_true = c(0, 0.5, 2)
family = c("normal", "lognormal")

params = expand.grid(n = n,
                     beta_true = beta_true,
                     family = family)

# define the number of cores
num_cores <- detectCores() - 1
cl <- makeCluster(num_cores)
registerDoParallel(cl)

###############################################################
## start simulation code
###############################################################

for (scenario in c(10)) {
#for (scenario in 1:nrow(params)) {
  
  # define simulation scenario
  param <- params[scenario, ]

  # generate a random seed for each simulated dataset
  seed <- floor(runif(nsim, 1, 900))
  
  # use parallel computing for the simulations
  results <- foreach(i = 1:nsim, .combine = 'rbind', .packages = c("tidyverse", "broom", "tictoc", "here")) %dopar% {
    
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
                      coverage_t = boot_res[[3]],
                      time_wald,
                      time_percentile = boot_res[[4]],
                      time_t = boot_res[[5]])
    
    return(res)  # each iteration returns a dataframe
  }
  
  ####################
  # save results
  filename <- paste0("scenario_", scenario, ".RDA")
  save(results, file = here("results", filename))
}

# stop the parallel cluster
stopCluster(cl)
