# bios731_hw1_qian

## Project Directory

This project runs simulations for BIOS 731 Homework 1.


## Workflow

1. Run the file `simulations/run_simulations.R`. This file runs simulations for different scenarios.The code is parallelized. Sources the following files:
  * `source/01_simulate_data.R`: contains function used to simulate data
  * `source/02_apply_methods.R`: contains function for applying the method (linear regression)
  * `source/03_extract_estimates.R`: contains functions for performing nonparametric bootstrap and calculating the percentile and bootstrap t intervals
Running this file outputs the simulation results to the `results` folder.


2. Run the Rmarkdown file `analysis/HW1_report.Rmd`. This file will pull together the simulation results in `results` folder and generated some tables and plots.
