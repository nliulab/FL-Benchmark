get.dat <- function(dir){
  setwd(dir)
  file_list <- list.files(path = dir, pattern = "^Site[0-9]+.train.*")
  K = get_K(dir)
  dat.list <- vector("list", K)
  i = 0
  for (file_name in file_list) {
    i = i+1
    dat.list[[i]]$dat = read.csv(file_name)
    dat.list[[i]]$n = get_n(file_name)
  }
  return(dat.list)
}

get.dat.DAC <- function(dir){
  file_list <- list.files(path = dir, pattern = "^Site[0-9]+.train.*")
  K = get_K(dir)
  dat.list <- vector("list", K)
  i = 0
  for (file_name in file_list) {
    i = i+1
    dat_temp = read.csv(file_name) %>% as.matrix()
    # print(dat_temp)
    # print(typeof(dat_temp))
    # print(str(dat_temp))
    dat.list[[i]] = dat_temp
  }
  return(dat.list)
}

get_largest_site <- function(dat.list){
  nmax = 0
  j = 0
  for(i in length(dat.list)){
    ntemp = dat.list[[i]]$n
    if(ntemp > nmax){
      nmax = ntemp
      j = i
    }
  }
  return(j)
}

get_K <- function(dir){
  i1 = gregexpr("seed", dir) %>% unlist
  i2 = gregexpr(".K", dir) %>% unlist
  return(as.integer(substring(dir, i2+3, i1-2)))
}

get_n <- function(csv_name){
  i1 = nchar(csv_name)
  i2 = gregexpr(".N", csv_name) %>% unlist
  return(as.integer(substring(csv_name, i2+3, i1-4)))
}

get_p <- function(dir){
  i1 = gregexpr(".s_", dir) %>% unlist
  i2 = gregexpr("p_", dir) %>% unlist
  return(as.integer(substring(dir, i2+2, i1-1)))
}



lasso.fun=function(x,y, family, offset=NULL, weights=NULL, lambda=NULL,alpha=1){
  if(is.null(weights)){weights=rep(1,dim(x)[1])}
  if(is.null(lambda)){
    cvfit = glmnet::cv.glmnet(x, y, family=family, offset=offset, weights=weights, alpha=alpha)
    pred = predict(cvfit, newx=x, type = "response")
    coef.1se = coef(cvfit, s = "lambda.min")
  }else{
    fit = glmnet::glmnet(x, y, family=family, offset=offset, weights=weights,lambda=lambda, alpha=alpha)
    pred = predict(fit, newx = x, type = "response")
    coef.1se = coef(fit)
  }
  best_cutoff = NA
  if(family == "binomial"){
    roc = roc(y, as.vector(pred))
    best_cutoff = coords(roc, "best", ret = "threshold", maximize = TRUE)
  }
  return(list(coef = as.numeric(coef.1se), cutoff = best_cutoff))
}


lasso.fun.0=function(x,y, family, offset=NULL, weights=NULL, lambda=NULL,alpha=1){
  if(is.null(weights)){weights=rep(1,dim(x)[1])}
  if(is.null(lambda)){
    cvfit = glmnet::cv.glmnet(x, y, family=family, offset=offset, weights=weights, alpha=alpha)
    # pred = predict(cvfit, newx=x, type = "response")
    coef.1se = coef(cvfit, s = "lambda.min")
  }else{
    fit = glmnet::glmnet(x, y, family=family, offset=offset, weights=weights,lambda=lambda, alpha=alpha)
    # pred = predict(fit, newx = x, type = "response")
    coef.1se = coef(fit)
  }
  return(coef.1se)
}

