library(tidyverse)
library(lubridate)
library(scales)
library(ggplot2)


file_list <- list.files(pattern = "*.csv", recursive = TRUE, full.names = TRUE)

# Read and merge all CSVs
df_raw <- map_dfr(file_list, read_csv, show_col_types = FALSE)

# Data Cleaning
df_clean <- df_raw %>%
  # A. Convert Dates
  mutate(
    event_date = as.Date(event_date),
    install_date = as.Date(install_date)
  ) %>%
  # B. Remove rows with invalid dates 
  filter(!is.na(event_date), !is.na(install_date)) %>%
  # C. Handle Missing Country Data (CRITICAL STEPP)
  # Instead of dropping rows, I label missing countries as "Unknown" to preserve revenue data.
  mutate(
    country = replace_na(country, "Unknown"),
    
    # D. Create Calculated Metrics
    days_since_install = as.numeric(event_date - install_date),
    total_revenue = iap_revenue + ad_revenue,
    duration_min = total_session_duration / 60 
  )

unknown_count <- sum(df_clean$country == "Unknown")
cat(sprintf("Info: %s rows had missing country data and were labeled as 'Unknown'.\n", comma(unknown_count)))


# ==============================================================================
# ANALYSIS 1: USER SEGMENTATION (Based on Day 0 Behavior)
# Hypothesis: Users who play more on their first day are more valuable.

# Filter for Day 0 (Install Day) activity
day0_data <- df_clean %>%
  filter(days_since_install == 0)

# Define Segments using Quartiles (33% and 66%)
cutoffs <- quantile(day0_data$total_session_duration, probs = c(0.33, 0.66))

day0_segmented <- day0_data %>%
  mutate(
    segment = case_when(
      total_session_duration <= cutoffs[1] ~ "Low Engagement",
      total_session_duration <= cutoffs[2] ~ "Medium Engagement",
      TRUE ~ "High Engagement"
    )
  )

# Calculate KPIs per Segment
segment_summary <- day0_segmented %>%
  group_by(segment) %>%
  summarise(
    User_Count = n(),
    Avg_Revenue = mean(total_revenue),
    Avg_Matches = mean(match_end_count),
    Avg_Duration_Min = mean(duration_min)
  ) %>%
  arrange(desc(Avg_Revenue))

print("--- SEGMENTATION RESULTS (DAY 0) ---")
print(segment_summary)

# VISUALIZATION 1: Revenue by Segment
p1 <- ggplot(segment_summary, aes(x = reorder(segment, Avg_Revenue), y = Avg_Revenue, fill = segment)) +
  geom_col() +
  labs(title = "Average Revenue by Day 0 Engagement",
       subtitle = "High Engagement users generate significantly more revenue",
       x = "Segment", y = "Avg Revenue per User ($)") +
  theme_minimal() +
  theme(legend.position = "none")

print(p1)

# ==============================================================================

# ANALYSIS 2: TREND ANALYSIS (Session Duration Over Time)

trend_data <- df_clean %>%
  filter(days_since_install >= 0, days_since_install <= 30) %>% # Focus on first 30 days
  group_by(days_since_install) %>%
  summarise(
    Avg_Duration_Sec = mean(total_session_duration),
    Active_Users = n_distinct(user_id)
  )

# VISUALIZATION 2: Session Duration Trend
p2 <- ggplot(trend_data, aes(x = days_since_install, y = Avg_Duration_Sec)) +
  geom_line(color = "#2c3e50", size = 1.2) +
  geom_point(color = "#e74c3c", size = 2) +
  geom_smooth(method = "loess", se = FALSE, color = "blue", linetype = "dashed") +
  labs(title = "Average Session Duration Trend (First 30 Days)",
       subtitle = "Duration peaks at install and stabilizes after Day 4",
       x = "Days Since Install", y = "Avg Duration (Seconds)") +
  theme_minimal()

print(p2)

# ==============================================================================
# 5. ANALYSIS 3: MONETIZATION BY PLATFORM & COUNTRY

# Platform Analysis
platform_stats <- df_clean %>%
  group_by(platform) %>%
  summarise(
    Total_Revenue = sum(total_revenue),
    Avg_Rev_Per_User = sum(total_revenue) / n_distinct(user_id),
    User_Count = n_distinct(user_id)
  )

print("--- PLATFORM STATS ---")
print(platform_stats)

# VISUALIZATION 3: Platform Revenue Share
p3 <- ggplot(platform_stats, aes(x = "", y = Total_Revenue, fill = platform)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  labs(title = "Total Revenue Share by Platform") +
  theme_void() +
  scale_fill_brewer(palette = "Set1")

print(p3)

# Country Analysis (Top 10)
# Note: I include 'Unknown' in the dataset, but it might be filtered out for the Top 10 chart
# if we only want to see specific countries. Here, we keep it to be transparent.
top_countries <- df_clean %>%
  group_by(country) %>%
  summarise(Total_Revenue = sum(total_revenue)) %>%
  arrange(desc(Total_Revenue)) %>%
  head(10)

# VISUALIZATION 4: Top Countries
p4 <- ggplot(top_countries, aes(x = reorder(country, Total_Revenue), y = Total_Revenue)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 10 Countries by Revenue",
       x = "Country", y = "Total Revenue ($)") +
  theme_minimal()

print(p4)