
writeSelfAsLog("sett_query")

# Query settings ----------------------------------------------------------

sett_query <- c()
sett_query$db_conn_name <- "db_conn_7" 
sett_query$db_name <- "URBAN_MV_VIE_UniBw_Study2" 
sett_query$src_prefix <- "t_adtf" 
sett_query$src_suffix <- "full_dti_rnd1" 
sett_query$df_name_prefix <- "study2"
sett_query$pxx   <-  c(1,2)
#sett_query$run <- 1
#sett_query$speed <- 50
sett_query$round <- c("t1_50", "t2_50", "t1_70", "t2_70")
#sett_query$round <- c("intro", "normal", "stress")
sett_query$subject <- 1:31
sett_query$var_dist <- "dti_m_rnd1"
#sett_query$dist1 <- -150
sett_query$dist1 <- -90
sett_query$dist2 <- 50
sett_query$dist_buffer <- 50
sett_query$var_session <-
  c("subject_id",
    "round_txt",
    "time_s",
    "gps_lat",
    "gps_lon")
sett_query$var_pxx <- createVector_var_pxx(sett_query$var_dist)
sett_query$var_data <-
  c("speed_kmh",
    "acc_lon_ms2",
    "acc_lat_ms2",
    "acc_pedal_pos_perc",
    "brake_status",
    "brake_press_bar",
    "steer_angle_deg",
    "yaw_rate_degs")

sett_query$filter$sets <-
  list(
    list(sett_id_names$active$round, sett_query$round, "=", "OR"),
    list(sett_id_names$active$subject, sett_query$subject, "=", "OR"),
    list(sett_query$var_dist, sett_query$dist1 - sett_query$dist_buffer, ">="),
    list(sett_query$var_dist, sett_query$dist2 + sett_query$dist_buffer, "<=")
  )
sett_query$filter$bool_op_between <- c("AND")



# Fetching data -----------------------------------------------------------

#dbFindConnObj(sett_query$db_name, output = T)
dbGetQuery_pxxBatch(sett_query$db_conn_name, sett_query, bind_rows = T)

