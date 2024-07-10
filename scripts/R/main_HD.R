# new main functions for high D scenarios
# only a demo.
# need adjustments later for large scale simulations
# dir_list = list.dirs("/Users/siqili/Desktop/Duke-Nus/research/FLB/FL_Benchmarking/data_HD/simulated/", recursive = FALSE)
library("dplyr")
library("glmnet")
library("MASS")
library("grplasso")
source("D:/Code/FLBenchmark/R/statistics/helpers.R")
source("D:/Code/FLBenchmark/R/statistics/DAC.R") 
source("D:/Code/FLBenchmark/R/statistics/SHIR.R") 
source("D:/Code/FLBenchmark/R/Sim/sim_fun.R") 
source("D:/Code/FLBenchmark/R/train.local.R") 
source("D:/Code/FLBenchmark/R/centralized.R") 


dir_list = list.dirs("D:/Code/FLBenchmark/data_HD/simulated", recursive = FALSE)


#centralized lasso:
for(dir in dir_list){
  print(dir)
  do.central.all(dir, sparse = T)
}

#local lasso:
for(dir in dir_list){
  print(dir)
  do.local.all(dir, sparse = T)
}

#meta
for(dir in dir_list){
  print(dir)
  do.meta.all(dir, sparse = T)
}

#DAC:
for(dir in dir_list){
  print(dir)
  do_DAC(mainDir = dir)
}

# SHIR:
for(dir in dir_list){
  print(dir)
  do_SHIR(mainDir = dir)
}


