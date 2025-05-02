setpar_sensi<- tibble(

  
  #Reach & flow routing --------------------------------------------------------
  # "CH_N1_9::CH_N1.sub      | change = absval | sub = c(21,22,23)" = 1/70,
  "n::CH_N2.rte      | change = absval | sub = 21" = c(0.02,0.04),
  "hf::CHD.rte         | change = absval | sub = 21" = c(10,20), #-6

  "B::CHW2.rte       | change = absval | sub = 21" = c(500,900),
  # "CH_S2_91::CH_S2.rte      | change = absval | sub = c(21,22,23)" = c(0.00001,0.000035),
  "Cnfp::CNFP.rte       | change = absval | sub = c(22,23)" = c(0,2), # 0.5
  "Kfp::KFP.rte         | change = absval | sub = c(22,23)" = c(3,10), # 5
  # "FPGEOM_9::FPGEOM.rte    | change = absval | sub = c(21,22,23)" = 0,
  # "THETAFP_9::THETA_FP.rte | change = absval | sub = c(21,22,23)" = 0.0001,
  
  
  # #Sediment routing ------------------------------------------------------------
  # # "Kch::KCH.rte      | change = absval | sub = c(21,22,23)" = c(0,0.5),
  # "db::DB.rte         | change = absval | sub = c(21,22,23)" = c(180,300), #-6
  # "ds::DSS.rte       | change = absval | sub = c(21,22,23)" = c(60,120),
  # "Beta::BETA.rte      | change = absval | sub = c(21,22,23)" = c(0.2,1),
  # # "Cnfp::CFP.rte       | change = absval | sub = c(21,22,23)" = c(100,500), # 0.5
  # "P_ETAN_91::P_ETAN.rte         | change = absval | sub = c(21,22,23)" = c(1.5,3.5), # 5
)
