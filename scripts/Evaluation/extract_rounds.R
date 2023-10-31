rm(list = ls())
library(stringr)
library(dplyr)
library(gridExtra)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))

Dir = "../../data/simulated"
dir_list = list.dirs(Dir, recursive = FALSE)

dir.create("Rounds")
#----------------------------extract GLORE iteration----------------------------------------
get_glore_its = function(file_path){
  glore_output = read.csv(file.path(file_path,"output_glore.txt"))
  it_nums = str_extract_all(as.character(glore_output), "(?<=Iteration )[0-9.]+")
  it_nums = unlist(it_nums)
  index = length(it_nums)
  it_num = as.numeric(it_nums[index])
  return(it_num)
}

get_all_its = function(dir_path){
  folders = list.dirs(dir_path,recursive = FALSE)
  seed_num = length(folders)
  all_its = data.frame(matrix(ncol = 2))
  names(all_its)=c("seed","GLORE")
  for(i in 1:seed_num){
    seed_index = gsub(".*seed(\\d+).*", "\\1", folders[i])
    all_its[i, 'seed'] = as.numeric(seed_index)
    all_its[i, 'GLORE'] = get_glore_its(folders[i])
  }
  return(all_its)
}

all_its_result = data.frame()
for(dir in dir_list){
  result = get_all_its(dir)
  result$data_type = basename(dir)
  print(dir)
  all_its_result = rbind(all_its_result,result)
}

mean_it = all_its_result %>% 
  group_by(data_type) %>% 
  summarize(mean_GLORE = mean(GLORE))
mean_it = as.data.frame(mean_it)
colnames(mean_it)[colnames(mean_it) == "mean_GLORE"] <- "GLORE"
mean_it[,"fedavg"] = 10
mean_it[,"fedavgM"] = 10
mean_it[,"Qfedavg"] = 30
mean_it[,"fedprox"] = 20
mean_it[mean_it$data_type=="homogenous",'fedprox'] = 10
write.csv(mean_it,"Rounds/rounds_mean.csv",row.names = FALSE)

