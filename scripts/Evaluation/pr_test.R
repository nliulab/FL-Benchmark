# evaluate model performance based on AUC values
rm(list = ls())
library(pROC)
library(stringr)
library(dplyr)
library(jsonlite)
library(PRROC) 
library(igraph)

source("helpers.r")

set.seed(123)

get.pred <- function(y, X, coef){
  X = data.frame(do.call("cbind", X))
  X = cbind(1,X)
  coef = rbind(0, coef)
  coef <- as.data.frame(apply(coef, 2, as.numeric)) 
  pred = g.logit(as.matrix(X) %*% as.matrix(coef))
  return(pred)
}

get.pred.1seed <- function(dir){
  dat.list = get.dat.test(dir)
  K = get_K(dir)
  res = list()
  for(i in 1:length(dat.list)){
    dat = dat.list[[i]]$dat
    coef = get_coef(dir,p=8, sparse = F, method = c("Central","Local","Meta","GLORE","fedavg","fedprox"))
    #coef = get_coef(dir,p=100, sparse = T, method = c("Central","Local","Meta","DAC","SHIR","fedavg","fedprox")) #high dim
    result = get.pred(dat$label, dat[, -which(names(dat) == "y")], coef)
    result = as.data.frame(result)
    result$Site_index = i
    result$y = dat$y
    res[[i]] = result
  }
  return(res)
}

g.logit=function(x) exp(x)/(1+exp(x))
logit=function(x) log(x/(1-x))



#-----------------------------------------------------------------
roc_res <- function(dat){
  K <- length(dat)
  res_all <- data.frame()
  for(i in 1:K){
    df <- dat[[i]]
    cols_to_remove <- c("Site_index", "y","Central")
    predicted_columns <- df[, !names(df) %in% cols_to_remove]
    roc_test <- function(var){
      # roc1  Central
      roc1 <- roc(df$y, df[,1], verbose = FALSE)
      roc2 <- roc(df$y, df[[var]], verbose = FALSE)
      roc_test <- roc.test(roc1, roc2, alternative = "less", method = "delong")
      p.value <- roc_test$p.value
      z <- roc_test$statistic
      return(c(p.value, z))
    }
    
    vars = colnames(predicted_columns)
    roc_p <- lapply(vars, roc_test)
    roc_p_df <- do.call(rbind, roc_p)
    colnames(roc_p_df) <- c("p.value", "z")
    
    final <- cbind(vars, roc_p_df)
    final <- as.data.frame(final)
    #p<0.05, V2 better than V1
    final$V2_better = ifelse(final$p.value < 0.05,T,F)
    final$site = i
    res_all <- rbind(res_all, final)
  }
  return(res_all)
}

calc_auprc <- function(actual, predicted) {
  pr <- pr.curve(scores.class0 = predicted[actual == 1], scores.class1 = predicted[actual == 0], curve = TRUE)
  return(pr$auc.integral)
}

calc_seed_auprc <- function(dat){
  K <- length(dat)
  auprc_res <- data.frame(Model = character(), AUPRC = numeric(), Site = integer(), stringsAsFactors = FALSE)
  for(i in 1:K){
    df = dat[[i]]
    actual <- df$y
    cols_to_remove <- c("Site_index", "y")
    predicted_columns <- df[, !names(df) %in% cols_to_remove]
    auprc_values <- lapply(predicted_columns, function(col) calc_auprc(actual, col))
    auprc_df <- data.frame(Model = names(auprc_values), AUPRC = unlist(auprc_values))
    auprc_df$Site <- i
    auprc_res <- rbind(auprc_res,auprc_df)
  }
  return(auprc_res)
}


#------------------------------------------------------------------
Dir = "../../data/simulated"
dir_list = list.dirs(Dir, recursive = FALSE)


roc.1seed <- function(dir){
  pred_res = get.pred.1seed(dir)
  result = roc_res(pred_res)
  write.csv(result,file.path(dir, "roc_res.csv"), row.names = FALSE)
  seed_auprc = calc_seed_auprc(pred_res)
  write.csv(seed_auprc,file.path(dir,"auprc_res.csv"), row.names = FALSE)
}


roc.all <- function(mainDir){
  dir_list =list.dirs(mainDir, recursive = FALSE)
  for(dir in dir_list){
    print(dir)
    roc.1seed(dir)
  }
}

for(dir in dir_list){
  print(dir)
  roc.all(dir)
}

