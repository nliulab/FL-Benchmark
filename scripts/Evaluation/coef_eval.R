rm(list = ls())
library(stringr)
library(dplyr)
library(gridExtra)
library(ggplot2)
library(cowplot)
library(patchwork)
library(grid)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
source("helpers.r")

Dir = "../../data/simulated"
dir_list = list.dirs(Dir, recursive = FALSE)

#---------------save coef---------------------------

extract_coef <- function(dir){
  all_coef = data.frame()
  seed_list = list.dirs(dir,recursive = FALSE)
  for (seed in seed_list ){
    print(seed)
    coef = get_coef(seed)
    new_coef = data.frame(t(coef)[-1,])
    new_coef$method = colnames(coef)[-1]
    seed_index = gsub(".*seed(\\d+).*", "\\1", seed)
    new_coef$seed = seed_index
    all_coef = rbind(all_coef, new_coef)
  }
  cols_to_convert <- setdiff(names(all_coef), "method")
  all_coef[cols_to_convert] <- lapply(all_coef[cols_to_convert], as.numeric)
  names(all_coef)[1:8] <- paste0("Beta", 1:8)
  return(all_coef)
}

mapping <- c(
  "Central" = "Central",
  "Site1_Local" = "Local1",
  "Site2_Local" = "Local2",
  "Site3_Local" = "Local3",
  "GLORE" = "GLORE",
  "fedavg" = "FedAvg",
  "fedavgM" = "FedAvgM",
  "Qfedavg" = "q-FedAvg",
  "fedprox_mu0" = "FedProx(mu0)"
)

dir.create("Coef")
for(dir in dir_list){
  coef = extract_coef(dir)
  folder_name = basename(dir)
  write.csv(coef,paste0("Coef/",folder_name,"_coef.csv"),row.names = FALSE)
}


#---------------------plot----------------------------
draw_folder <- function(dir){
  folder_name = basename(dir)
  all_coef = extract_coef(dir)
  all_coef$method = mapping[all_coef$method]
  method_levels <- c("FedProx(mu0)", "q-FedAvg","FedAvgM", "FedAvg", 
                     "GLORE", "Local3","Local2","Local1", "Central")
  all_coef$method <- factor(all_coef$method, levels = method_levels)
  origin_coef_all = get_origin_coef(list.dirs(dir, recursive = FALSE)[1])
  #Use site2 coefficient
  origin_coef = origin_coef_all[[names(origin_coef_all)[2]]]
  draw_violin <- function(var_index){
    var_name = names(all_coef)[var_index]
    esti = bquote(beta[.(as.character(var_index))])
    max_lim = max(all_coef[,var_index])
    min_lim = min(all_coef[,var_index])
    plot <- ggplot(all_coef, aes(x = get(var_name), y = reorder(method,method))) + 
      xlab(esti) +
      geom_violin(width=1, size=2.0, trim = FALSE, fill ="#709BCD", color = "NA") +
      theme(legend.position = "none", panel.border = element_blank(), strip.background = element_blank()) +
      theme(axis.text = element_text(size = 14),  axis.title = element_text(size = 16)) +
      geom_vline(xintercept = origin_coef[var_index], color = "#808080",linetype = "dashed") +
      annotate("text", x = origin_coef[var_index], y = -Inf, 
               label = bquote(beta[.(var_index)] == .(origin_coef[var_index])), 
               fontface = "bold", vjust = -0.5, size = 6) +
      scale_y_discrete(labels = c("FedProx (μ=0)", "q-FedAvg", "FedAvgM", "FedAvg", 
                                  "GLORE", "Local3","Local2","Local1", "Central")) +
      theme(axis.title.y = element_blank()) +
      coord_cartesian(xlim=c(min_lim,max_lim))
    return(plot)
  }
  plots <- lapply(c(1,3,5,7), function(x) draw_violin(x))
  all_plots = grid.arrange(grobs = plots, ncol = 4,align = "v", 
                           top = textGrob("Method", x = 0, hjust = -0.8, vjust = 1, gp = gpar(fontsize = 15, fontface = "bold")))
  ggsave(paste0("Coef/",folder_name,"_coef_plot.pdf"), plot=all_plots, width=20, height=6)
  return(all_plots)
}

draw_folder(dir_list[1])

