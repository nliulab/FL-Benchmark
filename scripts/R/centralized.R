library(pROC)
library(tidyverse)
library(glmnet)
# functions to fit centralized model
setwd(dirname(rstudioapi::getSourceEditorContext()$path))
source("statistics/helpers.r")

get.dat.c.single <- function(dir){
  setwd(dir)
  dat.list = get.dat(dir)
  df = data.frame()
  N = 0
  for(i in seq_along(dat.list)){
    df = bind_rows(df, dat.list[[i]]$dat)
    N = N + dat.list[[i]]$n
  }
  return(df)
}


get.central.1seed <- function(dir){
  setwd(dir)
  df = get.dat.c.single(dir) %>% as.data.frame()
  res = glm(y ~ ., data = df, family = 'binomial')
  coef = coef(res)
  write.csv(coef, "Coef_central.csv")
}

get.local.1seed <- function(dir, sparse=F){
  df = get.dat.c.single(dir)
  for(i in seq_along(dat.list)){

  }
}

do.central.all <- function(mainDir){
  dir_list =list.dirs(mainDir, recursive = FALSE)
  for(dir in dir_list){
    get.central.1seed(dir)
  }
}

dir = "..."
do.central.all(dir)

Dir = "data/simulated"
dir_list = list.dirs(Dir, recursive = FALSE)
lapply(dir_list, do.central.all)
