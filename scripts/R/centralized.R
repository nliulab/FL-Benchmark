library(pROC)
library(tidyverse)
library(glmnet)
library(Matrix)
# functions to fit centralized model
source("scripts/R/statistics/helpers.R")

get.dat.c.single <- function(dir){
  dat.list = get.dat(dir)
  df = data.frame()
  N = 0
  for(i in seq_along(dat.list)){
    df = bind_rows(df, dat.list[[i]]$dat)
    N = N + dat.list[[i]]$n
  }
  return(df)
}

#-----------------Central---------------------------------------
get.central.1seed <- function(dir, sparse = F){
  df = get.dat.c.single(dir) %>% as.data.frame()
  setwd("../../../..")
  print(dir)
  if(sparse){
    x_train = df[,-1]
    coef1  = lasso.fun(x = as.matrix(x_train), y = as.vector(df$y), family = 'binomial')
    write.csv(coef1$coef %>% as.vector(), paste0(dir,"/Coef.central.lasso.csv"))
  }else{
    res = glm(y ~ ., data = df, family = 'binomial')
    coef = coef(res)
    write.csv(coef, paste0(dir,"/Coef_central.csv"))
  }
}


do.central.all <- function(mainDir, sparse = F){
  dir_list =list.dirs(mainDir, recursive = FALSE)
  for(dir in dir_list){
    get.central.1seed(dir, sparse)
  }
}
