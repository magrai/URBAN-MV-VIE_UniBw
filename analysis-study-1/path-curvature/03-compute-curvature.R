
# Preparatory settings ----------------------------------------------------

sett_proc <- c()
sett_proc$objname <- "dat_med"
sett_proc$colname4gps_lon_conv <- "gps_lon_med_smooth_xy"
sett_proc$colname4gps_lat_conv <- "gps_lat_med_smooth_xy"
sett_proc$seqlength <- 11 ## Must be uneven
## Info: Resulting number of radius values will be nrow(data) - seglength
sett_proc$rfilter <- 100

## Create data copy
dat4curv <- get(sett_proc$objname)

## In case of duplicate values create mini-mini-mini-deviations
## Otherwise circum for computing radius won't work
dat4curv[, sett_proc$colname4gps_lon_conv] <-
  jitter( dat4curv[, sett_proc$colname4gps_lon_conv], factor = 1/10^10)
dat4curv[, sett_proc$colname4gps_lat_coZnv] <-
  jitter( dat4curv[, sett_proc$colname4gps_lat_conv], factor = 1/10^10)



# Compute radius ----------------------------------------------------------

radius <- computeRadius_batch(dat4curv[, sett_proc$colname4gps_lon_conv], 
                              dat4curv[, sett_proc$colname4gps_lat_conv], 
                              sett_proc$seqlength,
                              output = F)

test <- function(x, y, seq_length, output = T) {
  ## Initialise collector
  coll <- c()
  
  ## Loop through data
  i = 1
  while (i <= length(x) - 2 * seq_length) {
    indexes <- c(i, i + seq_length, i + 2* seq_length)
    x_temp <- x[indexes]
    y_temp <- y[indexes]
    radius <- circum(x_temp, y_temp)$radius 
    coll_temp <- data.frame(i = i, r = radius)
    i = i + 1
    coll <- rbind(coll, coll_temp)
  }
  return(coll)
}

dat4curv <- get(sett_proc$objname)
t <- test(dat4curv[, sett_proc$colname4gps_lon_conv], 
          dat4curv[, sett_proc$colname4gps_lat_conv],
          10)
plot(t$r, type = "l", ylim = c(0, 100000))
abline(a=15000, b=0)
t$r[t$r >]
dat4curv <- dat4curv[1:(nrow(dat4curv) - 2 * 100), ]
ggplot() + 
  geom_path(data = dat4curv, aes(x=gps_lon_med, y=gps_lat_med), size=2)  
  + geom_path(data = dat4curv, aes(x=gps_lon_med, y=gps_lat_med), size=2, 
              color="yellow", alpha=( t$r - min(t$r) ) / ( max(t$r) - min(t$r) ))


curv <- sapply(1/t$r, function(x) min(x, 100))

# radius_alt <- radius
# 
# # radius <- computeRadius_batch(dat4curv[, "gps_lon_med"], 
# #                                dat4curv[, "gps_lat_med"], 
# #                                sett_proc$seqlength,
# #                                output = F)
# # 
# # dat4curv_curv_alt <- dat4curv_curv


# Smooth and plot radius values -------------------------------------------

## Settings for plot combination (including next step)
par(mfrow = c(4, 1), oma=c(0,0,2,0))

## Plot original values
plot(radius, type = "l", main = paste("Radius with seqlength =", sett_proc$seqlength))
title(paste("Intersection #", sett_proc$sxx, sep = ""), outer=TRUE)

## Filter values
radius.filtered <- radius
#coll.filtered[coll.filtered > set4curv$thresh] <- set4curv$thresh
radius.filtered[radius.filtered > sett_proc$rfilter] <- sett_proc$rfilter

## Plot filtered values
plot(radius.filtered, type = "l", main = "Filtered radius")

## Remember maximum value
radius.filtered_max <- max(radius.filtered)

## Create and predict smooth model
model <- loess(radius.filtered ~ c(1:length(radius.filtered)), span = 1/10, degree = 1)
radius.filtered.smooth <- predict(model, c(1:length(radius.filtered)))

## In case of overfitting: Adjust peak values to original maximum
radius.filtered.smooth[which(radius.filtered.smooth > radius.filtered_max)] <- radius.filtered_max

## Plot smoothed values
plot(radius.filtered, type = "l", main = "Smoothed radius values (span = 1/10, degree = 1)")
lines(radius.filtered.smooth, col = "red")

## Compute curvature
curv <- 1 / radius.filtered.smooth
#curv <- curv^(1/3)
#curv <- curv^2

## Plot curvature values
plot(curv, type = "l", main = "Adjusted curvature")

## Reset of plot settings
par(mfrow = c(1, 1)) 



# Merge with data ---------------------------------------------------------

# row_first <- ceiling(sett_proc$seqlength/2)
# row_last <- nrow(dat4curv) - floor(sett_proc$seqlength/2)
#dat4curv_curv <- cbind(dat4curv[c(row_first:row_last), ], curv)
dat4curv_curv <- cbind(dat4curv, curv)

yellowness <- ( curv - min(curv) ) / ( max(curv) - min(curv) )



# Visualise ---------------------------------------------------------------

plotcurv <-
  ggplot() +
  geom_path(data = dat4curv_curv,
            aes_string(x = sett_proc$colname4gps_lon_conv,
                       y = sett_proc$colname4gps_lat_conv),
            size = 2) +
  geom_path(data = dat4curv_curv,
            aes_string(x = sett_proc$colname4gps_lon_conv,
                       y = sett_proc$colname4gps_lat_conv),
                #alpha = curv.rollmean),
                alpha = yellowness^(1/3.5),
            #alpha = test.z3),
            colour = "yellow",
            #alpha = dat2plottest$curv.adj.rollmean.z,
            size = 2) +
  guides(alpha = F)+
  coord_cartesian(xlim = sett_proc$xlim,
                  ylim = sett_proc$ylim) #+
 # ggtitle(paste("kwidth:", sett_proc$kwidth, "+ treshold:", sett_proc$thresh))

plot(plotcurv)

# ggsave(paste(sprintf("s%02d", sett_proc$sxx),
#              "_seg", sett_proc$seglength,
#              "_xydist.smoothed.curv.pdf", sep = ""),
#        plotcurv,
#        path = "plots",
#        dpi = 300,
#        width = 20,
#        height = 10,
#        units = "cm")
# 
# ggsave(paste(sprintf("s%02d", sett_proc$sxx),
#              "_seg", sett_proc$seglength,
#              "_xydist.smoothed.curv.svg", sep = ""),
#        plotcurv,
#        path = "plots",
#        dpi = 300,
#        width = 20,
#        height = 10,
#        units = "cm")



