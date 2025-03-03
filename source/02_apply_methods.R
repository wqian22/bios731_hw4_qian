### Function to fit a multiple linear regression model ###

fit_model = function(data){
  lm(y ~ x, data = data)
}
