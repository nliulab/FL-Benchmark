library("dplyr")
library("glmnet")
library("MASS")
library("grplasso")
source("scripts/R/statistics/helpers.R")
source("scripts/R/train.local.R")
source("scripts/R/centralized.R")
source("scripts/R/statistics/Meta.R")
source("scripts/R/statistics/DAC.R") 
source("scripts/R/statistics/SHIR.R")

#Low Dim
Dir = "data/simulated"
dir_list = list.dirs(Dir, recursive = FALSE)

#local
for(dir in dir_list){
  print(dir)
  do.local.all(dir, sparse = F)
}


#central
for(dir in dir_list){
  print(dir)
  do.central.all(dir, sparse = F)
}

#meta
for(dir in dir_list){
  print(dir)
  do.meta.all(dir, sparse = F)
}

#---------------------------------------------------------------
#High dim
Dir = "data/simulated_HD"
dir_list = list.dirs(Dir, recursive = FALSE)



#local lasso:
for(dir in dir_list){
  print(dir)
  do.local.all(dir, sparse = T)
}

#centralized lasso:
for(dir in dir_list){
  print(dir)
  do.central.all(dir, sparse = T)
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


