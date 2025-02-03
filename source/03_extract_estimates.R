# perform nonparametric bootstrap
do_bootstrap <- function(data, beta_true, beta_hat, nboot = 1000, nboot_t = 500, alpha = 0.05){
  tic()
  n <- nrow(data)
  beta_star <- numeric(nboot)
  t_star <- numeric(nboot)
  time_innerloop <- numeric(nboot)

  for(b in 1:nboot){
    # nonparametric bootstrap
    boot_indices <- sample(1:n, size = n, replace = TRUE)
    boot_sample <- data[boot_indices, ]
    boot_model <- fit_model(boot_sample)
    beta_star[b] <- coef(boot_model)[2]

    tic()
    beta_star_b = numeric(nboot_t)
    for(k in 1:nboot_t){
      boot_indices_b <- sample(1:n, size = n, replace = TRUE)
      boot_sample_b <- boot_sample[boot_indices_b, ]
      boot_model_b <- fit_model(boot_sample_b)
      beta_star_b[k] <- coef(boot_model_b)[2]
    }
    
    # calculate t_star
    se_star_b <- sd(beta_star_b, na.rm = TRUE)
    t_star[b] <- (beta_star[b] - beta_hat) / se_star_b
    
    time_stamp <- toc(quiet = TRUE)
    time_innerloop[b] <- time_stamp$toc - time_stamp$tic
  }
  
  # percentile interval
  percent_ci <- quantile(beta_star, probs = c(alpha/2, 1-(alpha/2)), na.rm = TRUE)
  percent_coverage <- ifelse(beta_true >= percent_ci[1] & beta_true <= percent_ci[2], 1, 0)
  
  # bootstrap t interval
  t_quants <- quantile(t_star, probs = c(alpha/2, 1-(alpha/2)), na.rm = TRUE)
  se_star <- sd(beta_star, na.rm = TRUE)
  t_ci_lower <- beta_hat - t_quants[2] * se_star
  t_ci_upper <- beta_hat - t_quants[1] * se_star
  t_coverage <- ifelse(beta_true >= t_ci_lower & beta_true <= t_ci_upper, 1, 0)
  
  time_stamp <- toc(quiet = TRUE)
  time_t <- time_stamp$toc - time_stamp$tic
  time_percentile <- time_t - sum(time_innerloop)

  return(list(se_star, percent_coverage, t_coverage, time_percentile, time_t))
}

