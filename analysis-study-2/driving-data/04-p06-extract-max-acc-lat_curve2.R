
# Settings ----------------------------------------------------------------

## Data
sett <- c()
sett$meta$df_name <- "dat_study2_t_adtf_pxx_full_aggr_dti_rnd1_intrpld_cut"
#sett$meta$df_name <- "dat_study2_t_adtf_pxx_full_aggr_tti_rnd1_intrpld_cut"
sett$meta$am <- ifelse(grepl("dti", sett$meta$df_name), "dti", "tti")
sett$meta$am_ger <- ifelse(sett$meta$am == "dti", "dzk", "zzk")

## Filter
sett$filters$pxx <- 6
sett$filters$am <- "dti"
sett$filters$am_lower <- -50
sett$filters$am_upper <- 250
sett$filters$am_lower_precise <- -50
sett$filters$am_upper_precise <- 250


## Column names
sett$col_names$pxx <- c("pxx")
sett$col_names$am <- findColNameForAM(sett$meta$am, get(sett$meta$df_name))
sett$col_names$dti <- findColNameForAM("dti", get(sett$meta$df_name))
sett$col_names$tti <- findColNameForAM("tti", get(sett$meta$df_name))
sett$col_names$measure_speed <- "speed_kmh"
sett$col_names$measure_acc_lat <- "acc_lat_ms2"
sett$col_names$measure_acc_lat_abs <- 
  paste_(sett$col_names$measure_acc_lat, "abs")
sett$col_names$id <- "passing"
sett$col_names$subject <- "subject_id"
sett$col_names$condition_run <- "condition_run"
sett$col_names$condition_speed <- "condition_speed"

## Data for experimental conditions
sett$db$db_names$study2 <- "URBAN-MV-VIE_UniBw_Study-2"
sett$db$conn_names$study2 <- dbFindConnObj(sett$db$db_names$study2, output = F)



# Preprocess data ---------------------------------------------------------

## Get data
dat <- get(sett$meta$df_name) 

## Filter position
dat <- 
  dat %>% 
  ## Filter for position
  filter_(createFilterString(sett$col_names$pxx, sett$filters$pxx))

## Filter AM
dat <- 
  dat %>% 
  filter_(paste(sett$col_names$dti, ">=", 
                max(-999, sett$filters$am_lower, na.rm = T))) %>% 
  filter_(paste(sett$col_names$dti, "<=", 
                min(999, sett$filters$am_upper, na.rm = T))) 

## Create new column for absolute acc. lat.
dat[, sett$col_names$measure_acc_lat_abs] <- 
  abs(dat[, sett$col_names$measure_acc_lat])



# Visualize speed profiles ------------------------------------------------

plot_speed <- 
  ggplot() + 
  geom_line(data = dat,
            aes_string(x = sett$col_names$am,
                       y = sett$col_names$measure_speed,
                       group = sett$col_names$id),
            size = 0.2) + 
  facet_grid(as.formula(
    paste(".", "~", 
          sett$col_names$condition_speed))) +
  coord_cartesian(y = c(0, 100),
                  expand = c(0, 0))

#windows(); plot(plot_profile)



# Extract max. lat. acc. while turning ------------------------------------

## Compute summary
temp_groups <- 
  c(sett$col_names$id,
    sett$col_names$pxx,
    sett$col_names$subject,
    sett$col_names$condition_speed,
    sett$col_names$condition_run,
    sett$col_names$condition_vip
  )

temp_values <- 
  c(sett$col_names$measure_acc_lat_abs)

dat_acc_lat <- 
  computeSummary(
    dat %>% 
      filter_(paste(sett$col_names$am, ">=", 
                    max(-999, sett$filters$am_lower_precise, na.rm = T))) %>% 
      filter_(paste(sett$col_names$am, "<=", 
                    min(999, sett$filters$am_upper_precise, na.rm = T))),
    col_names_group = temp_groups,
    col_names_values = temp_values)

## Aggregate results from summary
temp_groups <- 
  c(sett$col_names$pxx,
    sett$col_names$subject,
    sett$col_names$condition_speed,
    sett$col_names$condition_vip
  )

dat_acc_lat_max_aggr <- 
  computeSummary(dat_acc_lat,
                 col_names_group = temp_groups,
                 col_names_values = "max")



# Enrich speed profiles with positions of max. lat. acc. ------------------

dat_speed_acc_lat <- 
  left_join(dat %>% 
              select_(sett$col_names$id,
                      sett$col_names$condition_run,
                      sett$col_names$condition_speed,
                      sett$col_names$dti,
                      sett$col_names$tti,
                      sett$col_names$measure_acc_lat_abs,
                      sett$col_names$measure_speed,
                      "gps_lat",
                      "gps_lon"),
            dat_acc_lat %>% 
              select_(sett$col_names$id,
                      "max")) %>% 
  group_by_(sett$col_names$id) %>% 
  filter_(paste(sett$col_names$measure_acc_lat_abs, "==", "max")) %>% 
  filter(row_number() == 1)



# Visualize enriched speed profiles ---------------------------------------

plot_speed_acc_lat <- 
  plot_speed + 
  geom_point(data = dat_speed_acc_lat,
             aes_string(x = sett$col_names$am,
                        y = sett$col_names$measure_speed,
                        group = sett$col_names$id),
             color = "red")

windows(); plot(plot_speed_acc_lat)



# Write to database -------------------------------------------------------

## Summary
sett$table_names$summary <- 
  paste_("t_adtf_results",
         sprintf("p%02d", sett$filters$pxx),
         sett$col_names$am,
         "acc_lat_summary")

dbWriteTable(get(sett$db$conn_names$study2),
             name = sett$table_names$summary,
             dat_acc_lat,
             row.names = F,
             overwrite = T)

## Summary aggregated across runs
sett$table_names$summary <- 
  paste_("t_adtf_results",
         sprintf("p%02d", sett$filters$pxx),
         sett$col_names$am,
         "acc_lat_max_aggr")

dbWriteTable(get(sett$db$conn_names$study2),
             name = sett$table_names$summary,
             dat_acc_lat_max_aggr,
             row.names = F,
             overwrite = T)

sett$table_names$max <- 
  paste_("t_adtf_results",
         sprintf("p%02d", sett$filters$pxx),
         sett$col_names$am,
         "acc_lat_max_with_am")

dbWriteTable(get(sett$db$conn_names$study2),
             name = sett$table_names$max,
             dat_speed_acc_lat,
             row.names = F,
             overwrite = T)

