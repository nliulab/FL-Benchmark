rm(list = ls())
library(stringr)
library(dplyr)
library(gridExtra)
library(ggplot2)
library(cowplot)
library(grid)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

Dir = "../../data/simulated"
dir_list = list.dirs(Dir, recursive = FALSE)

#----------------------------------function-----------------------------------------------
get_auc <- function(file_path){
  auc_path = file.path(file_path,"auc.csv")
  df = read.csv(auc_path)
  return(df)
}

auc_convert <- function(df,col){
  convert_df = data.frame(matrix(ncol = 2, nrow = length(df)))
  colnames(convert_df) <- c("method", "auc")
  convert_df$auc = df
  convert_df$method = rep(col, length(df))
  return(convert_df)
}

mapping <- c(
  "Central" = "Central",
  "Site1_Local" = "Local1",
  "Site2_Local" = "Local2",
  "Site3_Local" = "Local3",
  "Meta" = "Meta",
  "GLORE" = "GLORE",
  "fedavg" = "FedAvg",
  "fedavgM" = "FedAvgM",
  "Qfedavg" = "q-FedAvg",
  "coef_fedprox_lr0.01_drop0_mu0" = "FedProx (μ=0)",
  "Site_index" = "Site_index",
  "seed" = "seed"
)

#-------------------Save Auc--------------------------------------
dir.create("AUC")
get_folder_auc = function(dir){
  folder_name = basename(dir)
  folders = list.dirs(dir, recursive = FALSE)
  all_auc = data.frame()
  seed_num = length(folders)
  for (seed in folders){
    seed_auc = get_auc(seed)
    seed_auc$seed = gsub(".*seed(\\d+).*", "\\1",basename(seed))
    all_auc = rbind(all_auc,seed_auc)
  }
  col_names <- colnames(all_auc)
  new_col_names <- mapping[col_names]
  colnames(all_auc) <- new_col_names
  
  write.csv(all_auc,paste0("AUC/",folder_name,"_auc.csv"),row.names = FALSE)
  return(all_auc)
}

get_folder_auc(dir_list[1])

#------------------------plot---------------------------------
draw_auc <- function(dir){
  folder_name = basename(dir)
  folders = list.dirs(dir, recursive = FALSE)
  all_auc = data.frame()
  seed_num = length(folders)
  for (seed in folders){
    seed_auc = get_auc(seed)
    seed_auc$seed = gsub(".*seed(\\d+).*", "\\1",basename(seed))
    all_auc = rbind(all_auc,seed_auc)
  }
  col_names <- colnames(all_auc)
  new_col_names <- mapping[col_names]
  colnames(all_auc) <- new_col_names
  cols_to_convert <- setdiff(names(all_auc), c("seed","Site_index"))
  max_auc = max(all_auc[, cols_to_convert])
  min_auc = min(all_auc[, cols_to_convert])
  site_auc <- function(Site_index){
    site_data = all_auc[all_auc$Site_index==Site_index,]
    site_convert = data.frame()
    for(col in cols_to_convert){
      df = site_data[,col]
      convert_df = auc_convert(df,col)
      site_convert = rbind(site_convert,convert_df)
    }
    return(site_convert)
  }
  
  draw_violin <- function(index){
    df <- site_auc(index)
    mean_auc <- mean(df$auc)
    method_levels <- c("Central", "Local1", "Local2", "Local3", "Meta","GLORE", 
                       "FedAvg", "FedAvgM", "q-FedAvg", "FedProx (μ=0)")
    df$method <- factor(df$method, levels = method_levels)
    
    plot <- ggplot(df, aes(x = method, y = auc)) +
      geom_violin(width=1, size=1.0, trim = FALSE, fill ="#709BCD", color = "NA") +
      theme(legend.position = "none", panel.border = element_blank(), strip.background = element_blank()) +
      xlab(paste0("AUC of Site", index)) +
      theme(
        axis.title.y = element_blank(),
        axis.title.x = element_text(size = 30),
        plot.title = element_text(hjust = 0.5),
        axis.text = element_text(size = 25),
        axis.title = element_text(size = 20)
      ) +
      geom_hline(yintercept = mean_auc, color = "#808080",linetype = "dashed") +
      geom_text(aes(x = 1, y = mean_auc, label = round(mean_auc,3)),
                hjust = 0.5, vjust = 0.5, size = 8, color = "gray30") +
      theme(axis.text.y = element_text(angle = 0, hjust = 0.5, vjust = -0.5),
            axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)) +
      scale_x_discrete(labels = c("Central", "Local1", "Local2", "Local3", "GLORE","Meta",
                                  "FedAvg", "FedAvgM", "q-FedAvg", "FedProx (μ=0)")) +
      ylim(min_auc-0.01,max_auc+0.01)

    return(plot)
  }
  
  plots <- lapply(1:length(unique(all_auc$Site_index)), function(x) draw_violin(x))
  all_plots <- do.call(grid.arrange, c(grobs = plots, ncol = 3, nrow = 1))
  ggsave(paste0("AUC/",folder_name,"_auc_plot.pdf"), plot=all_plots, width=45, height=13)
  return(all_plots)
}

draw_auc(dir_list[1])
