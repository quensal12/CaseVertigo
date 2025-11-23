library(ggplot2)
library(dplyr)
library(tidyr)

# Constants & Assumptions
DAILY_INSTALLS <- 20000
ASSUMED_ARPPU  <- 5.0

# Variant Metrics
metrics <- list(
  A = list(purchase_ratio = 0.0305, ecpm = 9.80, ad_imp_dau = 2.3),
  B = list(purchase_ratio = 0.0315, ecpm = 10.80, ad_imp_dau = 1.6)
)

# Retention Data Points
days_obs <- c(1, 3, 7, 14)
ret_A_obs <- c(0.53, 0.27, 0.17, 0.06)
ret_B_obs <- c(0.48, 0.25, 0.19, 0.09)

# 2. MODELING
# Power Law Model to predict missing days.

fit_model <- function(x_vals, y_vals) {
  nls(y ~ a * x^b, 
      data = data.frame(x = x_vals, y = y_vals), 
      start = list(a = 0.5, b = -0.5))
}

# Models
model_A <- fit_model(days_obs, ret_A_obs)
model_B <- fit_model(days_obs, ret_B_obs)

# Prediction for 30 days  
days_seq <- 1:30
pred_A <- predict(model_A, newdata = data.frame(x = days_seq))
pred_B <- predict(model_B, newdata = data.frame(x = days_seq))

# Day 0 (%100 Retention)
curve_A <- c(1.0, pred_A)
curve_B <- c(1.0, pred_B)

# 3. SIMULATION:DAU and Revenue day-by-day using Cohort Analysis.

run_simulation <- function(days_limit = 30, scenario = "base") {

  results <- list()
  
  for (variant in c("A", "B")) {
    base_curve <- if(variant == "A") curve_A else curve_B
    m <- metrics[[variant]]
    
    if(is.null(m$purchase_ratio)) stop(paste("Variant Error"))
    if(is.null(m$ad_imp))  stop(paste("Variant Error"))
    # Generate "New Source" Curve for (e)
    # Formula: A: 0.58*exp(-0.12*(x-1)), B: 0.52*exp(-0.10*(x-1))
    new_source_curve <- numeric(31)
    new_source_curve[1] <- 1.0
    for(d in 1:30) {
      if(variant == "A") new_source_curve[d+1] <- 0.58 * exp(-0.12 * (d - 1))
      else               new_source_curve[d+1] <- 0.52 * exp(-0.10 * (d - 1))
    }
    
    daily_dau <- numeric(days_limit)
    daily_rev <- numeric(days_limit)
    
    # TIME LOOP
    for (current_day in 1:days_limit) {
      dau_today <- 0
      
      # COHORT LOOP
      for (install_day in 1:current_day) {
        age <- current_day - install_day # Days since install
        if (age > 30) next
        
        # LOGIC FOR SCENARIO (e): NEW USER SOURCE
        # "On Day 20: 12k old + 8k new"
        if (scenario == "new_source" && install_day >= 20) {
          survivors <- (12000 * base_curve[age + 1]) + (8000 * new_source_curve[age + 1])
        } else {
          # Standard: 20k users on the base curve
          survivors <- DAILY_INSTALLS * base_curve[age + 1]
        }
        
        dau_today <- dau_today + survivors
      }
      
      daily_dau[current_day] <- dau_today
      
      #REVENUE CALCULATION
      current_p_ratio <- m$purchase_ratio
      
      # LOGIC FOR SCENARIO (d): SALE
      # "10-day sale starting on Day 15"
      if (scenario == "sale" && current_day >= 15 && current_day <= 24) {
        current_p_ratio <- current_p_ratio + 0.01
      }
      
      iap_revenue <- dau_today * current_p_ratio * ASSUMED_ARPPU
      ad_revenue  <- dau_today * m$ad_imp * (m$ecpm / 1000)
      
      daily_rev[current_day] <- iap_revenue + ad_revenue
    }
    
    results[[variant]] <- list(
      dau_final = daily_dau[days_limit], # DAU on the last day
      dau_history = daily_dau,           # Full DAU history array
      rev_total = sum(daily_rev),        # Cumulative Revenue sum
      rev_history = cumsum(daily_rev)    # Cumulative Revenue history array
    )
  }
  return(results)
 
}


# 4. RESULTS 

# Simulations for all scenarios
sim_base <- run_simulation(30, scenario = "base")
sim_sale <- run_simulation(30, scenario = "sale")
sim_new  <- run_simulation(30, scenario = "new_source")


# Question a:
dau_15_A <- sim_base$A$dau_history[15]
dau_15_B <- sim_base$B$dau_history[15]

# Question b:
rev_15_A <- sim_base$A$rev_history[15]
rev_15_B <- sim_base$B$rev_history[15]

# Question c:
rev_30_A <- sim_base$A$rev_total
rev_30_B <- sim_base$B$rev_total

# Question d:
sale_30_A <- sim_sale$A$rev_total
sale_30_B <- sim_sale$B$rev_total

# Question e:
new_30_A <- sim_new$A$rev_total
new_30_B <- sim_new$B$rev_total

# Question f:
gain_sale_A <- sale_30_A - rev_30_A
gain_new_A  <- new_30_A - rev_30_A
