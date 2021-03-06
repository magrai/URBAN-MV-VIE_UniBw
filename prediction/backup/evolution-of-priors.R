

# Run prediction for single position --------------------------------------

sett_proc$carryout_am_single <- -25
#sett_proc$carryout_am_single <- sample(dat_test[, sett_dat$col_name_am], 1)
source("analysis-study-1/prediction_dev/load-test-data.R")
source("analysis-study-1/prediction_dev/pred-single.R")



# Run prediction for group pf passings -------------------------------------

dat_pred_results_coll_overall <- c()
for (case in sett_dat$cases) {
  #for (case in sett_dat$case) {
  sett_dat$case <- case
  outputString(paste("* Currently processing:", case))
  source("analysis-study-1/prediction_dev/load-test-data.R", print.eval = F)
  source("analysis-study-1/prediction_dev/pred-complete.R")
}


# Print evolution of prior ------------------------------------------------

dat_pred_results_coll_overall_avg <- 
  dat_pred_results_coll_overall %>% 
  mutate(Intent34 = Intent3 + Intent4) %>% 
  group_by_(sett_dat$col_name_am) %>% 
  summarise_all(funs(mean(., na.rm = TRUE)))

graphics.off()
ggplot() + 
  geom_line(data = dat_pred_results_coll_overall,
            aes_string(x = sett_dat$col_name_am,
                       y = "Intent1",
                       group = sett_dat$col_name_group),
            color = "#6FCDDD",
            alpha = 0.25) +
  geom_line(data = dat_pred_results_coll_overall_avg,
            aes_string(x = sett_dat$col_name_am,
                       y = "Intent1"),
            size = 2,
            color = "#6FCDDD") + 
  geom_line(data = dat_pred_results_coll_overall,
            aes_string(x = sett_dat$col_name_am,
                       y = "Intent2",
                       group = sett_dat$col_name_group),
            color = "orange",
            alpha = 0.25) +
  geom_line(data = dat_pred_results_coll_overall_avg,
            aes_string(x = sett_dat$col_name_am,
                       y = "Intent2"),
            size = 2,
            color = "orange") + 
  geom_line(data = dat_pred_results_coll_overall,
            # %>% filter(passing == "p04_stress_s02"),
            aes_string(x = sett_dat$col_name_am,
                       y = "Intent3",
                       group = sett_dat$col_name_group),
            color = "#ED2125",
            alpha = 0.25) +
  geom_line(data = dat_pred_results_coll_overall_avg,
            aes_string(x = sett_dat$col_name_am,
                       y = "Intent3"),
            size = 2,
            color = "#ED2125") + 
  ###
  geom_line(data = dat_pred_results_coll_overall,
            aes_string(x = sett_dat$col_name_am,
                       y = "Intent3 + Intent4",
                       group = sett_dat$col_name_group),
            color = "#ED2125",
            alpha = 0.25,
            linetype = "dashed") +
  geom_line(data = dat_pred_results_coll_overall_avg,
            aes_string(x = sett_dat$col_name_am,
                       y = "Intent34"),
            size = 2,
            color = "#ED2125",
            linetype = "dashed") + 
  # facet_grid(passing~.) + 
  # geom_line(data = dat_pred_results_coll_overall,
  #           aes(x = pos4carryout,
  #               y = Intent4,
  #               group = passing),
  #           color = "#B9539F",
  #           alpha = 0.5) +
  # geom_line(data = dat_pred_results_coll_overall_avg,
  #           aes(x = pos4carryout,
  #               y = Intent4),
  #           size = 2,
#           color = "#B9539F") + 
coord_cartesian(ylim = c(0, 1)) +
  scale_x_continuous(expand = c(0, 0)) +
  theme_bw()


## Idea
## Plot envelope


# plot(x = coll4prior$s, y = coll4prior$X1, type = "l", col = "blue", ylim = c(0,1), main = "PriorDev")
# lines(x = coll4prior$s, coll4prior$X2, col = "orange")
# lines(x = coll4prior$s, coll4prior$X3, col = "red")
# lines(x = coll4prior$s, coll4prior$X4, col = "magenta")