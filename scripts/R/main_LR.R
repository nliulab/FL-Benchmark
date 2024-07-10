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

#dir_list = list.dirs("D:/Code/Backup-Simulated-7_Jun/data_LR/simulated", recursive = FALSE)

#large sim
Dir = "D:/nbox/FLB_simulated_large"
dir_list = list.dirs(Dir, recursive = FALSE)

#meta
for(dir in dir_list){
  print(dir)
  do.meta.all(dir, sparse = F)
}


#move result
Dir <- "D:/nbox/FLB_simulated_large"
Des <- "D:/Code/FL_new_sim_result"

move_data = function(folder,Dir,Des){
  seeds = list.dirs(folder,recursive = FALSE)
  for(seed in seeds){
    subfolder <- sub(paste0("^", Dir), "", seed)
    des = paste0(Des,subfolder)
    source_path = paste0(seed,"/Coef_meta.csv")
    des_path = paste0(des,"/Coef_meta.csv")
    file.copy(source_path, des_path, overwrite = TRUE)
  }
}
lapply(dir_list, move_data, Dir = Dir, Des = Des)