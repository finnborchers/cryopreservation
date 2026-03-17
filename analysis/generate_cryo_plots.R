#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(readr)
})

# readxl is needed only for the Vi-CELL workbook.
if (!requireNamespace("readxl", quietly = TRUE)) {
  if (requireNamespace("readxl", quietly = TRUE, lib.loc = "/tmp/rlib")) {
    .libPaths(c("/tmp/rlib", .libPaths()))
  } else {
    stop("Package 'readxl' is required. Install it or export CryolabA1.xls to CSV.")
  }
}
suppressPackageStartupMessages(library(readxl))

in_temp <- if (file.exists("data/Temperaturmessungen_A1.csv")) {
  "data/Temperaturmessungen_A1.csv"
} else {
  "Group_A1/Temperaturmessungen_A1.csv"
}

in_vicell <- if (file.exists("data/CryolabA1.xls")) {
  "data/CryolabA1.xls"
} else {
  "Group_A1/CryolabA1.xls"
}

out_dir <- if (dir.exists("analysis/figures")) {
  "analysis/figures"
} else {
  "analysis_outputs/figures"
}
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

fill_na_linear <- function(x) {
  ok <- which(!is.na(x))
  if (length(ok) == 0) return(x)
  if (length(ok) == 1) return(rep(x[ok], length(x)))
  approx(ok, x[ok], xout = seq_along(x), method = "linear", rule = 2)$y
}

first_idx <- function(x, cond_fun) {
  w <- which(cond_fun(x))
  if (length(w) == 0) return(NA_integer_)
  w[1]
}

detect_ln2_plunge_index <- function(x, t, search_start_s = 2400, drop_window_s = 4, drop_threshold_c = -15) {
  start_i <- first_idx(t, function(v) v >= search_start_s)
  if (is.na(start_i)) return(NA_integer_)

  max_i <- length(x) - drop_window_s
  if (start_i > max_i) return(NA_integer_)

  for (i in seq(start_i, max_i)) {
    w <- x[i:(i + drop_window_s)]
    if (any(is.na(w))) next
    if ((w[length(w)] - w[1]) <= drop_threshold_c) {
      return(i + 1)
    }
  }
  NA_integer_
}

detect_thaw_start_index <- function(x, min_i, rise_window_s = 10, rise_threshold_c = 20) {
  if (is.na(min_i)) return(NA_integer_)
  max_i <- length(x) - rise_window_s
  if (min_i >= max_i) return(min_i)

  for (i in seq(min_i, max_i)) {
    w <- x[i:(i + rise_window_s)]
    if (any(is.na(w))) next
    if ((w[length(w)] - w[1]) >= rise_threshold_c) {
      return(i)
    }
  }
  min_i
}

parse_start_time <- function(path) {
  header <- readLines(path, n = 8, encoding = "UTF-8")
  start_line <- header[str_detect(header, "^Startzeit:")][1]
  if (is.na(start_line)) {
    stop("Could not parse 'Startzeit' from temperature CSV header.")
  }
  start_txt <- str_trim(str_remove(start_line, "^Startzeit:\\s*"))
  as.POSIXct(strptime(start_txt, format = "%d.%m.%Y %H:%M:%S", tz = "Europe/Berlin"))
}

