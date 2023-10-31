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
get_central_res <- function(file_path){
  coef_path = file.path(file_path,"Coef_central.csv")
  df = read.csv(coef_path)
  coef_cen = df[2:9,2]
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

get_fedprox_res <- function(file_path, mu){
  if(mu == 1){
    file_name = "coef_fedprox_lr0.01_drop0_mu1.txt"
  }else if(mu == 0){
    file_name = "coef_fedprox_lr0.01_drop0_mu0.txt"
  }else if(mu == 0.5){
    file_name = "coef_fedprox_lr0.01_drop0_mu0.5.txt"
  }else if(mu == 0.1){
    file_name = "coef_fedprox_lr0.01_drop0_mu0.1.txt"
  }else if(mu == 0.01){
    file_name = "coef_fedprox_lr0.01_drop0_mu0.01.txt"
  }else{
    print("no result")
  }
  coef_path = file.path(file_path,file_name)
  coef_line = readLines(coef_path,warn=FALSE)
  coef_index <- grep("Coef:", coef_line)
  nums = coef_line[coef_index + 1:8]
  pattern <- "[-+]?\\d*\\.?\\d+(?:[eE][-+]?\\d+)?"
  nums <- str_extract_all(nums, pattern)
  nums_numeric <- lapply(nums, as.numeric)
  return(unlist(nums_numeric))
}


get_glore_res <- function(file_path){
  coef_path = file.path(file_path,"Coef_glore.csv")
  df = read.csv(coef_path, header = FALSE)
  coef_glore = df[2:9,1]
  return(coef_glore)
}


get_site_index <- function(csv_name){
  index = gsub(".*Site(\\d+)[^.]*\\..*", "\\1", csv_name)
  return(paste0("Site",index))
}


get_local_res <- function(file_path){
  file_list = list.files(file_path, pattern = "Coef\\.local\\.Site")
  local_coef = list()
  for(csv_name in file_list){
    df = read.csv(file.path(file_path,csv_name))
    coef = df[2:9,2]
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
    coef = df[1:8,2]
    index = get_site_index(csv_name)
    origin_coef[[index]] = coef
  }
  return(origin_coef)
}


# p = number of x
# method from c("central","Local","GLORE","fedavg","fedprox")
get_coef <- function(file_path,method = c("Central","Local","GLORE","fedavg","fedprox"),p = 8){
  output = data.frame(matrix(ncol = 0, nrow = p))
  x_values <- paste0("x", 1:p)
  output$x <- x_values
  if ("Central" %in% method) {
    coef = get_central_res(file_path)
    output[["Central"]] = coef
  }
  if ("Local" %in% method){
    coef = get_local_res(file_path)
    for(i in names(coef)){
      local_name = paste0(i,"_Local")
      output[[local_name]] = coef[[i]]
    }
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
    coef_mu0 = get_fedprox_res(file_path,0)
    output[["fedprox_mu0"]] = coef_mu0
    # coef_mu0_01 = get_fedprox_res(file_path,0.01)
    # output[["fedprox_mu0.01"]] = coef_mu0_01
    # coef_mu0_1 = get_fedprox_res(file_path,0.1)
    # output[["fedprox_mu0.1"]] = coef_mu0_1
    # coef_mu0_5 = get_fedprox_res(file_path,0.5)
    # output[["fedprox_mu0.5"]] = coef_mu0_5
    # coef_mu1 = get_fedprox_res(file_path,1)
    # output[["fedprox_mu1"]] = coef_mu1
  }
  return(output)
}
#---------------------------------------------------------------------------------------------------------------------------
get_coef_bysite <- function(file_path,method = c("Central","Local","ODAL2","GLORE","fedavg","fedprox"),p = 8,site_index){
  output = data.frame(matrix(ncol = 0, nrow = p))
  x_values <- paste0("x", 1:p)
  output$x <- x_values
  if ("Central" %in% method) {
    coef = get_central_res(file_path)
    output[["central_coef"]] = coef
  }
  if ("Local" %in% method){
    site_name = paste0("Site",site_index)
    coef = get_local_res(file_path)
    coef_site = coef[site_name == names(coef)]
    output[["Local_coef"]] = coef_site[[1]]
  }
  if ("GLORE" %in% method) {
    coef = get_glore_res(file_path)
    output[["GLORE_coef"]] = coef
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
    coef_mu1 = get_fedprox_res(file_path,1)
    output[["fedprox_mu1"]] = coef_mu1
    coef_mu0 = get_fedprox_res(file_path,0)
    output[["fedprox_mu0"]] = coef_mu0
    coef_mu0_1 = get_fedprox_res(file_path,0.1)
    output[["fedprox_mu0.1"]] = coef_mu0_1
    coef_mu0_5 = get_fedprox_res(file_path,0.5)
    output[["fedprox_mu0.5"]] = coef_mu0_5
    coef_mu0_01 = get_fedprox_res(file_path,0.01)
    output[["fedprox_mu0.01"]] = coef_mu0_01
  }
  return(output)
}

