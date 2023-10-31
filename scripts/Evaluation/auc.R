rm(list = ls())
library(pROC)
library(stringr)
library(dplyr)
library(jsonlite)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
source("helpers.r")

Dir = "../../data/simulated"
dir_list = list.dirs(Dir, recursive = FALSE)

eval.auc <- function(y, X, coef){
  X = data.frame(do.call("cbind", X))
  X = cbind(1,X)
  coef = rbind(0, coef)
  coef <- as.data.frame(apply(coef, 2, as.numeric)) 
  pred = g.logit(as.matrix(X) %*% as.matrix(coef))
  auc_all = list()
  for(i in 1:dim(pred)[2]){
    roc = roc(y, as.vector(pred[,i]))
    auc_val = auc(roc)
    auc <- as.numeric(str_extract(auc_val, "\\d+\\.?\\d*"))
    auc_all[[names(coef)[i]]] = auc
  }
  return(as.data.frame(auc_all))
}

eval.auc.1seed <- function(dir){
  dat.list = get.dat.test(dir)
  K = get_K(dir)
  res = list()
  for(i in 1:length(dat.list)){
    dat = dat.list[[i]]$dat
    coef = get_coef(dir)
    coef = coef[,-1]
    result = eval.auc(dat$y, dat[, -which(names(dat) == "y")], coef)
    result$Site_index = i
    res = rbind(res,result)
  }
  write.csv(res, file.path(dir,"auc.csv"), row.names = F)
}

eval.auc.allseed <- function(Dir){
  dir_list =list.dirs(Dir, recursive = FALSE)
  for(dir in dir_list){
    print(dir)
    eval.auc.1seed(dir)
  }
}

g.logit=function(x) exp(x)/(1+exp(x))
logit=function(x) log(x/(1-x))


eval.auc.allseed(dir_list[1])
