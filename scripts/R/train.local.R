library(tidyverse)
library(glmnet)
source("scripts/R/statistics/helpers.R")

get.local.1file <- function(csv_name, sparse){
  df = read.csv(csv_name) %>% as.data.frame()
  if(sparse){
    x_train = subset(df, select = -y)
    coef1  = lasso.fun(x = as.matrix(x_train), y = as.vector(df$y), family = 'binomial')
    write.csv(coef1$coef %>% as.vector(), sprintf("Coef.lasso.local.Site%d.csv", get_siteindex(csv_name)))
  }
  else{
    res = glm(y ~ ., data = df, family = 'binomial')
    coef = coef(res)
    name = sprintf("Coef.local.Site%d.csv", get_siteindex(csv_name))
    write.csv(coef, name)
  }
}

get.local.1seed <- function(dir, sparse){
  setwd(dir)
  file_names <- list.files(full.names = TRUE, pattern = "^Site[0-9]+.test.*")
  for(csv_name in file_names){
    get.local.1file(csv_name, sparse)
  }
}

do.local.all <- function(mainDir, sparse = F){
  dir_list =list.dirs(mainDir, recursive = FALSE)
  for(dir in dir_list){
    get.local.1seed(dir, sparse)
    setwd("../../../..")
  }
}

get_siteindex <- function(csv_name){
  return(as.integer(gsub("[^0-9]+", "", str_extract(csv_name, "Site[0-9]+"))))
}