detect_nucleation_event <- function(df_channel, start_dt) {
  x <- fill_na_linear(df_channel$temperature_clean)
  t <- df_channel$time_s

  end_i <- first_idx(x, function(v) !is.na(v) & v <= -40)
  if (is.na(end_i)) end_i <- length(x)

  best <- NULL
  upper_i <- max(4, end_i - 35)

  for (i in seq(4, upper_i)) {
    t0 <- x[i]
    if (is.na(t0) || t0 < -25 || t0 > -2) next
    if (!(t0 <= x[i - 1] && t0 <= x[i + 1])) next

    w_end <- min(i + 30, length(x))
    if (w_end <= i) next
    w <- x[(i + 1):w_end]
    peak_rel <- which.max(w)
    peak_temp <- w[peak_rel]
    rise <- peak_temp - t0
    if (rise < 1.5) next

    score <- rise - max(0, (-8 - t0)) * 0.02
    peak_i <- i + peak_rel
    cand <- list(score = score, nuc_i = i, peak_i = peak_i, rise = rise)
    if (is.null(best) || cand$score > best$score) best <- cand
  }

  if (is.null(best)) {
    return(tibble(
      channel = df_channel$channel[1],
      team = df_channel$team[1],
      solution = df_channel$solution[1],
      nucleation_index = NA_real_,
      nucleation_temp_c = NA_real_,
      peak_index = NA_real_,
      peak_temp_c = NA_real_,
      jump_delta_t_c = NA_real_,
      peak_rel_s = NA_real_,
      nucleation_time = NA_character_,
      peak_time = NA_character_
    ))
  }

  nuc_idx <- t[best$nuc_i]
  peak_idx <- t[best$peak_i]
  nuc_time <- start_dt + nuc_idx
  peak_time <- start_dt + peak_idx

  tibble(
    channel = df_channel$channel[1],
    team = df_channel$team[1],
    solution = df_channel$solution[1],
    nucleation_index = nuc_idx,
    nucleation_temp_c = x[best$nuc_i],
    peak_index = peak_idx,
    peak_temp_c = x[best$peak_i],
    jump_delta_t_c = best$rise,
    peak_rel_s = peak_idx - nuc_idx,
    nucleation_time = format(nuc_time, "%H:%M:%S"),
    peak_time = format(peak_time, "%H:%M:%S")
  )
}

collect_key_points <- function(df_channel, start_dt, nuc_row) {
  x <- fill_na_linear(df_channel$temperature_clean)
  t <- df_channel$time_s

  idx_for_threshold <- function(thresh, from_i = 1) {
    local <- first_idx(x[from_i:length(x)], function(v) !is.na(v) & v >= thresh)
    if (is.na(local)) return(NA_integer_)
    from_i + local - 1
  }

  point_row <- function(point_name, i_pos) {
    if (is.na(i_pos) || i_pos < 1 || i_pos > length(x)) {
      return(tibble(
        channel = df_channel$channel[1],
        team = df_channel$team[1],
        solution = df_channel$solution[1],
        point = point_name,
        sample_index = NA_real_,
        temperature_c = NA_real_,
        time_hms = NA_character_
      ))
    }
    abs_time <- start_dt + t[i_pos]
    tibble(
      channel = df_channel$channel[1],
      team = df_channel$team[1],
      solution = df_channel$solution[1],
      point = point_name,
      sample_index = t[i_pos],
      temperature_c = x[i_pos],
      time_hms = format(abs_time, "%H:%M:%S")
    )
  }

  start_i <- first_idx(x, function(v) !is.na(v))
  t40_i <- first_idx(x, function(v) !is.na(v) & v <= -40)
  t80_i <- first_idx(x, function(v) !is.na(v) & v <= -80)
  plunge_i <- detect_ln2_plunge_index(x, t, search_start_s = 2400)
  ctrl_end_i <- ifelse(is.na(plunge_i), NA_integer_, plunge_i - 1)
  min_i <- which.min(x)
  thaw_start_i <- detect_thaw_start_index(x, min_i)
  thaw0_i <- idx_for_threshold(0, from_i = min_i)
  thaw10_i <- idx_for_threshold(10, from_i = min_i)
  thaw20_i <- idx_for_threshold(20, from_i = min_i)

  nuc_i <- match(nuc_row$nucleation_index, t)
  peak_i <- match(nuc_row$peak_index, t)

  bind_rows(
    point_row("initial_loading", start_i),
    point_row("nucleation_onset", nuc_i),
    point_row("recalescence_peak", peak_i),
    point_row("controlled_end_pre_LN2", ctrl_end_i),
    point_row("freezing_endpoint_minus40", t40_i),
    point_row("freezing_endpoint_minus80", t80_i),
    point_row("deep_cold_minimum", min_i),
    point_row("thaw_start_detected", thaw_start_i),
    point_row("thaw_0C", thaw0_i),
    point_row("thaw_plus10C", thaw10_i),
    point_row("thaw_plus20C", thaw20_i)
  )
}

