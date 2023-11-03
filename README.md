# Federated Learning for Clinical Structured Data: A Benchmark Comparison of Engineering and Statistical Approaches

- [Introduction](#introduction)
- [System requirements](#system-requirements)
- [A demo for generating and analyzing simulated data](#a-demo-for-generating-and-analyzing-simulated-data)
  - [Step I. Generate simulated data](#step-i-generate-simulated-data)
  - [Step II. Generate local and central models](#step-ii-generate-local-and-central-models)
  - [Step III. Generate FL models](#step-iii-generate-fl-models)
    - [(1). GLORE](#1-glore)
    - [(2). FLower (FedAvg, q-FedAvg \& FedAvgM)](#2-flower-fedavg-q-fedavg--fedavgm)
    - [(3). FedProx](#3-fedprox)
  - [Step IV. Result analysis](#step-iv-result-analysis)

Python and R workflow for generating and analyzing simulated datasets for benchmark comparisons of engineering-based FL algorithms ([FedAvg](https://arxiv.org/abs/1602.05629), [FedAvgM](https://arxiv.org/abs/1909.06335), [q-FedAvg](https://arxiv.org/abs/1905.10497) and [FedProx](https://arxiv.org/abs/1812.06127)) and the statistics-based FL algorithm ([GLORE](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3422844/)). 
<!--See our new [Preprint](https://arxiv.org/abs/2303.00282) for the whole story.-->

This repository contains code that references [FedProx](https://github.com/litian96/FedProx) and [GLORE](https://github.com/x1jiang/glore).

## Introduction

Federated Learning (FL) has shown promising potential for safeguarding data privacy in healthcare collaborations. Although the term “FL” was originally coined by engineers,  the statistical community has also explored similar privacy-preserving algorithms. Statistical FL algorithms, however, remain considerably less recognized than their engineering counterparts. Our goal was to bridge the gap by presenting the first comprehensive comparison of FL frameworks from both engineering and statistical domains. We evaluated five FL frameworks using both simulated and real-world data. The results indicate that statistical FL algorithms yield less biased point estimates for model coefficients and offer convenient confidence interval estimations. In contrast, engineering-based methods tend to generate more accurate predictions, sometimes surpassing central pooled and statistical FL models. This study underscores the relative strengths and weaknesses of both types of methods, emphasizing the need for increased awareness and their integration in future FL applications. 

## System requirements
- **R packages**: 'cowplot', 'dplyr', 'ggplot2', 'grid', 'gridExtra', 'pROC', 'rstudioapi', 'stringr'.
- **Java**: version 8 or higher.
- **Python**: version 3.9 (macOS) or 3.7 (Windows).
  
  To install the required Python packages, run: ```pip install -r requirements.txt``` (use `requirements_win.txt` for Windows).

**Extra notes for using TensorFlow-** The current version is for macOS. For Windows users, when importing Tensorflow, replace current lines with `import tensorflow as tf`.

## A demo for generating and analyzing simulated data

In this section, we will walk through a demonstration of generating and analyzing simulated data using three clients (site 1, site 2, and site 3). 

### Step I. Generate simulated data

Run script `scripts/R/Sim/main.R` to generate 50 seeds of simuulation, with the output saved in the `data/simulated` directory.

### Step II. Generate local and central models

- Run script `scripts/R/train.local.R` to produce local results.
- Run script `scripts/R/centralized.R` to produce global results.

### Step III. Generate FL models

#### (1). GLORE
- Run following commands to compile `Server.java` and `Client.java`.
```
cd scripts/GLORE
javac -cp Jama-1.0.2.jar Server.java Client.java
```
- Run script `run_glore.py` (macOS) or `run_glore_win.py` (Windows) to start the server and clients, with output file `output_glore.txt` stored in each seed folder.
```
python run_glore.py [path]
```
For example:
```
python run_glore.py ../../data/simulated/homogenous
```
- Run script `scripts/data_LR/extract_glore_all.py` to extract model coefficients and total training time for all datasets and seeds, with output file `Coef_glore.csv` and `Cov_glore.csv` stored in each seed folder.
```
cd scripts/data_LR
python extract_glore_all.py ../../data/simulated
```

#### (2). FLower (FedAvg, q-FedAvg & FedAvgM)
- Change strategies in `scripts/Flower/FL_run_win.py` (Windows) or `scripts/Flower/FL_run.py` (macOS) for different FL methods:
  - Strategy 1: FedAvg
  - Strategy 2: q-FedAvg
  - Strategy 3: FedAvgM
- Run script ```python3 scripts/Flower/run_flwr_all_win.py [path]``` for Windows and ```python3 scripts/Flower/run_flwr_all.py [path]``` for macOS, with output file `output_flwr_fedavg.txt` stored in each seed folder.
- Run script ```python3 scripts/data_LR/extract_flower_fedavg.py [path] ``` to extract coefficients and communication cost. The same for `scripts/data_LR/extract_flower_fedavgM.py` and `scripts/data_LR/extract_flower_Qfedavg.py`.
For example:
```
python scripts/data_LR/extract_flower_fedavg.py data/simulated/homogenous
```

#### (3). FedProx
- Convert training and testing data to json format and copy them to the correct FedProx input data folder.
```
cd scripts/data_LR
python convert_data_to_json.py
python move_data.py ../../data/simulated/[path]
```
- Run script `scripts/FedProx/fedprox.py`, with output files like `fedprox_lr0.01_drop0_mu0` stored in each seed folder.
```
cd scripts/FedProx
python fedprox.py [path]
```
- Run script ```python3 extract_fedprox.py [output path]``` to extract model coefficients and communication time,  with output files stored in each seed folder.

### Step IV. Result analysis
- AUC of prediction task
  - Run script `scripts/Evaluation/auc.R` to calculate AUC score for all methods, with results stored in `scripts/Evaluation/AUC`.
  - Run script `scripts/Evaluation/auc_eval.R` to draw violin plots for AUC values, with results stored in `scripts/Evaluation/AUC`.
  ![AUC Plot](scripts/Evaluation/AUC/homogenous_auc_plot.png)
- Coefficient estimate
  - Run script `scripts/Evaluation/coef_eval.R` to extract coefficients of all methods, with result stored in `scripts/Evaluation/Coef`.
  - Run script `scripts/Evaluation/coef_eval.R` to draw violin plots for estimated coefficients, with results stored in `scripts/Evaluation/Coef`.
![Coefficient Plot](scripts/Evaluation/Coef/homogenous_coef_plot.png)

- Communication

Run script `scripts/Evaluation/extract_time.R` to extract communications for GLORE. 

The average round result will be generated at `scripts/Evaluation/time_rounds`.


## Citation

xxx

## Contact

- Siqi Li (Email: <siqili@u.duke.nus.edu>)
- Nan Liu (Email: <liu.nan@duke-nus.edu.sg>)
