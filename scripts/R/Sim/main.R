sim_path = "data/simulated"
source("scripts/R/Sim/sim_fun.R") 
myseed = c(1:50)
#### I. homogeneous settings:
para = list(p = 8, s= 6,
            sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1),
            lb_shift_X = 0, ub_shift_X=0,
            lb_sd.ratio=1, ub_sd.ratio=1,
            lb_shift_beta=0, ub_shift_beta=0)
Sig.X <- diag(1, para$p)
for(i in 1:length(myseed)){
  Sim.group(para, Sig.X, 3, c(1000, 2000, 4000),mainDir = sim_path, myseed = myseed[i])
}


#### II. Different Xs, 
para = list(p = 8, s= 6,
            sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1),
            lb_shift_X = -0.1, ub_shift_X=0.1,
            lb_sd.ratio=1, ub_sd.ratio=1,
            lb_shift_beta=0, ub_shift_beta=0)
Sig.X <- diag(1, para$p)
for(i in 1:length(myseed)){
  Sim.group(para, Sig.X, 3, c(1000, 2000, 4000), mainDir = sim_path,subDir = "differentX_mean_0.1_sd_1", heterogeneity_X = T, myseed =myseed[i])
}


para = list(p = 8, s= 6,
            sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1),
            lb_shift_X = -0.2, ub_shift_X=0.2,
            lb_sd.ratio=1, ub_sd.ratio=1,
            lb_shift_beta=0, ub_shift_beta=0)
Sig.X <- diag(1, para$p)
for(i in 1:length(myseed)){
  Sim.group(para, Sig.X, 3, c(1000,2000,4000), mainDir = sim_path, subDir = "differentX_mean_0.2_sd_1", heterogeneity_X = T, myseed =myseed[i])
}


para = list(p = 8, s= 6,
            sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1),
            lb_shift_X = -0.3, ub_shift_X=0.3,
            lb_sd.ratio=1, ub_sd.ratio=1,
            lb_shift_beta=0, ub_shift_beta=0)
Sig.X <- diag(1, para$p)
for(i in 1:length(myseed)){
  Sim.group(para, Sig.X, 3, c(1000,2000,4000),mainDir = sim_path, subDir = "differentX_mean_0.3_sd_1", heterogeneity_X = T, myseed =myseed[i])
}

para = list(p = 8, s= 6,
            sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1),
            lb_shift_X = -0.4, ub_shift_X=0.4,
            lb_sd.ratio=1, ub_sd.ratio=1,
            lb_shift_beta=0, ub_shift_beta=0)
Sig.X <- diag(1, para$p)
for(i in 1:length(myseed)){
  Sim.group(para, Sig.X, 3, c(1000,2000,4000),mainDir = sim_path, subDir = "differentX_mean_0.4_sd_1", heterogeneity_X = T, myseed =myseed[i])
}

para = list(p = 8, s= 6, 
            sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1), 
            lb_shift_X = 0.1, ub_shift_X=0.1, 
            lb_sd.ratio=0.9, ub_sd.ratio=1.1,
            lb_shift_beta=0, ub_shift_beta=0)
Sig.X <- diag(1, para$p)
for(i in 1:length(myseed)){
  Sim.group(para, Sig.X, 3, c(1000,2000,4000), mainDir = sim_path, subDir = "differentX_mean_0.1_sd_0.9_1.1", heterogeneity_X = T, myseed =myseed[i])
}

para = list(p = 8, s= 6,
            sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1),
            lb_shift_X = -0.1, ub_shift_X=0.1,
            lb_sd.ratio=0.8, ub_sd.ratio=1.2,
            lb_shift_beta=0, ub_shift_beta=0)
Sig.X <- diag(1, para$p)
for(i in 1:length(myseed)){
  Sim.group(para, Sig.X, 3, c(1000,2000,4000), mainDir = sim_path, subDir = "differentX_mean_0.1_sd_0.8_1.2", heterogeneity_X = T, myseed =myseed[i])
}


para = list(p = 8, s= 6,
            sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1),
            lb_shift_X = -0.1, ub_shift_X=0.1,
            lb_sd.ratio=0.7, ub_sd.ratio=1.3,
            lb_shift_beta=0, ub_shift_beta=0)
Sig.X <- diag(1, para$p)
for(i in 1:length(myseed)){
  Sim.group(para, Sig.X, 3, c(1000,2000,4000), mainDir = sim_path, subDir = "differentX_mean_0.1_sd_0.7_1.3", heterogeneity_X = T, myseed =myseed[i])
}


para = list(p = 8, s= 6,
            sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1),
            lb_shift_X = -0.1, ub_shift_X=0.1,
            lb_sd.ratio=0.6, ub_sd.ratio=1.4,
            lb_shift_beta=0, ub_shift_beta=0)
Sig.X <- diag(1, para$p)
for(i in 1:length(myseed)){
  Sim.group(para, Sig.X, 3, c(1000,2000,4000), mainDir = sim_path, subDir = "differentX_mean_0.1_sd_0.6_1.4", heterogeneity_X = T, myseed =myseed[i])
}





#### III. Different betas:

para = list(p = 8, s= 6, 
            sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1), 
            lb_shift_X = 0, ub_shift_X=0, 
            lb_sd.ratio=1, ub_sd.ratio=1,
            lb_shift_beta=0.9, ub_shift_beta=1.1)
Sig.X <- diag(1, para$p)
for(i in 1:length(myseed)){
  Sim.group(para, Sig.X, 3, c(1000,2000,4000), mainDir = sim_path, subDir = "differentBeta_0.1", heterogeneity_beta = T, myseed = myseed[i])
}

para = list(p = 8, s= 6, 
            sig.beta = c(-2, 1, 0.8, 0.4, 0.2, 0.1), 
            lb_shift_X = 0, ub_shift_X=0, 
            lb_sd.ratio=1, ub_sd.ratio=1,
            lb_shift_beta=0.8, ub_shift_beta=1.2)
Sig.X <- diag(1, para$p)
for(i in 1:length(myseed)){
  Sim.group(para, Sig.X, 3, c(1000,2000,4000), mainDir = sim_path, subDir = "differentBeta_0.2", heterogeneity_beta = T, myseed = myseed[i])
}
