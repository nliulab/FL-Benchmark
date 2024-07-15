library(dplyr)
Dir = "../../data/simulated"
dir_list =  list.dirs(Dir,recursive = F)

site_p <- function(dir,site_index){
  seeds = list.dirs(dir,recursive = FALSE)
  roc_res = data.frame()
  for(seed in seeds){
    roc_file = read.csv(file.path(seed,"roc_res.csv"))
    df = roc_file[roc_file$site==site_index,]
    roc_res = rbind(roc_res,df)
  }
  seed_num = length(seeds)
  result <- roc_res %>%
    group_by(vars) %>%
    summarise(count_p_value = sum(p.value < 0.05, na.rm = TRUE)/seed_num)
  
  return(as.data.frame(result))
}

dir.create("ROC")
setting_p <- function(dir,site_num){
  all_p <- list()
  for(i in 1:site_num){
    p_res  = site_p(dir,i)
    all_p[[i]] = p_res
  }
  result <- all_p[[1]]
  for (i in 2:length(all_p)) {
    result <- left_join(result, all_p[[i]], by = "vars",suffix = c("", paste0("_", i)))
  }
  folder_name = basename(dir)

  write.csv(result,paste0("ROC/",folder_name,".csv"),row.names = F)
  return(result)
}

lapply(dir_list,setting_p,site_num = 3)
