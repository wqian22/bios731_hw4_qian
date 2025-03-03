### Function to perform a nonparametric bootstrap, extract standard error and percentile interval coverage###

do_bootstrap <- function(data,         # original sample
                         beta_true,    # true average treatment effect
                         beta_hat,     # estimated average treatment effect
                         nboot = 1000, # number of bootstrap samples
                         alpha = 0.05  # significance threshold
                         ){
  tic()
  n <- nrow(data)
  beta_star <- numeric(nboot)

  for(b in 1:nboot){
    # nonparametric bootstrap
    boot_indices <- sample(1:n, size = n, replace = TRUE)
    boot_sample <- data[boot_indices, ]
    boot_model <- fit_model(boot_sample)
    beta_star[b] <- coef(boot_model)[2]
  }
  
  # percentile interval and coverage
  percent_ci <- quantile(beta_star, probs = c(alpha/2, 1-(alpha/2)), na.rm = TRUE)
  percent_coverage <- ifelse(beta_true >= percent_ci[1] & beta_true <= percent_ci[2], 1, 0)
  
  # bootstrap estimate of standard error
  se_star <- sd(beta_star, na.rm = TRUE)
  
  time_stamp <- toc(quiet = TRUE)
  time_percentile <-  time_stamp$toc - time_stamp$tic

  return(list(se_star, percent_coverage, time_percentile))
}

