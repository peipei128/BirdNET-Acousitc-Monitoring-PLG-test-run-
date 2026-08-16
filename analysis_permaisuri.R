library(dplyr)
library(ggplot2)
library(lubridate)

# 1. Read the CSV
df <- read.csv(file.choose())

# 2. Manually set the recording start time and calculate the actual time of each detection
recording_start <- ymd_hms("2026-08-15 09:50:00")

df$Detection_Start_Time <- recording_start + seconds(df$Start..s.)
df$Detection_End_Time   <- recording_start + seconds(df$End..s.)
df$Elapsed_Min <- as.numeric(difftime(df$Detection_Start_Time, recording_start, units = "mins"))

# 3. Species richness
richness <- n_distinct(df$Common.name)
richness

# 4. Relative abundance
abundance <- df %>%
  count(Common.name, name = "Detections") %>%
  mutate(Relative_Abundance = Detections / sum(Detections)) %>%
  arrange(desc(Relative_Abundance))
abundance

# 5. Changes in detections during the recording (grouped into 5-minute intervals)
activity <- df %>%
  mutate(Time_Bin = floor(Elapsed_Min / 5) * 5) %>%
  count(Time_Bin, name = "Detections")

ggplot(activity, aes(x = Time_Bin, y = Detections)) +
  geom_col(fill = "darkgreen") +
  labs(title = "Changes in the number of detections throughout the recording",
       x = "Elapsed recording time (minutes)", y = "Number of detections") +
  theme_minimal()

# 6. Number of detections for each species during each time interval (which species is calling & when)
species_time <- df %>%
  mutate(Time_Bin = floor(Elapsed_Min / 5) * 5) %>%
  count(Time_Bin, Common.name, name = "Detections")

ggplot(species_time, aes(x = Time_Bin, y = Common.name, fill = Detections)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "white", high = "darkred") +
  labs(title = "Active Periods of Each Species During the Recording",
       x = "Elapsed Recording Time (minutes)", y = NULL, fill = "Number of Detections") +
  theme_minimal()

# 7. Number of bird species active during each time interval (to determine whether multiple species are calling simultaneously or a single species is responsible for a detection burst)
richness_over_time <- df %>%
  mutate(Time_Bin = floor(Elapsed_Min / 5) * 5) %>%
  group_by(Time_Bin) %>%
  summarise(Species_Count = n_distinct(Common.name),
            Total_Detections = n())

richness_over_time

ggplot(richness_over_time, aes(x = Time_Bin, y = Species_Count)) +
  geom_col(fill = "steelblue") +
  labs(title = "Number of Species Active During Each Time Interval",
       x = "Elapsed Recording Time (minutes)", y = "Number of Species") +
  theme_minimal()

# 8. Check Black-headed Ibis reliability (this species was not observed in the field, so it was very likely a misidentification)
df %>%
  filter(Common.name == "Black-headed Ibis") %>%
  summarise(min_conf = min(Confidence), mean_conf = mean(Confidence), max_conf = max(Confidence))

# List the detections with highest/lowest confidence scores for easier verification against the original recordings (Start..s. refers to the timestamp in seconds in the original file and can be used directly to locate the relevant section by dragging the playback bar)
df %>%
  filter(Common.name == "Black-headed Ibis") %>%
  arrange(desc(Confidence)) %>%
  select(Common.name, Confidence, Start..s.) %>%
  head(5)

df %>%
  filter(Common.name == "Black-headed Ibis") %>%
  arrange(Confidence) %>%
  select(Common.name, Confidence, Start..s.) %>%
  head(5)

# 9. Recalculate richness / abundance after applying the confidence-score threshold to see whether the results change substantially
df_filtered <- df %>% filter(Confidence >= 0.5)

richness_filtered <- n_distinct(df_filtered$Common.name)
richness_filtered

abundance_filtered <- df_filtered %>%
  count(Common.name, name = "Detections") %>%
  mutate(Relative_Abundance = Detections / sum(Detections)) %>%
  arrange(desc(Relative_Abundance))
abundance_filtered

# 10. Use the same method to check Cattle Egret (also appears almost continuously and accounts for a high proportion of detections, worth verifying)
df %>%
  filter(Common.name == "Cattle Egret") %>%
  summarise(min_conf = min(Confidence), mean_conf = mean(Confidence), max_conf = max(Confidence))

df %>%
  filter(Common.name == "Cattle Egret") %>%
  arrange(desc(Confidence)) %>%
  select(Common.name, Confidence, Start..s.) %>%
  head(5)

# 11. Manually verify & confirm Black-headed Ibis detections were misidentified children's shouting, while some Cattle Egret detections were misidentified other noise, exclude them entirely;
# at the same time, apply confidence >= 0.5 threshold to filter out other low-confidence single detections
df_final <- df %>%
  filter(!Common.name %in% c("Black-headed Ibis", "Cattle Egret"), Confidence >= 0.5)

richness_final <- n_distinct(df_final$Common.name)
richness_final

abundance_final <- df_final %>%
  count(Common.name, name = "Detections") %>%
  mutate(Relative_Abundance = Detections / sum(Detections)) %>%
  arrange(desc(Relative_Abundance))
abundance_final

# 12. Replot 3 figures using cleaned data (df_final) after excluding misidentified detections, ensuring they match the final richness/abandance values
activity_final <- df_final %>%
  mutate(Time_Bin = floor(Elapsed_Min / 5) * 5) %>%
  count(Time_Bin, name = "Detections")

ggplot(activity_final, aes(x = Time_Bin, y = Detections)) +
  geom_col(fill = "darkgreen") +
  labs(title = "Changes in the number of detections throughout the recording (cleaned)",
       x = "Elapsed recording time (minutes)", y = "Number of detections") +
  theme_minimal()

species_time_final <- df_final %>%
  mutate(Time_Bin = floor(Elapsed_Min / 5) * 5) %>%
  count(Time_Bin, Common.name, name = "Detections")

ggplot(species_time_final, aes(x = Time_Bin, y = Common.name, fill = Detections)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "white", high = "darkred") +
  labs(title = "Active Periods of Each Species During the Recording (cleaned)",
       x = "Elapsed Recording Time (minutes)", y = NULL, fill = "Number of Detections") +
  theme_minimal()

richness_over_time_final <- df_final %>%
  mutate(Time_Bin = floor(Elapsed_Min / 5) * 5) %>%
  group_by(Time_Bin) %>%
  summarise(Species_Count = n_distinct(Common.name),
            Total_Detections = n())

richness_over_time_final

ggplot(richness_over_time_final, aes(x = Time_Bin, y = Species_Count)) +
  geom_col(fill = "steelblue") +
  labs(title = "Number of Species Active During Each Time Interval (cleaned)",
       x = "Elapsed Recording Time (minutes)", y = "Number of Species") +
  theme_minimal()