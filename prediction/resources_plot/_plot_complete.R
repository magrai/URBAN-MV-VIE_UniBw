
## Visualise simulated speed profiles
dev.set(3)
source("prediction/resources_plot/_plot_simulation.R")

## Visualize simulated speed values
dev.set(4)
source("prediction/resources_plot/_plot_simulation_speed.R")


## Visualize simulated distance values
dev.set(5)
source("prediction/resources_plot/_plot_simulation_distance.R")


## Visualise current intent probabilites
dev.set(7)
source("prediction/resources_plot/_plot_current-prob.R")


## Visualise history of intent probabilities
dev.set(8)
source("prediction/resources_plot/_plot_history-prob.R")





## Dummy window to avoid flickering
## Must be called as last device
dev.set(2)