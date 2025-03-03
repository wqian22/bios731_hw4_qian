# bios731_hw3_qian

## Project Directory

This project runs simulations for BIOS 731 Homework 3.


## Workflow

1. Clone this repository to your project folder on cluster.

```bash
cd project_folder
git clone https://github.com/wqian22/bios731_hw3_qian.git
```
2. Change directory to the `simulations` folder and run the script `run_simulations_hpc.sh`.

```bash
cd bios731_hw3_qian/simulations
sbatch run_simulations_hpc.sh
```

Running batch jobs outputs the simulation results to the `results` folder. You can transfer the simulation results from cluster to local using scp. 

3. Run the Rmarkdown file `analysis/HW3_report.Rmd`. This file will pull together the simulation results in `results` folder and generated some plots.
