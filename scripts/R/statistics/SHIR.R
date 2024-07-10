library(MASS)
library(glmnet)

do_SHIR <- function(mainDir, tune = "BIC"){
  dir_list =list.dirs(mainDir, recursive = FALSE)
  for(dir in dir_list){
    setwd(dir)
    startTime <- Sys.time()
    dat <- get.dat(dir)
    X_lst <- list()
    Y_lst <- list()
    M <- length(dat)
    for(i in 1:M){
      X_lst[[i]] <- as.matrix(dat[[i]]$dat[, -1])
      Y_lst[[i]] <- as.matrix(dat[[i]]$dat[, 1])

      #for real data
      # X_lst[[i]] <- as.matrix(dat[[i]]$dat[, -ncol(dat[[i]]$dat)])
      # Y_lst[[i]] <- as.matrix(dat[[i]]$dat[, ncol(dat[[i]]$dat)])
    }
    
    # p = X_lst[[1]] %>% nrow
    length_lst <- c()
    
    I_lst <- vector('list', M)
    U_lst <- vector('list', M)
    beta_lst <- vector('list', M)
    
    system.time(
      for (m in 1:M){
        Y <- Y_lst[[m]]
        X <- X_lst[[m]]
        
        local_summary_m <- Local_fit(Y, X)
        
        I_lst[[m]] <- local_summary_m$hessian
        U_lst[[m]] <- local_summary_m$gradient
        beta_lst[[m]] <- local_summary_m$beta
        length_lst <- c(length_lst, length(Y))
      }
    )
    #print(beta_lst)
    system.time(
      SHIR_train <- SHIR_fit(I_lst, U_lst, length_lst)
    )
    
    
    endTime <- Sys.time()
    sink("SHIR.lasso.txt")
    print(endTime - startTime)
    sink()
    closeAllConnections()
    coef1 <- SHIR_train$min.beta
    write.csv(coef1, "coef_SHIR_lasso.csv")

    print(sprintf("finished %s", dir))
  }
}


### Function for SHIR ###
Local_fit <- function(Y, X, lambda_lst = c(0.1,0.2)){
  
  cv.result <- cv.glmnet(X, Y, family = 'binomial', lambda = lambda_lst)
  lambda.cv <- cv.result$lambda.min
  model <- glmnet(X, Y, family = 'binomial', lambda = lambda.cv)
  beta_fit <- c(as.vector(model$a0), as.vector(model$beta))
  
  n <- length(Y)
  X_all <- cbind(rep(1, n), X)
  pi_vec <- as.vector(1 / (1 + exp(- X_all %*% beta_fit)))
  grad <- t(X_all) %*% (Y - pi_vec)
  I_mat <- t(X_all) %*% diag(pi_vec * (1- pi_vec)) %*% X_all
  U <- I_mat %*% beta_fit + grad
  
  return(list(hessian = I_mat, gradient = U, beta = beta_fit))
}

Cal_GIC_pool <- function(U_lst, I_lst, X_all, fit_coef, length_lst, lambda_g, 
                         intercept = T, type = 'BIC'){
  M <- length(U_lst)
  if (intercept == T){
    
    p <- length(I_lst[[1]][1, ]) - 1
    mu <- fit_coef[1:(p + 1)]
    
    mu[which(abs(mu) < 1e-6)] <- 0
    
    beta_fit <- mu
    alpha_fit <- c()
    
    for (i in 2:M){
      beta_fit <- beta_fit - fit_coef[((i - 1) * p + i):(i * p + i)]
      alpha_fit <- cbind(alpha_fit, fit_coef[((i - 1) * p + i + 1):(i * p + i)])
    }
    for (i in 2:M) {
      beta_fit <- cbind(beta_fit, mu + 
                          fit_coef[((i - 1) * p + i):(i * p + i)])
    }
    norm_lst <- sqrt(rowSums(alpha_fit^2))
    S_alpha <- which(norm_lst != 0)
    S_mu <- which(mu != 0)
    S_full <- which(fit_coef != 0)
    H_S <- t(X_all[ ,S_full]) %*% X_all[ ,S_full]
    partial <- diag(0, length(S_full), length(S_full))
    if (length(S_alpha) != 0){
      for (t in 1:length(S_alpha)) {
        j <- S_alpha[t]
        partial_j <- t + 1 + length(S_mu) + (length(S_alpha) + 1) * c(0:(M-2))
        partial[partial_j, partial_j] <- lambda_g / norm_lst[j] *
          (diag(1, M - 1, M - 1) - alpha_fit[j,] %*% t(alpha_fit[j,]) / norm_lst[j]^2)
      }
    }
    df <- sum(diag(solve(H_S + partial) %*% H_S))
  }
  GIC <- 0
  for (i in 1:M){
    GIC <- GIC + t(beta_fit[,i]) %*% I_lst[[i]] %*% beta_fit[,i] -
      2 * t(beta_fit[,i]) %*% U_lst[[i]]
  }
  
  if (type == 'BIC'){
    GIC <- GIC / sum(length_lst) + 0.5 * df * log(sum(length_lst)) / sum(length_lst)
  }
  if (type == 'AIC'){
    GIC <- GIC / sum(length_lst) + df * 2 / sum(length_lst)
  }
  if (type == 'RIC'){
    GIC <- GIC / sum(length_lst) + df * log(M * p) / sum(length_lst)
  }
  return(list(GIC = GIC, beta = beta_fit))
}