calc_metrics <- function(df_channel, nucleation_index, peak_index) {
  x <- df_channel$temperature_clean
  x_fill <- fill_na_linear(x)
  t <- df_channel$time_s

  start_i <- first_idx(x_fill, function(v) !is.na(v))
  t80_i <- first_idx(x_fill, function(v) !is.na(v) & v <= -80)
  nuc_i <- match(nucleation_index, t)
  if (is.na(nuc_i)) {
    nuc_i <- NA_integer_
  }
  peak_i <- match(peak_index, t)
  if (is.na(peak_i)) {
    peak_i <- NA_integer_
  }

  controlled_start_i <- first_idx(t, function(v) v >= 300) # minute 5
  controlled_end_i <- first_idx(t, function(v) v >= 2700) # minute 45
  if (is.na(controlled_end_i)) controlled_end_i <- length(t)

  min_i <- which.min(x_fill)
  thaw_start_i <- detect_thaw_start_index(x_fill, min_i)

  rate <- function(i1, i2) {
    if (is.na(i1) || is.na(i2) || t[i2] == t[i1]) return(NA_real_)
    (x_fill[i2] - x_fill[i1]) / ((t[i2] - t[i1]) / 60)
  }

  crossing_after_start <- function(threshold, start_i) {
    if (is.na(start_i) || start_i >= length(x_fill)) return(list(t_cross = NA_real_, i_cross = NA_integer_))
    if (!is.na(x_fill[start_i]) && x_fill[start_i] >= threshold) {
      return(list(t_cross = t[start_i], i_cross = start_i))
    }

    for (j in seq(start_i + 1, length(x_fill))) {
      a <- x_fill[j - 1]
      b <- x_fill[j]
      if (is.na(a) || is.na(b)) next
      if (a < threshold && b >= threshold) {
        frac <- ifelse(b == a, 0, (threshold - a) / (b - a))
        t_cross <- t[j - 1] + frac * (t[j] - t[j - 1])
        return(list(t_cross = t_cross, i_cross = j))
      }
    }
    list(t_cross = NA_real_, i_cross = NA_integer_)
  }

  c10 <- crossing_after_start(10, thaw_start_i)
  c20 <- crossing_after_start(20, thaw_start_i)
  thaw_dt_10_s <- ifelse(is.na(c10$t_cross), NA_real_, c10$t_cross - t[thaw_start_i])
  thaw_dt_20_s <- ifelse(is.na(c20$t_cross), NA_real_, c20$t_cross - t[thaw_start_i])
  thaw_dT_10 <- 10 - x_fill[thaw_start_i]
  thaw_dT_20 <- 20 - x_fill[thaw_start_i]
  thaw_rate_10 <- ifelse(is.na(thaw_dt_10_s) || thaw_dt_10_s <= 0, NA_real_, thaw_dT_10 / (thaw_dt_10_s / 60))
  thaw_rate_20 <- ifelse(is.na(thaw_dt_20_s) || thaw_dt_20_s <= 0, NA_real_, thaw_dT_20 / (thaw_dt_20_s / 60))

  tibble(
    invalid_points = sum(df_channel$is_invalid, na.rm = TRUE),
    start_temp = x_fill[start_i],
    temp_at_minus80 = ifelse(is.na(t80_i), NA_real_, x_fill[t80_i]),
    time_to_minus80_s = ifelse(is.na(t80_i), NA_real_, t[t80_i] - t[start_i]),
    cooling_rate_to_minus80_k_per_min = rate(start_i, t80_i),
    controlled_start_index_s = t[controlled_start_i],
    controlled_end_index_s = t[controlled_end_i],
    controlled_end_temp = x_fill[controlled_end_i],
    cooling_rate_controlled_k_per_min = rate(controlled_start_i, controlled_end_i),
    nucleation_temp_est = ifelse(is.na(nuc_i), NA_real_, x_fill[nuc_i]),
    time_to_nucleation_s = ifelse(is.na(nuc_i), NA_real_, t[nuc_i] - t[start_i]),
    cooling_rate_to_nucleation_k_per_min = rate(start_i, nuc_i),
    min_temp = x_fill[min_i],
    time_at_min_s = t[min_i],
    thaw_start_index_s = t[thaw_start_i],
    thaw_start_temp = x_fill[thaw_start_i],
    thaw_delta_temp_to_10_c = thaw_dT_10,
    thaw_time_to_10_s = thaw_dt_10_s,
    thaw_rate_to_10_k_per_min = thaw_rate_10,
    thaw_rate_to_20_k_per_min = thaw_rate_20
  )
}

