### Function to simulate data ###

get_simdata = function(n,          # sample size
                       beta_treat, # true average treatment effect
                       family      # error distribution = "normal" or "gamma"
                       ){
  beta0 = 1
  x = rbinom(n, 1, prob = 0.5)
  if (family == "normal") {
    epsilon = rnorm(n, 0, sqrt(2))
  } else if (family == "gamma"){
    epsilon = rgamma(n, shape = 1, rate = 2)
  }
  
  y = beta0 + beta_treat * x + epsilon

  tibble(
    x = x,
    y = y
  )

}



