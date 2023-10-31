library(tidyverse)
library(glmnet)

get.local.1file <- function(csv_name, sparse){
  df = read.csv(csv_name) %>% as.data.frame()
  if(sparse){
    x_train = subset(df, select = -y)
    coef1  = lasso.fun.0(x = as.matrix(x_train), y = as.vector(df$y), family = 'binomial')
    coef2 = lasso.fun.0(x = as.matrix(x_train), y = as.vector(df$y), family = 'binomial', alpha = 0)
    write.csv(coef1 %>% as.vector(), sprintf("Coef.lasso.local.Site%d.csv", get_siteindex(csv_name)))
    write.csv(coef2 %>% as.vector(), sprintf("Coef.ridge.local.Site%d.csv", get_siteindex(csv_name)))
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
  }
}

get_siteindex <- function(csv_name){
  return(as.integer(gsub("[^0-9]+", "", str_extract(csv_name, "Site[0-9]+"))))
}

Dir = "data/simulated"
dir_list = list.dirs(Dir, recursive = FALSE)

lapply(dir_list,do.local.all)