# ----------------------
# Temperature time series
# ----------------------
temp <- read.delim(
  in_temp,
  sep = ";",
  dec = ",",
  skip = 6,
  header = TRUE,
  stringsAsFactors = FALSE,
  check.names = FALSE,
  fileEncoding = "UTF-8-BOM"
) %>%
  mutate(across(3:8, as.numeric)) %>%
  mutate(time_s = as.numeric(Messwert), time_min = time_s / 60)

start_dt <- parse_start_time(in_temp)

temp_long <- temp %>%
  pivot_longer(
    cols = 3:8,
    names_to = "channel",
    values_to = "temperature"
  ) %>%
  mutate(
    team = if_else(str_detect(channel, "^Crazy Cells"), "Crazy Cells", "Cryo Masters"),
    solution = case_when(
      str_detect(channel, "DMSO") ~ "DMSO+FBS",
      str_detect(channel, "Suc") ~ "Sucrose+FBS",
      str_detect(channel, "PBS") ~ "PBS only",
      TRUE ~ "Unknown"
    ),
    is_invalid = is.na(temperature) | temperature <= -500 | temperature >= 80 | abs(temperature) == 9999
  ) %>%
  group_by(channel) %>%
  arrange(time_s, .by_group = TRUE) %>%
  mutate(
    prev = lag(temperature),
    nxt = lead(temperature),
    spike = !is.na(temperature) & !is.na(prev) & !is.na(nxt) &
      abs(temperature - prev) > 20 & abs(temperature - nxt) > 20,
    is_invalid = is_invalid | spike,
    temperature_clean = if_else(is_invalid, NA_real_, temperature)
  ) %>%
  ungroup() %>%
  select(-prev, -nxt, -spike)

colors <- c(
  "DMSO+FBS" = "#D55E00",
  "Sucrose+FBS" = "#009E73",
  "PBS only" = "#0072B2"
)

base_theme <- theme_minimal(base_size = 12) +
  theme(
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    legend.background = element_rect(fill = "white", color = NA),
    legend.key = element_rect(fill = "white", color = NA),
    text = element_text(color = "#111111"),
    axis.text = element_text(color = "#111111"),
    axis.title = element_text(color = "#111111"),
    plot.title = element_text(color = "#111111"),
    plot.subtitle = element_text(color = "#111111")
  )

nucleation_events <- temp_long %>%
  group_by(channel, team, solution) %>%
  group_map(~ detect_nucleation_event(.x, start_dt), .keep = TRUE) %>%
  bind_rows()

write_csv(nucleation_events, file.path(out_dir, "nucleation_events.csv"))

channel_metrics <- temp_long %>%
  group_by(channel, team, solution) %>%
  group_map(
    ~ {
      nuc_row <- nucleation_events %>%
        filter(channel == .y$channel, team == .y$team, solution == .y$solution) %>%
        slice(1)
      bind_cols(.y, calc_metrics(
        .x,
        nucleation_index = nuc_row$nucleation_index,
        peak_index = nuc_row$peak_index
      ))
    },
    .keep = TRUE
  ) %>%
  bind_rows()

write_csv(channel_metrics, file.path(out_dir, "temperature_metrics.csv"))

