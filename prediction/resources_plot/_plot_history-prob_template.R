
## Avoid additional space to axis
par(xaxs = "i", yaxs = "i")

## Draw empty plot
plot(x = 0, 
     y = 0, 
     xlim = c(sett_plot$xmin, sett_plot$xmax), 
     ylim = c(-0.05,1.05),
     col = "white",
     xlab = "Distance to intersection (m)",
     ylab = "Probability",
     font.lab = 2)

## Left-align title
title(expression(bold("History of P(H"["i"]*"|v(t),s(t))")),
      adj = 0)

## BN Version
mtext(text = 
         paste("Version:",
               sett_pred$bn_version),
      line = 1,
      side = 3,
      adj = 1,
      cex = 1)

## BN evidence
mtext(text =
         paste("Evidence:", 
               paste(sett_pred$bn_evidence$print, collapse = "; ")),
      line = 0,
      side = 3,
      adj = 1,
      cex = 1)


## Draw lines for object positions
abline(v = sett_sim$obj_pos[2], 
       col = "orange", 
       lty = "dotted")
abline(v = sett_sim$obj_pos[4], 
       col = "#B9539F", 
       lty = "dotted")

## Draw legend
legend(x = sett_plot$xmin + 1.6, 
       y = 1 - 0.025,
       title = expression(bold("Intent probability")),
       title.adj = 0.1,
       c("Go straight", 
         "Stop at stop line", 
         "Turn", 
         "Turn but stop"),
       lty = c("solid", 
               "solid", 
               "solid", 
               "solid"),
       col = c("#6FCDDD", 
               "orange", 
               "#ED2125", 
               "#B9539F"),
       bg = "grey92")

plot_template4probhist <- recordPlot()

replayPlot(plot_template4probhist)
