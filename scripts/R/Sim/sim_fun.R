# basic functions for simulate data (LR)
# p: number of predictors
library(caret)

g.logit=function(x) exp(x)/(1+exp(x))
logit=function(x) log(x/(1-x))


# generate covariance matrix:
# default: identically distributed
Sigma.gen <- function(n){
  p <- qr.Q(qr(matrix(rnorm(n^2), n)))
  return(crossprod(p, p*(n:1)))
}

# shift_X: shift relative to 0. 
# sd.ratio: sd.ration*1
# shift_beta: ratio!
Data.gen=function(n, p, beta0, Sig.X, shift_X, sd.ratio, shift_beta){
  x <- MASS::mvrnorm(n, rep(shift_X, p), sd.ratio*Sig.X)
  y=unlist(lapply(1:n, function(ll) rbinom(1,1,g.logit(x[ll,] %*% (shift_beta*beta0) ))))
  data.frame(y,x)
}

# generate coefficients:
# p:  dimensions
# s: number of non-zero coefficients
# sig.beta: magnitude of non-zero coefficients
# sig.beta1: magnitude of noise
# h: number of coefficients with noise for source
# n: sample size
Coef.gen<- function(s = 6, p = 50, sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1)){
  if(length(sig.beta)!=s){
    print("ERROR! inconsistent input")
    return()
  }
  beta0 = c(sig.beta, rep(0, p-s))
  return(beta0)
}

# simulate one group of data
# default option: independent variables
# Sig.X should be decided outside of this function!!
# K: number of sites
# N: client size
# in current setting, training and testing data are generated at a proportion of 70% and 30%
Sim.single <- function(para, Sig.x, n, file.name, shift_X, sd.ratio, shift_beta){
  coef.all <- Coef.gen(s = para$s, sig.beta = para$sig.beta, p = para$p)
  dat=Data.gen(n = n, p = para$p, beta0 = coef.all, Sig.X, shift_X, sd.ratio, shift_beta)
  # write ground truth coefficients:
  write.csv(coef.all*shift_beta, paste("Coef_", file.name, sep = ""))
  return(dat)
}

# currently default option: unified para, Sig.X for one group of data
# currently only consider independent variables
Sim.group <- function(para, Sig.X, K, N, mainDir, subDir = "homogenous", heterogeneity_X = F, heterogeneity_beta = F, myseed){
  set.seed(myseed)
  if(K!=length(N)){
    print("ERROR! Length of list should equal to number of sites")
    return(NULL)
  }
  # create and set directory:
  dir.create(file.path(mainDir, subDir), showWarnings = F)
  setwd(file.path(mainDir, subDir))
  
  path = sprintf("p_%d.s_%d.K_%d_seed%d/", para$p, para$s, K, myseed)
  dir.create(file.path(getwd(), path), showWarnings = F)
  setwd(file.path(getwd(), path))
  
  # set up parameters for heterogeneity
  if(heterogeneity_X){
    #print("Generating heterogenous covariate distribution")
    shift_X = gen.shift(p=K, lb = para$lb_shift_X, ub = para$ub_shift_X)
    sd.ratio = gen.shift(p=K, lb = para$lb_sd.ratio, ub = para$ub_sd.ratio)
  }
  else{
    shift_X = rep(1,K)
    sd.ratio = rep(1,K)
  }

  if(heterogeneity_beta){
    #print("Generating heterogenous effect size")
    shift_beta = gen.shift(p=K, lb = para$lb_shift_beta, ub = para$ub_shift_beta)
  }
  else{
    shift_beta = rep(1,K)
  }
  
  for(i in 1:K){
    file.name = sprintf("Site%d.N_%d.csv", i, N[i])
    dat = Sim.single(para, Sig.X, N[i], file.name, shift_X[i], sd.ratio[i], shift_beta[i]) # all data
    
    # split data into training and testing sets:
    index <- sample(seq_len(nrow(dat)), size = floor(0.7*nrow(dat)), replace = FALSE)
    train <- dat[index, ]
    test <- dat[-index, ]
    
    write.csv(train, sprintf("Site%d.train.N_%d.csv", i, nrow(train)), row.names = F)
    write.csv(test, sprintf("Site%d.test.N_%d.csv", i, nrow(test)), row.names = F)
  }
  setwd("../../../..")
}



# extra function to control covariate shifting and sd ratio

# p: length of vector for shifting para. Default equal to number of K sites.

gen.shift <- function(p, lb=0.5, ub=2, cut = NULL){
  if(is.null(cut)){
    mu_shift = seq(from=lb,to=ub,length.out=p)
  }
  else if(length(cut)==p){
    mu_shift = cut
  }
  else{
    print("Error! Double check input")
    return()
  }
  return(mu_shift)
}