temperature_key_points <- temp_long %>%
  group_by(channel, team, solution) %>%
  group_map(
    ~ {
      nuc_row <- nucleation_events %>%
        filter(channel == .y$channel, team == .y$team, solution == .y$solution) %>%
        slice(1)
      collect_key_points(.x, start_dt, nuc_row)
    },
    .keep = TRUE
  ) %>%
  bind_rows()

write_csv(temperature_key_points, file.path(out_dir, "temperature_key_points.csv"))

nucleation_zoom <- temp_long %>%
  inner_join(
    nucleation_events %>% select(channel, nucleation_index, peak_rel_s),
    by = "channel"
  ) %>%
  mutate(
    team = factor(team, levels = c("Crazy Cells", "Cryo Masters")),
    solution = factor(solution, levels = c("DMSO+FBS", "Sucrose+FBS", "PBS only"))
  ) %>%
  mutate(rel_s = time_s - nucleation_index) %>%
  filter(rel_s >= -20, rel_s <= 40)

nuc_ann <- nucleation_events %>%
  mutate(
    team = factor(team, levels = c("Crazy Cells", "Cryo Masters")),
    solution = factor(solution, levels = c("DMSO+FBS", "Sucrose+FBS", "PBS only"))
  ) %>%
  mutate(
    nuc_label = sprintf("Tnuc %.2f C", nucleation_temp_c),
    peak_label = sprintf("Tpeak %.2f C", peak_temp_c),
    jump_label = sprintf("DeltaT %.2f C", jump_delta_t_c),
    mid_x = peak_rel_s / 2,
    mid_y = (nucleation_temp_c + peak_temp_c) / 2
  )

p_nucleation <- ggplot(
  nucleation_zoom,
  aes(x = rel_s, y = temperature_clean, color = solution)
) +
  geom_line(linewidth = 0.7, alpha = 0.95, na.rm = TRUE) +
  geom_point(
    data = nuc_ann,
    aes(x = 0, y = nucleation_temp_c),
    color = "black",
    fill = "white",
    shape = 21,
    size = 2.4,
    inherit.aes = FALSE
  ) +
  geom_point(
    data = nuc_ann,
    aes(x = peak_rel_s, y = peak_temp_c),
    color = "black",
    fill = "white",
    shape = 21,
    size = 2.4,
    inherit.aes = FALSE
  ) +
  geom_segment(
    data = nuc_ann,
    aes(
      x = 0, xend = peak_rel_s,
      y = nucleation_temp_c, yend = peak_temp_c
    ),
    color = "#666666",
    linewidth = 0.45,
    linetype = "dashed",
    inherit.aes = FALSE
  ) +
  geom_text(
    data = nuc_ann,
    aes(x = -15, y = nucleation_temp_c, label = nuc_label),
    size = 3,
    hjust = 0,
    inherit.aes = FALSE
  ) +
  geom_text(
    data = nuc_ann,
    aes(x = 6, y = peak_temp_c, label = peak_label),
    size = 3,
    hjust = 0,
    inherit.aes = FALSE
  ) +
  geom_text(
    data = nuc_ann,
    aes(x = mid_x, y = mid_y + 0.8, label = jump_label),
    size = 3,
    color = "#333333",
    inherit.aes = FALSE
  ) +
  facet_grid(solution ~ team) +
  scale_color_manual(values = colors) +
  coord_cartesian(xlim = c(-20, 40), ylim = c(-15, 5)) +
  labs(
    title = "Nucleation in Supercooled Water (Recalescence Zoom)",
    subtitle = "Rows: protective condition, columns: team. t = 0 s marks nucleation onset",
    x = "Relative time from nucleation (s)",
    y = "Temperature (C)",
    color = "CPA condition"
  ) +
  base_theme

ggsave(
  filename = file.path(out_dir, "06_nucleation_zoom.png"),
  plot = p_nucleation,
  width = 12, height = 8, dpi = 300, bg = "white"
)

