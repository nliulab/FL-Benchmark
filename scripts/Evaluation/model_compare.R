library(dplyr)
library(pROC)
library(tidyr)


model_pairs <- list(c("Central", "fedavg"),
                    c("Central", "fedavgM"),
                    c("Central", "Qfedavg"),
                    c("Central", "fedprox_mu0"),
                    c("Central", "GLORE")
)

compare_auc_models <- function(df, model1, model2) {
  auc_data_long <- data.frame(
    AUC = c(df[[model1]], df[[model2]]),
    Model = factor(rep(c(model1, model2), each = nrow(df)))
  )
  
  anova_result <- aov(AUC ~ Model, data = auc_data_long)
  return(summary(anova_result))
}


#for high dim
model_pairs <- list(c("Central", "fedavg"),
                    c("Central", "fedavgM"),
                    c("Central", "Qfedavg"),
                    c("Central", "coef_fedprox_lr0.01_drop0_mu0"),
                    c("Central","DAC"),
                    c("Central","SHIR")
)

#----------------AUC----------------------------------

dir = "AUC"

auc_files = list.files(dir, pattern = "auc.csv")

compare_auc <- function(folder){
  dat = read.csv(file.path(dir,folder))
  K = unique(dat$Site_index)
  Comparison_model <- lapply(model_pairs, function(pair) {
    paste(pair[1], "vs", pair[2])
  })
  res_all = data.frame(Comparison = unlist(Comparison_model))
  for(i in 1:length(K)){
    df <- dat[dat$Site_index == i,]
    results <- list()
    for (pair in model_pairs) {
      model1 <- pair[1]
      model2 <- pair[2]
      model_res <- compare_auc_models(df, model1, model2)
      p_value = model_res[[1]]["Model", "Pr(>F)"]
      results[[paste(model1, "vs", model2)]] <- p_value
    }
    site_result = t(as.data.frame(results))
    col_name <- paste("Site", i, sep = "")
    res_all[[col_name]] = site_result[,1]
  }
  tukey_all = data.frame()
  multi_res = data.frame(Comparison = "Multi Groups")
  for(i in 1:length(K)){
    cols_to_remove <- c("seed","Site_index","Site1_Local", "Site2_Local", "Site3_Local","Meta","GLORE")
    #cols_to_remove <- c("seed","Site_index","Site1_Local", "Site2_Local", "Site3_Local","Meta","DAC","SHIR") #high dim
    site_df = dat[dat$Site_index == i,]
    auc_df <- site_df[, !(names(site_df) %in% cols_to_remove)]
    auc_data_long <- auc_df %>%
      pivot_longer(cols = everything(), names_to = "Model", values_to = "AUC")
    anova_result <- aov(AUC ~ Model, data = auc_data_long)
    anova_res = summary(anova_result)
    p.value = anova_res[[1]]["Model", "Pr(>F)"]
    col_name <- paste("Site", i, sep = "")
    multi_res[[col_name]] = p.value
    tukey_result <- TukeyHSD(anova_result)
    tukey_res <- as.data.frame(tukey_result$Model)
    tukey_res$Site_index = i
    tukey_all = rbind(tukey_all, tukey_res)
  }
  res_all = rbind(res_all, multi_res)
  print(folder)
  print(res_all)
  print(res_all<0.05)
}

lapply(auc_files, compare_auc)


#---------------------------coef----------------------------------------

dir = "Coef"



coef_files = list.files(dir, pattern = ".csv")

compare_coef_models <- function(df, model1, model2) {
  subset_df <- df[df$method == model1 | df$method == model2,]
  colnames(subset_df) = c("Beta","Model")
  anova_result <- aov(Beta ~ Model, data = subset_df)
  return(summary(anova_result))
}


compare_coef <- function(coef_file, beta){
  dat =  read.csv(file.path(dir,coef_file))
  df = dat[, c(beta, "method")]
  df = df[!df$method %in% c("Site1_Local", "Site2_Local", "Site3_Local","Meta"),]
  results = data.frame()
  for (pair in model_pairs) {
    model1 <- pair[1]
    model2 <- pair[2]
    model_res <- compare_coef_models(df, model1, model2)
    
    p_value = model_res[[1]]["Model", "Pr(>F)"]
    row_name = paste(model1, "vs", model2)
    row = data.frame(Comparison = row_name, p.value = p_value)
    results = rbind(results, row)
  }
  subset_df = df[df$method!=c("Central","GLORE"),]
  #subset_df = df[df$method!=c("Central","DAC","SHIR"),] #high dim
  colnames(subset_df) = c("Beta","Model")
  anova_result <- aov(Beta ~ Model, data = subset_df)
  anova_res = summary(anova_result)
  p_value = anova_res[[1]]["Model", "Pr(>F)"]
  new_row = data.frame(Comparison = "Multi Groups", p.value = p_value)
  results = rbind(results, new_row)
  print(coef_file)
  results = as.data.frame(results)
  results$sig <- ifelse(results$p.value < 0.05, TRUE, FALSE)
  print(results)
}

lapply(coef_files, compare_coef, beta = "Beta1")


