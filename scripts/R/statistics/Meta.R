get.coef.pool <- function(v1, method = "meta", K, sample_size){
  Coef <- matrix(, nrow = length(v1[[1]]), ncol = K)
  for (i in 1:K) {
    Coef[, i] <- v1[[i]]
  }
  
  if(method=="meta"){
    # print("Pooling by sample size weighted mean")
    coef = apply(Coef, 1, FUN = function(x){
      weighted.mean(x, w = sample_size/sum(sample_size))
    })
  }
  else{
    #print("Pooling by mean")
    coef = rowMeans(Coef)
  }
  return(coef)
}

get.meta.1seed <- function(dir, sparse){
  setwd(dir)
  dat.list = get.dat(dir)
  N = c()
  coef.vec = c()
  
  if(sparse){
    file_names <- list.files(full.names = TRUE, pattern = "Coef.lasso.local.*")
    coef.vec <- lapply(file_names, function(file) {
      read.csv(file)[,-1]
    })
  }
  else{
    file_names <- list.files(full.names = TRUE, pattern = "Coef.local.*")
    coef.vec <- lapply(file_names, function(file){
      read.csv(file)[,-1]
    })}
  
  for(i in seq_along(dat.list)){
    df = dat.list[[i]]$dat
    N = c(N, dat.list[[i]]$n)
  }
  
  for(i in seq_along(coef.vec)) {
    coef.vec[[i]] <- as(Matrix(coef.vec[[i]]), "matrix")
  }
  coef.m = get.coef.pool(coef.vec, K = length(dat.list), sample_size = N)
  write.csv(coef.m, "Coef_meta.csv")
}

do.meta.all <- function(mainDir, sparse = F){
  dir_list =list.dirs(mainDir, recursive = FALSE)
  for(dir in dir_list){
    get.meta.1seed(dir, sparse)
  }
}


