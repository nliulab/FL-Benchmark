library(MASS)

do_DAC <- function(mainDir, niter=3, ridge=F, lambda = NULL, family = "binomial"){
  dir_list =list.dirs(mainDir, recursive = FALSE)
  for(dir in dir_list){
    
    startTime <- Sys.time()
    coef1 = DCOS.FUN(get.dat.DAC(dir), niter, ridge = F, lambda, family)
    endTime <- Sys.time()
    sink("DAC.lasso.txt")
    print(endTime - startTime)
    sink()
    closeAllConnections()

    write.csv(coef1, "coef_DAC_lasso.csv")
    print(sprintf("finished %s", dir))
    setwd("../../../..")
  }
}

iteration.fun2=function (dat.list, bini, kk.list) {
  K = length(dat.list)
  Uini.list = sapply(kk.list, function(kk) {
    U.fun(bini, dat = dat.list[[kk]])
  })
  Aini.list = lapply(1:K, function(kk) {
    A.fun(bini, dat = dat.list[[kk]])
  })
  Ahat.ini = Reduce("+", Aini.list)/K
  bhat.list = -ginv(Ahat.ini) %*% Uini.list + bini
  list(b.k = bhat.list, Ahat = Ahat.ini)
}
DCOS.FUN=function(dat.list, niter, ridge=F, lambda=NULL, family){
  K=length(dat.list)
  lambda.grid=10^seq(-100,3,0.1)
  N=sum(unlist(lapply(dat.list, function(xx) dim(xx)[1])))
  nn = unlist(lapply(dat.list, function(xx) dim(xx)[1]))
  max_index = which.max(nn)
  ### Round 1
  dat.list.00=dat.list[[max_index]]
  y1=dat.list.00[,1]
  x1=dat.list.00[,-1]
  ##initial
  if(ridge==F){
    bini = glm(y1~x1,family=family)$coef}
  if(ridge==T){
    bini = as.vector(coef(glmnet(x1,y1,alpha=0,standardize=F,lambda=lambda,family=family)))
  } 
  #update
  update=iteration.fun2(dat.list=dat.list,bini=bini,kk.list=1:K)
  bnew.update=apply(update$b.k,1,mean)
  for(ii in 1:(niter-1)){
    bnew=bnew.update
    update.DCOS = iteration.fun2(dat.list=dat.list,bini=bnew,kk.list=1:K)
    bnew.update = apply(update.DCOS$b.k,1,mean) 
  }
  Ahalf.DCOS= svd(-update.DCOS$Ahat); Ahalf.DCOS = Ahalf.DCOS$u%*%diag(sqrt(Ahalf.DCOS$d))%*%t(Ahalf.DCOS$v)
  betahat = Est.ALASSO.Approx.GLMNET(ynew=Ahalf.DCOS%*%bnew.update,xnew=Ahalf.DCOS,bini=bnew.update,N.adj=N,lambda.grid,family='gaussian')$bhat.BIC
  return(betahat)
}

Est.ALASSO.Approx.GLMNET=function (ynew, xnew, bini, N.adj, lambda.grid, modBIC = T, N.inflate = N.adj, family) 
{
  w.b = 1/abs(bini)
  tmpfit = glmnet(x = xnew, y = ynew, family = family, 
                  penalty.factor = w.b, alpha = 1, lambda = lambda.grid, intercept = F)
  LL = apply((c(ynew) - predict(tmpfit, xnew, type = "response"))^2, 
             2, sum) * N.inflate
  if (modBIC) {
    BIC.lam = LL + min(N.adj^0.1, log(N.adj)) * tmpfit$df
    m.opt = which.min(BIC.lam)
    bhat.modBIC = tmpfit$beta[, m.opt]
    lamhat.modBIC = tmpfit$lambda[m.opt]
  }
  else {
    bhat.modBIC = lamhat.modBIC = NA
  }
  BIC.lam = LL + log(N.adj) * tmpfit$df
  m.opt = which.min(BIC.lam)
  bhat.BIC = tmpfit$beta[, m.opt]
  lamhat.BIC = tmpfit$lambda[m.opt]
  return(list(bhat.BIC = bhat.BIC, bhat.modBIC = bhat.modBIC, 
              lambda.BIC = lamhat.BIC, lambda.modBIC = lamhat.modBIC))
}

A.fun=function (bet, dat) 
{
  yy = dat[, 1]
  xx.vec = cbind(1, dat[, -1])
  -t(c(dg.logit(xx.vec %*% bet)) * xx.vec) %*% xx.vec/length(yy)
}
# for continuous var:
A.fun.2=function (bet, dat) 
{
  yy = dat[, 1]
  xx.vec = cbind(1, dat[, -1])
  2 * t(xx.vec) %*% xx.vec / length(yy)
}
U.fun=function (bet, dat) 
{
  yy = dat[, 1]
  xx.vec = cbind(1, dat[, -1])
  c(t(c(yy - g.logit(xx.vec %*% bet))) %*% xx.vec)/length(yy)
}
# for continuous var:
U.fun.2=function (bet, dat) 
{
  yy = dat[, 1]
  xx.vec = cbind(1, dat[, -1])
  -2 * t(xx.vec) %*% (yy - xx.vec %*% bet) / length(yy)
}


dg.logit = function(xx){exp(xx)/(exp(xx)+1)^2}
g.logit=function(x) exp(x)/(1+exp(x))
logit=function(x) log(x/(1-x))