p_full <- ggplot(
  temp_long,
  aes(x = time_min, y = temperature_clean, color = solution, linetype = team)
) +
  geom_line(linewidth = 0.5, alpha = 0.9) +
  scale_color_manual(values = colors) +
  coord_cartesian(ylim = c(-200, 30)) +
  labs(
    title = "Cryopreservation Temperature Profiles",
    subtitle = "All six channels, cleaned for sensor outliers",
    x = "Time (min)",
    y = "Temperature (C)",
    color = "CPA condition",
    linetype = "Team"
  ) +
  base_theme

ggsave(
  filename = file.path(out_dir, "01_temperature_profiles_full.png"),
  plot = p_full,
  width = 12, height = 7, dpi = 300, bg = "white"
)

p_zoom <- ggplot(
  temp_long,
  aes(x = time_min, y = temperature_clean, color = solution, linetype = team)
) +
  geom_line(linewidth = 0.7, alpha = 0.95) +
  geom_abline(intercept = 6, slope = -1, linewidth = 0.6, linetype = "dotted", color = "black") +
  scale_color_manual(values = colors) +
  coord_cartesian(xlim = c(0, 50), ylim = c(-45, 10)) +
  labs(
    title = "Controlled Cooling Window (0 to 50 min)",
    subtitle = "Dotted line: -1 K/min reference from +6 C",
    x = "Time (min)",
    y = "Temperature (C)",
    color = "CPA condition",
    linetype = "Team"
  ) +
  base_theme

ggsave(
  filename = file.path(out_dir, "02_temperature_profiles_zoom_freezing.png"),
  plot = p_zoom,
  width = 12, height = 7, dpi = 300, bg = "white"
)

rates_long <- channel_metrics %>%
  select(
    channel, team, solution,
    cooling_rate_controlled_k_per_min,
    cooling_rate_to_nucleation_k_per_min,
    thaw_rate_to_10_k_per_min
  ) %>%
  pivot_longer(
    cols = -c(channel, team, solution),
    names_to = "metric",
    values_to = "rate_k_per_min"
  ) %>%
  mutate(
    metric = recode(
      metric,
      cooling_rate_controlled_k_per_min = "Controlled cooling (5 to 45 min)",
      cooling_rate_to_nucleation_k_per_min = "Cooling to nucleation",
      thaw_rate_to_10_k_per_min = "Thawing rate (frozen to +10 C)"
    ),
    label = str_c(team, " | ", solution)
  )

p_rates <- ggplot(
  rates_long,
  aes(x = label, y = rate_k_per_min, fill = solution)
) +
  geom_col() +
  facet_wrap(~ metric, scales = "free_y") +
  scale_fill_manual(values = colors) +
  labs(
    title = "Cooling and Thawing Rate Summary",
    x = "Channel",
    y = "Rate (K/min)",
    fill = "CPA condition"
  ) +
  base_theme +
  theme(axis.text.x = element_text(angle = 25, hjust = 1))

ggsave(
  filename = file.path(out_dir, "03_rate_summary.png"),
  plot = p_rates,
  width = 12, height = 7, dpi = 300, bg = "white"
)

# --------------------
# Vi-CELL measurements
# --------------------
vicell_raw <- read_excel(in_vicell, sheet = "Vi-CELL Results", col_names = FALSE)
vicell <- vicell_raw[6:23, 1:6]
names(vicell) <- c(
  "sample_id", "cell_type", "sample_date", "viability_pct",
  "total_cells_mio_per_ml", "viable_cells_mio_per_ml"
)

vicell <- vicell %>%
  mutate(
    viability_pct = as.numeric(viability_pct),
    total_cells_mio_per_ml = as.numeric(total_cells_mio_per_ml),
    viable_cells_mio_per_ml = as.numeric(viable_cells_mio_per_ml),
    team = if_else(str_detect(sample_id, "^Crazycells"), "Crazy Cells", "Cryo Masters"),
    sample_code = str_extract(sample_id, "[0-9]{2}$"),
    solution_code = str_sub(sample_code, 1, 1),
    replicate = str_sub(sample_code, 2, 2),
    solution = case_when(
      solution_code == "1" ~ "DMSO+FBS",
      solution_code == "2" ~ "Sucrose+FBS",
      solution_code == "3" ~ "PBS only",
      TRUE ~ "Unknown"
    )
  )

