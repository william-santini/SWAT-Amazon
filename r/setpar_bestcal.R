setpar_bestcal <- c(

    
    # ____________________________________________________________________________ 
    # 9) Downstream Floodplain, main stem = (21, 22, 23)
    # ____________________________________________________________________________
    # Grounwater
    "ALPHA_BF_9::ALPHA_BF.gw | change = absval | sub = c(21,22,23)" = 0.263,
    "GW_DELAY_9::GW_DELAY.gw | change = absval | sub = c(21,22,23)" = 34.5,
    "GWQMN_9::GWQMN.gw       | change = absval | sub = c(21,22,23)" = 12.8,
    "GW_REVAP_9::GW_REVAP.gw | change = absval | sub = c(21,22,23)" = 0.12,
    "REVAPMN_9::REVAPMN.gw   | change = absval | sub = c(21,22,23)" = 909.67,
    "RCHRG_DP_9::RCHRG_DP.gw | change = absval | sub = c(21,22,23)" = 0.9,
    
    # Infiltration
    "CN2_9::CN2.mgt          | change = pctchg | sub = c(21,22,23)" = 0,
    # "SOL_AWC_9::SOL_AWC.mgt  | change = pctchg | sub = c(21,22,23)" = +15,
    
    # Evapotranspiration
    "ESCO_9::ESCO.hru        | change = absval | sub = c(21,22,23)" = 0.8,
    "EPCO_9::EPCO.hru        | change = absval | sub = c(21,22,23)" = 0.5,
    "CANMX_9::CANMX.hru      | change = absval | sub = c(21,22,23)" = 5.2,
    
    # Lateral flows
    # "SLSOIL_9::SLSOIL.hru    | change = pctchg | sub = c(21,22,23)" = +30,
    # "SOL_K_9::SOL_K.sol      | change = pctchg | sub = c(21,22,23)" = +30,
    # "HRU_SLP_9::HRU_SLP.hru  | change = pctchg | sub = c(21,22,23)" = +30, 
    
    # Land-Surface flows
    # "SLSUB_9::SLSUBBSN.hru   | change = absval | sub = c(21,22,23)" = 10, 
    # "OV_N_9::OV_N.hru        | change = absval | sub = c(21,22,23)" = 0.05,
    # "SURLAG_9::SURLAG.hru    | change = absval | sub = c(21,22,23)" = 10,
    
    
    # Reach & flow routing
    "CH_S2_sub23::CH_S2.rte  | change = absval | sub = 23" = 5.5e-05,
    "CH_S2_sub22::CH_S2.rte  | change = absval | sub = 22" = 5.3e-05,
    "CH_S2_sub21::CH_S2.rte  | change = absval | sub = 21" = 3.0e-05,
    
    "CH_N2_sub23::CH_N2.rte  | change = absval | sub = 23" = 1/44.5,
    "CH_N2_sub22::CH_N2.rte  | change = absval | sub = 22" = 1/44.5,
    "CH_N2_sub21::CH_N2.rte  | change = absval | sub = 21" = 1/44, 
    
    "CNCH_sub21::CNCH.rte    | change = absval | sub = 21" = 0.4,
    "HCH_sub21::HCH.rte      | change = absval | sub = 21" = 14.5,
    
    "CHD_sub23::CHD.rte      | change = absval | sub = 23" = 11,
    "CHD_sub22::CHD.rte      | change = absval | sub = 22" = 12,
    "CHD_sub21::CHD.rte      | change = absval | sub = 21" = 14.59,
    
    "CH_W2_sub23::CHW2.rte   | change = absval | sub = 23" = 850,
    "CH_W2_sub22::CHW2.rte   | change = absval | sub = 22" = 850,
    "CH_W2_sub21::CHW2.rte   | change = absval | sub = 21" = 750,  
    
    "KFP_sub23::KFP.rte          | change = absval | sub = 23" = 12.6,
    "KFP_sub22::KFP.rte          | change = absval | sub = 22" = 10.69,

    "FPGEOM_sub21::FPGEOM.rte    | change = absval | sub = 21" = 1,
    "THETAFP_sub21::THETA_FP.rte | change = absval | sub = 21" = 0.0002,
    
    "CNFP_sub23::CNFP.rte        | change = absval | sub = 23" = 0.3,
    "CNFP_sub22::CNFP.rte        | change = absval | sub = 22" = 0.48,
    "CNFP_sub21::CNFP.rte        | change = absval | sub = 21" = 1,
    
    # Sand routing
    
    "DB_sub23::DB.rte            | change = absval | sub = 23" = 242.7, 
    "DSS_sub23::DSS.rte          | change = absval | sub = 23" = 80,
    "CBK_sub23::CBK.rte          | change = absval | sub = 23" = 147.6,
    "KCH_sub23::KCH.rte          | change = absval | sub = 23" = 0.24,
    "BETA_sub23::BETA.rte        | change = absval | sub = 23" = 1.85,
    "ETA_sub23::ETA.rte          | change = absval | sub = 23" = 3.75,
    
    
    "DB_sub22::DB.rte            | change = absval | sub = 22" = 235.6, 
    "DSS_sub22::DSS.rte          | change = absval | sub = 22" = 80,
    "CBK_sub22::CBK.rte          | change = absval | sub = 22" = 213.5,
    "KCH_sub22::KCH.rte          | change = absval | sub = 22" = 0.04,
    "BETA_sub22::BETA.rte        | change = absval | sub = 22" = 1.84,
    "ETA_sub22::ETA.rte          | change = absval | sub = 22" = 6.66,
    
    
    "DB_sub21::DB.rte            | change = absval | sub = 21" = 219.4,
    "DSS_sub21::DSS.rte          | change = absval | sub = 21" = 80,
    "CBK_sub21::CBK.rte          | change = absval | sub = 21" = 188.1,
    "KCH_sub21::KCH.rte          | change = absval | sub = 21" = 0.01,
    "BETA_sub21::BETA.rte        | change = absval | sub = 21" = 1.64,
    "ETA_sub21::ETA.rte          | change = absval | sub = 21" = 6.95,
    
    
    # ____________________________________________________________________________  
    # 10) Righ bank plain tributaries = (1, 2, 4)
    # ____________________________________________________________________________
    # Grounwater
    "ALPHA_BF_10::ALPHA_BF.gw | change = absval | sub = c(1,2,4)" = 0.2,
    "GW_DELAY_10::GW_DELAY.gw | change = absval | sub = c(1,2,4)" = 57.4,
    "GWQMN_10::GWQMN.gw       | change = absval | sub = c(1,2,4)" = 743.1,
    "GW_REVAP_10::GW_REVAP.gw | change = absval | sub = c(1,2,4)" = 0.07,
    "REVAPMN_10::REVAPMN.gw   | change = absval | sub = c(1,2,4)"  = 920.55, 
    "RCHRG_DP_10::RCHRG_DP.gw | change = absval | sub = c(1,2,4)" = 0.5,
    
    # Infiltration
    "CN2_10::CN2.mgt         | change = pctchg | sub = c(1,2,4)" = -24, 
    # "SOL_AWC_10::SOL_AWC.mgt | change = pctchg | sub = c(1,2,4)" = +15,
    
    # Evapotranspiration
    "ESCO_10::ESCO.hru       | change = absval | sub = c(1,2,4)" = 0.9, 
    "EPCO_10::EPCO.hru       | change = absval | sub = c(1,2,4)" = 0.6, 
    "CANMX_10::CANMX.hru     | change = absval | sub = c(1,2,4)" = 9.1, 
    
    # Lateral flows
    # "SLSOIL_10::SLSOIL.hru   | change = pctchg | sub = c(1,2,4)" = +30,
    # "SOL_K_10::SOL_K.sol     | change = pctchg | sub = c(1,2,4)" = +30,
    # "HRU_SLP_10::HRU_SLP.hru | change = pctchg | sub = c(1,2,4)" = +30, 
    
    # Land-Surface flows
    # "SLSUB_10::SLSUBBSN.hru   | change = absval | sub = c(1,2,4)" = 10, 
    # "OV_N_10::OV_N.hru        | change = absval | sub = c(1,2,4)" = 0.05,
    # "SURLAG_10::SURLAG.hru    | change = absval | sub = c(1,2,4)" = 10,
    
    # Reach & flow routing
    "CH_N2_10::CH_N2.rte      | change = absval | sub = c(1,2,4)" = 0.0273661,
    "CHD_10::CHD.rte          | change = pctchg | sub = c(1,2,4)" = -44.92,
    "CH_W2_10::CHW2.rte       | change = pctchg | sub = c(1,2,4)" = -14.55,
    "CH_S2_10::CH_S2.rte      | change = pctchg | sub = c(1,2,4)" = -10.57,
    "CNFP_10::CNFP.rte        | change = absval | sub = c(1,2,4)" = 1.21,
    "KFP_10::KFP.rte          | change = absval | sub = c(1,2,4)" = 6.01,
    
    # Sand routing
    "DB_10::DB.rte            | change = absval | sub = c(1,2,4)" = 363.53,
    "DSS_10::DSS.rte          | change = absval | sub = c(1,2,4)" = 94.69,
    "CBK_10::CBK.rte          | change = absval | sub = c(1,2,4)" = 431.75,
    "KCH_10::KCH.rte          | change = absval | sub = c(1,2,4)" = 0.72,
    "BETA_10::BETA.rte        | change = absval | sub = c(1,2,4)" = 1.72,
    "ETA_10::ETA.rte          | change = absval | sub = c(1,2,4)" = 3.02
    
  )