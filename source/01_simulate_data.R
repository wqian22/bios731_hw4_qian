get_simdata = function(n, beta_treat, family){
  beta0 = 1
  x = rbinom(n, 1, prob = 0.5)
  if (family == "normal") {
    epsilon = rnorm(n, 0, sqrt(2))
  } else if (family == "lognormal"){
    epsilon = rlnorm(n, 0, sqrt(2))
  }
  
  y = beta0 + beta_treat * x + epsilon

  tibble(
    x = x,
    y = y
  )

}



