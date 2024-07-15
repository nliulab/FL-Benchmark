get_K <- function(file_path){
  csv_list = list.files(file_path, pattern = "Site.*test")
  K = length(csv_list)
  return(K)
}

get_n <- function(csv_name){
  index = gsub(".*Site(\\d+)[^.]*\\..*", "\\1", csv_name)
  return(index)
}

get.dat.test <- function(dir){
  file_list <- list.files(path = dir, pattern = "Site.*test")
  K = get_K(dir)
  #print(K)
  dat.list <- vector("list", K)
  i = 0
  for (file_name in file_list) {
    i = i+1
    dat.list[[i]]$dat = read.csv(file.path(dir,file_name))
    dat.list[[i]]$n = get_n(file_name)
  }
  return(dat.list)
}


#-----------------------for coef-------------------------------------------------


get_central_res <- function(file_path, sparse = F){
  if(sparse){
    coef_path = file.path(file_path,"Coef.central.lasso.csv")
  }else{
    coef_path = file.path(file_path,"Coef_central.csv")
  }
  df = read.csv(coef_path)
  coef_cen = df[-1,2]
  return(coef_cen)
}

get_fedavg_res <- function(file_path, type = "fedavg"){
  if(type == "fedavg"){
    file_name = "coef_flwr_fedavg.txt"
  }else if(type == "Qfedavg"){
    file_name = "coef_flwr_Qfedavg.txt"
  }else if(type == "fedavgM"){
    file_name = "coef_flwr_fedavgM.txt"
  }else{
    print("no result")
  }
  coef_path = file.path(file_path,file_name)
  coef_line = readLines(coef_path,warn=FALSE)
  coef_index <- grep("Coef:", coef_line)
  coef_num <- coef_line[coef_index + 1]
  pattern <- "[-+]?\\d*\\.?\\d+(?:[eE][-+]?\\d+)?"
  nums <- str_extract_all(coef_num, pattern)
  nums_numeric <- lapply(nums, as.numeric)
  return(unlist(nums_numeric))
}


get_fedprox_res <- function(file_path,p){
  txt_list = list.files(path = file_path, pattern = "coef*.fedprox")
  K = length(txt_list)
  fedprox_coef = vector("list", K)
  i=0
  for(file_name in txt_list){
    i=i+1
    coef_path = file.path(file_path,file_name)
    coef_line = readLines(coef_path,warn=FALSE)
    coef_index <- grep("Coef:", coef_line)
    nums = coef_line[coef_index + 1:p]
    pattern <- "[-+]?\\d*\\.?\\d+(?:[eE][-+]?\\d+)?"
    nums <- str_extract_all(nums, pattern)
    nums_numeric <- lapply(nums, as.numeric)

    fedprox_coef[[i]]$coef = unlist(nums_numeric)
    fedprox_coef[[i]]$method = file_name
  }
  return(fedprox_coef)
}


get_DAC_res <- function(file_path){
  coef_path = file.path(file_path,"coef_DAC_lasso.csv")
  df = read.csv(coef_path)
  coef_DAL = df[-1,2]
  return(coef_DAL)
}

get_glore_res <- function(file_path){
  coef_path = file.path(file_path,"Coef_glore.csv")
  df = read.csv(coef_path, header = FALSE)
  coef_glore = df[c(-1,-nrow(df)),]
  return(coef_glore)
}

get_meta_res <-function(file_path){
  coef_path = file.path(file_path,"Coef_meta.csv")
  df = read.csv(coef_path, header = FALSE)
  coef_meta = df[-c(1, 2), -1]
  return(coef_meta)
}

get_SHIR_res <- function(file_path){
  coef_path = file.path(file_path,"coef_SHIR_lasso.csv")
  df = read.csv(coef_path)
  coef_cen = df[-1,2]
  return(coef_cen)
}

get_site_index <- function(csv_name){
  index = gsub(".*Site(\\d+)[^.]*\\..*", "\\1", csv_name)
  return(paste0("Site",index))
}


get_local_res <- function(file_path, sparse = F){
  if(sparse){
    file_list = list.files(file_path, pattern = "Coef\\.lasso\\.local\\.Site")
  }else{
    file_list = list.files(file_path, pattern = "Coef\\.local\\.Site")
  }
  local_coef = list()
  for(csv_name in file_list){
    df = read.csv(file.path(file_path,csv_name))
    coef = df[-1,2]
    index = get_site_index(csv_name)
    local_coef[[index]] = coef
  }
  return(local_coef)
}

get_origin_coef <- function(file_path){
  file_list = list.files(file_path, pattern = "^Coef_Site")
  origin_coef = list()
  for(csv_name in file_list){
    df = read.csv(file.path(file_path,csv_name))
    coef = df[,2]
    index = get_site_index(csv_name)
    origin_coef[[index]] = coef
  }
  return(origin_coef)
}

# get_Beta <- function(file_path){
#   coef_path = file.path(file_path,"Coef_central.csv")
#   df = read.csv(coef_path)
#   beta_name = df[-1,1]
#   return(beta_name)
# }

# p = number of x
get_coef <- function(file_path,method = c("Central","Local","Meta","GLORE","fedavg","fedprox"),p = 8, sparse = F){
  output = data.frame(matrix(ncol = 0, nrow = p))
  if ("Central" %in% method) {
    coef = get_central_res(file_path, sparse)
    output[["Central"]] = coef
  }
  if ("Local" %in% method){
    coef = get_local_res(file_path, sparse)
    for(i in names(coef)){
      local_name = paste0(i,"_Local")
      output[[local_name]] = coef[[i]]
    }
  }
  if ("DAC" %in% method) {
    coef = get_DAC_res(file_path)
    output[["DAC"]] = coef
  }
  if ("Meta" %in% method) {
    coef = get_meta_res(file_path)
    output[["Meta"]] = coef
  }
  if ("SHIR" %in% method) {
    coef = get_SHIR_res(file_path)
    output[["SHIR"]] = coef
  }
  if ("GLORE" %in% method) {
    coef = get_glore_res(file_path)
    output[["GLORE"]] = coef
  }
  if ("fedavg" %in% method) {
    coef_avg = get_fedavg_res(file_path)
    output[["fedavg"]] = coef_avg
    coef_Qavg = get_fedavg_res(file_path, type = "Qfedavg")
    output[["Qfedavg"]] = coef_Qavg
    coef_avgM = get_fedavg_res(file_path, type = "fedavgM")
    output[["fedavgM"]] = coef_avgM
  }
  if ("fedprox" %in% method){
    fedprox = get_fedprox_res(file_path, p)
    K = length(fedprox)
    for(i in 1:K){
      name = fedprox[[i]]$method
      method = gsub("\\.txt$", "", name)
      output[[method]] = fedprox[[i]]$coef
    }
  }
  return(output)
}