frozen_viable <- as.numeric(vicell_raw[[10]][5])
frozen_volume_ml <- 0.5
post_thaw_volume_ml <- 3.0
frozen_cells_per_sample_mio <- frozen_viable * frozen_volume_ml
vicell <- vicell %>%
  mutate(
    recovered_cells_mio = viable_cells_mio_per_ml * post_thaw_volume_ml,
    frozen_cells_mio = frozen_cells_per_sample_mio,
    recovery_pct = 100 * recovered_cells_mio / frozen_cells_mio
  )

write_csv(vicell, file.path(out_dir, "vicell_clean.csv"))

vicell_summary <- vicell %>%
  group_by(team, solution) %>%
  summarise(
    n = n(),
    viability_median = median(viability_pct, na.rm = TRUE),
    viability_sd = sd(viability_pct, na.rm = TRUE),
    recovery_median = median(recovery_pct, na.rm = TRUE),
    recovery_sd = sd(recovery_pct, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(vicell_summary, file.path(out_dir, "vicell_summary.csv"))

pd <- position_dodge(width = 0.5)

p_viability <- ggplot(vicell, aes(x = solution, y = viability_pct, color = team)) +
  geom_jitter(width = 0.12, alpha = 0.6, size = 2) +
  geom_point(
    data = vicell_summary,
    aes(x = solution, y = viability_median, group = team, color = team),
    position = pd, size = 3, inherit.aes = FALSE
  ) +
  geom_errorbar(
    data = vicell_summary,
    aes(
      x = solution,
      ymin = viability_median - viability_sd,
      ymax = viability_median + viability_sd,
      group = team,
      color = team
    ),
    width = 0.12, position = pd, inherit.aes = FALSE
  ) +
  scale_color_manual(values = c("Crazy Cells" = "#333333", "Cryo Masters" = "#AA3377")) +
  scale_x_discrete(limits = c("DMSO+FBS", "Sucrose+FBS", "PBS only")) +
  labs(
    title = "Post-thaw Viability by CPA Condition",
    subtitle = "Points: triplicate measurements, bars: median +/- SD",
    x = "Condition",
    y = "Viability (%)",
    color = "Team"
  ) +
  base_theme

ggsave(
  filename = file.path(out_dir, "04_viability_by_solution.png"),
  plot = p_viability,
  width = 10, height = 6, dpi = 300, bg = "white"
)

p_recovery <- ggplot(vicell, aes(x = solution, y = recovery_pct, color = team)) +
  geom_jitter(width = 0.12, alpha = 0.6, size = 2) +
  geom_point(
    data = vicell_summary,
    aes(x = solution, y = recovery_median, group = team, color = team),
    position = pd, size = 3, inherit.aes = FALSE
  ) +
  geom_errorbar(
    data = vicell_summary,
    aes(
      x = solution,
      ymin = recovery_median - recovery_sd,
      ymax = recovery_median + recovery_sd,
      group = team,
      color = team
    ),
    width = 0.12, position = pd, inherit.aes = FALSE
  ) +
  scale_color_manual(values = c("Crazy Cells" = "#333333", "Cryo Masters" = "#AA3377")) +
  scale_x_discrete(limits = c("DMSO+FBS", "Sucrose+FBS", "PBS only")) +
  labs(
    title = "Recovery Relative to Pre-freeze Viable Cells",
    subtitle = "Recovery based on 0.5 ml frozen sample and 3 x 1 ml Vi-CELL aliquots after thaw",
    x = "Condition",
    y = "Recovery (%)",
    color = "Team"
  ) +
  base_theme

ggsave(
  filename = file.path(out_dir, "05_recovery_by_solution.png"),
  plot = p_recovery,
  width = 10, height = 6, dpi = 300, bg = "white"
)

message("Done. Figures and tables written to: ", normalizePath(out_dir))