SHIR_fit <- function(H_lst, d_lst, n_lst, lambda_lst = NULL,
                     lambda_g_lst = NULL, tune = 'BIC'){
  
  options(warn = -1)
  M <- length(d_lst)
  X_lst <- vector('list', M)
  Y_lst <- vector('list', M)
  n <- sum(n_lst)
  p <- length(H_lst[[1]][1, ]) - 1
  
  
  if (is.null(lambda_lst)){
    lambda_lst = sqrt(n * log(p)) * 0.3 * c(5:25)
  }
  if (is.null(lambda_g_lst)){
    lambda_g_lst = c(0.6, 0.9)
  }
  
  initial <- rep(0, (M + 1) * (p + 1))
  
  for (i in 1:M){
    H <- H_lst[[i]]
    d <- d_lst[[i]]
    mat_all <- cbind(H, d)
    mat_all <- rbind(mat_all, t(c(d, max(mat_all) + n)))
    svd_result <- svd(mat_all)
    s_value <- svd_result$d
    s_mat <- diag(sqrt(s_value))[ ,1:(min(p + 1, n_lst[[i]]) + 1)]
    data_all <- svd_result$u %*% s_mat
    X <- t(data_all[-length(data_all[ ,1]),])
    Y <- data_all[length(data_all[ ,1]),]
    X_lst[[i]] <- X
    Y_lst[[i]] <- Y
  }
  
  X_all <- c()
  Y_all <- c()
  for (i in 1:M){
    X_all <- rbind(X_all, X_lst[[i]])
    Y_all <- c(Y_all, Y_lst[[i]])
  }
  
  X_alpha <- X_lst[[1]]
  for (i in 2:M){
    X_alpha <- bdiag(X_alpha, X_lst[[i]])
  }
  X_all <- cbind(X_all, X_alpha)
  
  enlarge_mat <- matrix(0, p + 1, p + 1)
  for (i in 1:M) {
    enlarge_mat <- cbind(enlarge_mat, diag(rep(1, p + 1)))
  }
  
  indx_lst <- c(c(NA, 1:p), rep(c(NA, (p + 1):(2 * p)), M))
  
  # tune with GIC
  min.lambda <- NULL
  min.GIC <- Inf
  min.coef <- NULL
  min.beta <- NULL
  
  lambda_all <- c()
  lambda_g_all <- c()
  fit_coef_mat <- c()
  
  total_num <- length(lambda_g_lst) * length(lambda_lst)
  z <- 0
  
  for (lambda in lambda_lst){
    for (lambda_g in lambda_g_lst){
      
      lambda_g <- lambda_g * lambda
      penscale <- function(x){
        ifelse(x == 1, 1, lambda_g / lambda)
      }
      
      Y_ <- 0
      rho_ <- n
      enlarge_Y <- rep(- Y_ / sqrt(rho_ / 2) / 2, p + 1)
      X_enlarge <- rbind(X_all, sqrt(rho_ / 2) * enlarge_mat)
      Y_enlarge <- c(Y_all, enlarge_Y)
      
      eta <- 2
      for (iter in 1:10) {
        invisible(utils::capture.output(
          fit_result <- grplasso::grplasso(x = as.matrix(X_enlarge), y = Y_enlarge,
                                           index = indx_lst, standardize = F,
                                           center = FALSE, lambda = lambda,
                                           penscale = penscale, model = LinReg(),
                                           coef.init = initial)))
        fit_coef <- fit_result$coefficients
        initial <- fit_coef
        
        alpha_fit <- c()
        for (i in 2:(M + 1)){
          alpha_fit <- cbind(alpha_fit, fit_coef[((i - 1) * p + i):(i * p + i)])
        }
        
        Y_ <- Y_ + rho_ * rowMeans(alpha_fit)
        rho_ <- rho_ * eta
        X_enlarge <- rbind(X_all, sqrt(rho_ / 2) * enlarge_mat)
        Y_enlarge <- c(Y_all, - Y_ / sqrt(rho_ / 2) / 2 * rep(1, p + 1))
        
      }
      
      lambda_all <- c(lambda_all, lambda)
      lambda_g_all <- c(lambda_g_all, lambda_g)
      fit_coef_mat <- cbind(fit_coef_mat, fit_coef)
      
      result_GIC <- Cal_GIC_pool(d_lst, H_lst, X_enlarge,
                                 fit_coef, n_lst, lambda_g / 2, type = tune)
      GIC <- result_GIC$GIC
      if (GIC < min.GIC){
        min.lambda <- c(lambda, lambda_g / lambda)
        min.GIC <- GIC
        min.beta <- result_GIC$beta
        min.coef <- fit_coef
      }
      z <- z + 1
      print(paste0('Finishing: ', 100 * round(z / total_num, 4), '%'))
    }
  }
  return(list(min.lambda = min.lambda, min.beta = min.beta))
}
