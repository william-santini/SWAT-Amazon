# ------------------------------------------------------------------------------
# Function: write_new_prmt
# Description: Adds a new parameter to a TxtInOut file (e.g., `.rte` files), ensuring
#              that the parameter does not already exist in the file. If it doesn't exist,
#              the function inserts the parameter description and its default value at 
#              the specified line, adjusting the formatting as needed.
#
# Inputs:
#   - file_path: A character string representing the path to the TxtInOut file.
#   - line_insert: The line number where the new parameter should be inserted.
#   - new_par_name: The name of the new parameter to add.
#   - par_describe: A description of the new parameter.
#   - par_dflt_val: The default value for the new parameter.
#   - par_precision: The number of decimal places to use when formatting the default value.
#
# Outputs:
#   - A character string indicating the result:
#     - If the parameter is successfully added, returns "Parameter has been added successfully!".
#     - If the parameter already exists in the file, returns a message indicating the line 
#       where the parameter is found.
#
# Example:
#   - `write_new_prmt("file.rte", 58, "EQROUTING", "Description of the parameter", 4, 0)`
#     This will add the parameter `EQROUTING` at line 58 of the file `file.rte` with 
#     a default value of `4.0000` (formatted to 4 decimal places).
#
# Notes:
#   - The function adjusts indentation based on the file type (`.rte` files have a different 
#     indentation style compared to others).
#   - If the parameter already exists in the file, the function reports the line number 
#     where it was found.
#
# ------------------------------------------------------------------------------

write_new_prmt <- function(file_path, line_insert, new_par_name, par_describe, par_dflt_val, par_precision) {
  # Read the file content
  content <- readLines(file_path)
  
  # Check if the parameter already exists
  new_par_name_pattern <- paste0('\\b', new_par_name, '\\b')
  is_present <- any(grepl(new_par_name_pattern, content))
  
  if (!is_present) {
    # Define indentation based on file type
    if (grepl(".rte", file_path)) {
      indent <- 14
    } else {
      indent <- 16
    }
    
    # Create the description line to insert
    new_text <- paste(strrep(" ", indent + 4), "| ", new_par_name, " : ", par_describe, sep = "")
    
    # Format the default value with given precision
    formatted_value <- sprintf(paste("%.", as.character(par_precision), "f", sep = ""), par_dflt_val)
    
    # Calculate insertion position for the value
    value_pos <- indent - nchar(formatted_value)
    
    # Insert the description line above the target line
    content <- append(content, new_text, after = line_insert - 1)
    
    # Update the target line with the formatted value
    updated_line <- paste0(
      substr(content[line_insert], 1, value_pos),
      formatted_value,
      substr(content[line_insert], indent + 1, nchar(content[line_insert]))
    )
    content[line_insert] <- updated_line
    
    # Write the modified content back to the file
    writeLines(content, file_path)
    return("Parameter has been added successfully!")
    
  } else {
    # If parameter already exists, return line number
    for (i in seq_along(content)) {
      if (grepl(new_par_name, content[i])) {
        line_found <- i
        break
      }
    }
    return(paste("Parameter has already been added on line", line_found, "!"))
  }
}

# Example usage:
# write_new_prmt("file.rte", 58, "EQROUTING", "Description of the parameter", 4, 0)


# ------------------------------------------------------------------------------
# Function: modif_par_bsn
# Description: Modifies a parameter directly in the `basins.bsn` file by searching 
#              for the parameter name and updating its associated value.
#
# Inputs:
#   - file_path: A character string representing the path to the `basins.bsn` file.
#   - par_name: A character string representing the name of the parameter to modify.
#   - new_value: The new value to assign to the parameter. This can be a numeric or 
#                character value (depending on the parameter type).
#
# Outputs:
#   - A character string indicating the result of the operation:
#     - If successful, returns a message indicating the old and new values of the parameter.
#     - If the parameter is not found, returns a message indicating that the parameter 
#       was not found in the file.
#
# Example:
#   - `modif_par_bsn("basins.bsn", "MSK_CO1", 0.255)`
#     This will search for the parameter `MSK_CO1` in the file `basins.bsn` and 
#     replace its value with `0.255`.
#
# Notes:
#   - The function assumes that the file uses a simple key-value structure, where 
#     parameters are defined in lines with a name and a numeric or string value.
#   - The function adjusts spacing to accommodate the change in the length of the 
#     value being modified (if necessary), ensuring the file format remains intact.
#
# ------------------------------------------------------------------------------

modif_par_bsn <- function(file_path, par_name, new_value) {
  # Read the contents of the file
  content <- readLines(file_path)
  
  line_index <- 0           # Line where the parameter is found
  current_value <- NULL     # Value currently associated with the parameter
  
  # Search for the line containing the target parameter name
  for (i in seq_along(content)) {
    if (grepl(par_name, content[i])) {
      line_index <- i
      current_value <- str_extract(content[i], "\\b\\d+(\\.\\d+)?\\b")
      break
    }
  }
  
  # If the parameter is found
  if (line_index != 0) {
    value_diff <- nchar(current_value) - nchar(new_value)
    
    # Replace the value with the new one, adjusting spacing
    if (value_diff == 0) {
      new_line <- str_replace(content[line_index], current_value, as.character(new_value))
    } else if (value_diff > 0) {
      new_line <- str_replace(
        content[line_index],
        current_value,
        paste0(strrep(" ", value_diff), as.character(new_value))
      )
    } else {
      new_line <- str_replace(content[line_index], current_value, as.character(new_value))
      new_line <- substring(new_line, abs(value_diff) + 1)
    }
    
    # Update the content and save it back to the file
    content[line_index] <- new_line
    writeLines(content, file_path)
    
    return(paste("The parameter has been modified from:", current_value, "to", new_value))
    
  } else {
    # Parameter not found in file
    return("Parameter not found in the basin file.")
  }
}

# Example usage:
# modif_par_bsn("basins.bsn", "MSK_CO1", 0.255)


# ------------------------------------------------------------------------------
# Function: monthly_average
# Description: Computes the monthly average of the values in the second column 
#              of a data frame, grouped by month and year. It also creates a 
#              representative date (the middle of each month) for the aggregated data.
#
# Inputs:
#   - df: data.frame or tibble with at least two columns:
#     - The first column should contain dates (Date or POSIXt format).
#     - The second column should contain numeric values to aggregate.
#
# Outputs:
#   - A data.frame with the following columns:
#     - "month": The month of the year (numeric, 01 to 12).
#     - "year": The year (numeric).
#     - "q_m": The computed monthly average for the corresponding year and month.
#     - "date": A representative date for each month (the 16th of each month).
#
# Example:
#   - Input: A data.frame `df` with columns for date and values.
#   - Output: A data.frame with monthly averages of the values in `df`.
#
# Notes:
#   - The first column of `df` is expected to be a date, and the second column
#     should contain the numeric data for which the monthly average is to be computed.
#   - The function uses the `aggregate()` function to compute the monthly averages.
#   - The date for each month in the output is set to the 16th of the respective month,
#     representing the middle of the month.
#
# ------------------------------------------------------------------------------

monthly_average <- function(df) {
  # Extract month and year from the first column (assumed to be dates)
  df$month <- format(df[[1]], format = "%m")
  df$year  <- format(df[[1]], format = "%Y")
  
  # Compute the monthly average of the second column, grouped by year and month
  monthly_agg <- aggregate(df[[2]] ~ month + year, data = df, mean)
  print(monthly_agg)
  
  # Create a representative date (middle of each month)
  monthly_agg$date <- as.Date(paste(monthly_agg$year, monthly_agg$month, 16, sep = "-"), format = "%Y-%m-%d")
  
  # Rename columns for clarity
  colnames(monthly_agg) <- c("month", "year", "q_m", "date")
  
  return(monthly_agg)
}

# Example usage:
# df should have a date column and a numeric value column
# monthly_average(df)


# ------------------------------------------------------------------------------
# Function: Compute_gof
# Description: Computes Goodness-of-Fit (GOF) metrics between simulation and 
#              observation data. The metrics include NSE, LogNSE, KGE, ME, MAE, 
#              PBIAS, and bR². The function aligns the date ranges of the 
#              simulation and observation datasets before calculation.
#
# Inputs:
#   - sim: data.frame or tibble, simulation results with two columns: "date" and "value".
#   - obs: data.frame or tibble, observed data with two columns: "date" and "value".
#
# Outputs:
#   - A data.frame with the computed GOF metrics:
#     - NSE: Nash-Sutcliffe Efficiency
#     - LogNSE: Logarithmic Nash-Sutcliffe Efficiency
#     - KGE: Kling-Gupta Efficiency
#     - ME: Mean Error
#     - MAE: Mean Absolute Error
#     - PBIAS: Percent Bias
#     - bR2: Bias-corrected R²
#
# Notes:
#   - The function assumes that both `sim` and `obs` have date columns in the first column
#     and value columns in the second column.
#   - The date range of the observation data is aligned to that of the simulation data 
#     by filtering out any observations outside the simulation date range.
#   - The function calculates metrics by applying appropriate functions (e.g., NSE, KGE, etc.)
#     after aligning the datasets.
#
# Dependencies: NSE, KGE, me, pbias, br2 (presumed to be defined functions)
#
# ------------------------------------------------------------------------------

Compute_gof <- function(sim, obs) {
  
  # Align simulation and observation data to common date range
  
  n <- length(obs[[1]])
  m <- length(sim[[1]])
  
  # Keep only observations that are within the simulation date range
  obs <- subset(obs, as.Date(obs[, 1]) >= sim[[1, 1]])
  obs <- subset(obs, as.Date(obs[, 1]) <= sim[[m, 1]])
  
  # Compute GOF metrics
  NSE     <- round(NSE(sim[[2]], obs[, 2], na.rm = TRUE), 2)
  LogNSE  <- round(NSE(sim[[2]], obs[, 2], na.rm = TRUE, FUN = log), 2)
  KGE     <- round(KGE(sim[[2]], obs[, 2], na.rm = TRUE, FUN = log), 2)
  ME      <- round(me(sim[[2]], obs[, 2], na.rm = TRUE, FUN = log), 0)
  MAE     <- round(pbias(sim[[2]], obs[, 2], na.rm = TRUE, FUN = log), 2)
  PBIAS   <- round(pbias(sim[[2]], obs[, 2], na.rm = TRUE, FUN = log), 2)
  bR2     <- round(br2(sim[[2]], obs[, 2], na.rm = TRUE, FUN = log), 2)
  
  # Combine all metrics into a single data frame
  dfGOF <- data.frame(NSE, LogNSE, KGE, ME, MAE, PBIAS, bR2)
  colnames(dfGOF) <- c("NSE", "LogNSE", "KGE", "ME", "MAE", "PBIAS", "bR2")
  
  return(dfGOF)
}

# Example usage:
# Compute_gof(sim_data, obs_data)


# ------------------------------------------------------------------------------
# Function: Graphstation
# Description: Generates an interactive Plotly plot comparing observed and 
#              simulated hydrological data (e.g., discharge, water depth, 
#              velocity) by station. It displays both raw and aggregated (monthly) 
#              data for observed and simulated values, including different sets of 
#              simulations (base, tests, best calibration, and parallel processing).
#
# Inputs:
#   - station_name: character, the name of the station (e.g., "Station A").
#   - variable: character, the hydrological variable to plot (e.g., "Q", "h", "u").
#   - obs: data.frame or tibble, observed time series with columns: "date" and "value".
#   - liq_gaug: data.frame or tibble, gauged values with columns: "date" and "value".
#   - qsim_0: data.frame or tibble, base simulation results with columns: "date" and "value".
#   - qsim_tests: data.frame or tibble, results of test simulations with columns: "date" and "value".
#   - qsim_bestcal: data.frame or tibble, best calibration simulation results with columns: "date" and "value".
#   - qsim_parallel_processing: data.frame or tibble (optional), simulation results for parallel processing 
#         with columns: "date", followed by simulation results for different runs.
#
# Outputs:
#   - An interactive Plotly plot comparing observed and simulated data.
#   - The plot is saved as an HTML file in the working directory, 
#     with the filename including the station name and variable.
#
# Dependencies: plotly, htmlwidgets
#
# Notes:
#   - This function aggregates the data by month and computes various Goodness-of-Fit (GOF) metrics 
#     for each simulation (e.g., NSE, LogNSE, KGE).
#   - The function allows comparison of multiple simulations using different colors and legends.
#   - For parallel processing simulations, only the top 10 best simulations based on GOF metrics are plotted.
# 
# ------------------------------------------------------------------------------

Graphstation <- function (station_name, variable, obs, liq_gaug, qsim_0, qsim_tests, qsim_bestcal, qsim_parallel_processing=NULL){
  
  # Convert observed data to tibble and compute monthly average
  df <- as_tibble(obs)
  obs_m <- monthly_average(df) 
  
  # Compute monthly averages for all simulation datasets
  qsim_0_m <- monthly_average(qsim_0)                 
  qsim_tests_m <- monthly_average(qsim_tests)         
  qsim_bestcal_m <- monthly_average(qsim_bestcal)     
  
  # Compute goodness-of-fit (GOF) metrics for each simulation set
  sim = qsim_0                                                   
  gof_0 = Compute_gof(sim, obs)
  
  sim = qsim_tests                                               
  gof_tests = Compute_gof(sim, obs)
  
  sim = qsim_bestcal                                       
  gof_bestcal = Compute_gof(sim, obs)
  
  # Define plot titles based on selected variable
  titre <- switch(variable,
                  "Q" = "Discharge (m3/s)",
                  "h" = "Water Depth (m)",
                  "u" = "Water Velocity (m/s)",
                  "p" = "Precipitations (mm)",
                  "Qss" = "Suspended Sediments (Sands) (t/d)",
                  "Qsf" = "Suspended Sediments (Fine) (t/d)",
                  "Qst" = "Total Suspended Sediments (t/d)",
                  "Unknown Variable")
  
  # Define Y-axis labels based on selected variable
  yaxis_title <- switch(variable,
                        "Q" = "Q (m3/s)",
                        "h" = "h (m)",
                        "u" = "u (m/s)",
                        "p" = "p (mm)",
                        "Qss" = "Qss (t/d)",
                        "Qsf" = "Qsf (t/d)",
                        "Qst" = "Qst (t/d)",
                        "Unknown Variable")
  
  # Initialize Plotly graph with all traces
  GraphQ = plot_ly() %>%
    
    # Add trace: liquid gauging points
    add_trace(data = liq_gaug, x = ~ as.Date(liq_gaug[,1]), y = ~ liq_gaug[,2],
              name = 'Gauged values', visible="TRUE",type="scatter", mode = "lines+markers",
              marker = list(size = 12, color = "red",
                            line = list(color = "red", width = 1)),
              line = list(color = rgb(0,0,0, alpha = 0), width = 0)) %>%
    
    # Add trace: raw observations
    add_trace(data =  obs, x = ~ as.Date(obs[,1]), y = ~ obs[,2], 
              name = "obs", visible="TRUE",
              type = 'scatter', mode = "lines+markers",
              marker = list(size = 3, color = "white",
                            line = list(color = Listcol[1], width = 0.5)),
              line = list(color = Listcol[1], width = 0.5)) %>%
    
    # Add trace: monthly average of observations
    add_trace(data = obs_m, x = ~ date, y = ~ q_m,
              name = "obs_m", visible="legendonly",
              type = 'scatter', mode = "lines",
              line = list(color = Listcol[1], width = 2)) %>%
    
    # Add trace: simulation 0 (raw and monthly average)
    add_trace(data = qsim_0, x = ~ date, y = ~ run_1 ,
              name = paste("<b>sim 0</b>",
                           "\nNSE = ", gof_0$NSE, " LogNSE =", gof_0$LogNSE,
                           "\nKGE = ", gof_0$KGE, " ME = ", gof_0$ME, "",
                           "\nPBIAS = ", gof_0$PBIAS,"%", " bR² = ", gof_0$bR2),
              visible="legendonly",
              type = 'scatter', mode = "lines",
              line = list(color = Listcol[2], width = 2)) %>%
    add_trace(data = qsim_0_m, x = ~ date, y = ~ q_m,
              name = "sim 0_m", visible="legendonly",
              type = 'scatter', mode = "lines",
              line = list(color = Listcol[2], width = 2)) %>%
    
    # Add trace: test simulation (raw and monthly)
    add_trace(data = qsim_tests, x = ~ date, y = ~ run_1,
              name = paste("<b>sim tests</b>",
                           "\nNSE = ", gof_tests$NSE, " LogNSE =", gof_tests$LogNSE,
                           "\nKGE = ", gof_tests$KGE, " ME = ", gof_tests$ME, "",
                           "\nPBIAS = ", gof_tests$PBIAS,"%", " bR² = ", gof_tests$bR2),
              visible="TRUE",
              type = 'scatter', mode = "lines",
              line = list(color = Listcol[3], width = 2)) %>%
    add_trace(data = qsim_tests_m, x = ~ date, y = ~ q_m,
              name = "sim tests_m", visible="legendonly",
              type = 'scatter', mode = "lines",
              line = list(color = Listcol[3], width = 2)) %>%
    
    # Add trace: best calibration simulation (raw and monthly)
    add_trace(data = qsim_bestcal, x = ~ date,
              y = ~ run_1,
              name = paste("<b>sim bestcal</b>",
                           "\nNSE = ", gof_bestcal$NSE, " LogNSE =", gof_bestcal$LogNSE,
                           "\nKGE = ", gof_bestcal$KGE, " ME = ", gof_bestcal$ME, "",
                           "\nPBIAS = ", gof_bestcal$PBIAS,"%", " bR² = ", gof_bestcal$bR2),
              visible="TRUE",
              type = 'scatter', mode = "lines",
              line = list(color = Listcol[5], width = 2)) %>%
    add_trace(data = qsim_bestcal_m, x = ~ date, y = ~ q_m,
              name = "sim bestcal_m", visible="legendonly",
              type = 'scatter', mode = "lines",
              line = list(color = Listcol[5], width = 2)) %>%
    
    # General layout settings
    layout(title = paste("<b>\n Simulations @ ", station_name, "</b>","\n",titre),
           xaxis = list(title = "Date", range = c(Date_ini_skip, Date_fin)),
           yaxis = list(title = bquote(.(yaxis_title))), 
           font = list(family = "Arial", size = 20, color = 'black'))
  
  # If parallel simulations are provided
  if (!is.null(qsim_parallel_processing)) {
    
    n <- ncol(qsim_parallel_processing) - 1
    
    # Compute GOF metrics for all parallel runs
    tempdf <- Plot_gof(station_name, variable, obs, qsim_parallel_processing)
    i_best <- tempdf[[3]]
    gofrun <- tempdf[[1]]
    gofrunsort <- tempdf[[2]]
    gof_tibble <- tempdf[[4]]
    rm(tempdf)
    
    # Retrieve best run
    df <- data.frame(qsim_parallel_processing$date, qsim_parallel_processing[[i_best+1]])
    colnames(df) <- c("Date", "Q")
    
    qsim_par_process_m <- monthly_average(as_tibble(df))
    
    # Add best parallel run trace
    GraphQ <- add_trace(GraphQ, data = df, x = ~ Date, y = ~ Q,
                        name = paste("Best sim parallel processing - Run", i_best, sep = "",
                                     "\nNSE = ", gof_tibble[[i_best]]$NSE,
                                     " LogNSE =", gof_tibble[[i_best]]$LogNSE,
                                     "\nKGE = ", gof_tibble[[i_best]]$KGE,
                                     " ME = ", gof_tibble[[i_best]]$ME, "",
                                     "\nPBIAS = ", gof_tibble[[i_best]]$PBIAS, " %",
                                     " bR² = ",gof_tibble[[i_best]]$bR2),
                        visible="legendonly",
                        type = 'scatter', mode = "lines",
                        line = list(color = Listcol[4], width = 2)) %>%
      
      add_trace(data = qsim_par_process_m, x = ~ date, y = ~ q_m,
                name = "sim best_parallel_proc_m", visible="legendonly",
                type = 'scatter', mode = "lines",
                line = list(color = Listcol[4], width = 2))
    
    compteur = 0
    
    # Add up to 10 good parallel runs (excluding the best one)
    for (i in 2:(n + 1)){
      if (i != (i_best + 1) &
          gofrun$NSE[i-1] >= max(gofrun$NSE, na.rm = TRUE) * 0.975 &
          gofrun$LogNSE[i-1] >= max(gofrun$LogNSE, na.rm = TRUE) * 0.975 &
          gofrun$KGE[i-1] >= max(gofrun$KGE, na.rm = TRUE) * 0.975) {
        
        df <- data.frame(qsim_parallel_processing$date, qsim_parallel_processing[[i]])
        colnames(df) <- c("Date", "Q")
        
        compteur = compteur + 1 
        
        if (compteur <= 10) {
          GraphQ <- add_trace(GraphQ, data = df, x = ~ Date, y = ~ Q,
                              name = paste("Parallel processing - Run", i-1, sep = "",
                                           "\nNSE = ", gofrun$NSE[i-1],
                                           " LogNSE =", gofrun$LogNSE[i-1],
                                           "\nKGE = ", gofrun$KGE[i-1],
                                           " ME = ", gofrun$ME[i-1], " ",
                                           "\nPBIAS = ", gofrun$PBIAS[i-1],
                                           " bR² = ", gofrun$bR2[i-1]),
                              visible="legendonly",
                              type = 'scatter', mode = "lines",
                              line = list(color = Listcol[4], width = 2))
        }
      }
    }
    
    rm(df)
    rm(compteur)
  }
  
  # Export graph to HTML with interactive toolbar
  htmlwidgets::saveWidget(config(GraphQ, scrollZoom = TRUE,
                                 displaylogo = FALSE,
                                 modeBarButtonsToAdd = list('drawline', 
                                                            'drawopenpath', 
                                                            'drawclosedpath', 
                                                            'drawcircle', 
                                                            'drawrect', 
                                                            'eraseshape')), 
                          paste("Sims@", station_name, "_", variable, ".html", sep = ""))
}



# ------------------------------------------------------------------------------
# Function: Plot_gof
# Description: This function generates a set of objective function (GOF) plots for a given station's simulation results.
#              The function calculates various GOFs (NSE, LogNSE, KGE, etc.), identifies the best simulation based on these
#              metrics, and produces interactive plots to visualize the GOF relationships.
#
# Inputs:
#   - station_name: A character string representing the station name.
#   - variable: A character string indicating the variable of interest (e.g., "Q", "h", "u").
#   - obs: A data frame containing observed values.
#   - qsim_parallel_processing: A data frame containing the simulation results.
#
# Outputs:
#   - A list containing:
#     - gofrun: A tibble of GOF results for each simulation.
#     - gofrunsort: A tibble of sorted GOF results based on NSE, KGE, and other metrics.
#     - imax_best_sim: The index of the best simulation based on GOF metrics.
#     - gof_tibble: A list of individual GOF results for each simulation.
#
# Example:
#   - `Plot_gof("Station1", "Q", observed_data, simulation_results)`
#     This will generate and save the GOF plots for the station "Station1" with variable "Q".
#
# Notes:
#   - The function calculates several GOFs and uses the best simulation (based on GOF scores) for visualization.
#   - Interactive plots are generated using the Plotly library and saved as HTML.
#
# ------------------------------------------------------------------------------

Plot_gof <- function(station_name, variable, obs, qsim_parallel_processing) {
  
  n <- ncol(qsim_parallel_processing) - 1
  gof_tibble <- list()
  
  # Use switch instead of nested ifelse for title assignment
  titre <- switch(variable,
                  "Q" = "Discharge (m3/s)",
                  "h" = "Average Water Depth (m)",
                  "u" = "Average Water Velocity (m/s)",
                  "p" = "Precipitations (mm)",
                  "Qss" = "Sediment Flux (Sands) (m3/s)",
                  "Qsf" = "Suspended Sediment (Fine) (m3/s)",
                  "Qst" = "Total Sediment Flux (m3/s)",
                  "Unknown Variable")
  
  for (i in 2:(n + 1)) {
    sim <- data.frame(qsim_parallel_processing$date, qsim_parallel_processing[[i]])
    colnames(sim) <- c("date", "q")
    
    gof_tibble[[i - 1]] <- Compute_gof(sim, obs)
    
    if (i == 2) {
      gofrun <- data.frame(
        run = i - 1,
        NSE = gof_tibble[[i - 1]]$NSE,
        LogNSE = gof_tibble[[i - 1]]$LogNSE,
        KGE = gof_tibble[[i - 1]]$KGE,
        ME = gof_tibble[[i - 1]]$ME,
        MAE = gof_tibble[[i - 1]]$MAE,
        PBIAS = gof_tibble[[i - 1]]$PBIAS,
        bR2 = gof_tibble[[i - 1]]$bR2
      )
    } else {
      gofrun <- rbind(gofrun, data.frame(
        run = i - 1,
        NSE = gof_tibble[[i - 1]]$NSE,
        LogNSE = gof_tibble[[i - 1]]$LogNSE,
        KGE = gof_tibble[[i - 1]]$KGE,
        ME = gof_tibble[[i - 1]]$ME,
        MAE = gof_tibble[[i - 1]]$MAE,
        PBIAS = gof_tibble[[i - 1]]$PBIAS,
        bR2 = gof_tibble[[i - 1]]$bR2
      ))
    }
  }
  
  gofrunsort <- gofrun[order(-gofrun$NSE, -gofrun$KGE, -gofrun$LogNSE, abs(gofrun$PBIAS), -gofrun$bR2), ]
  best_run <- gofrunsort$run[1]
  
  plot1 <- plot_ly(data = gofrunsort, x = ~NSE, y = ~PBIAS, type = 'scatter', mode = 'markers',
                   marker = list(color = ifelse(gofrunsort$run == best_run, 'red', '#56B4E9'),
                                 size = ifelse(gofrunsort$run == best_run, 20, 12),
                                 line = list(color = ifelse(gofrunsort$run == best_run, 'red', '#56B4E9'))),
                   text = ~paste("Run: ", run, "<br>NSE: ", NSE, "<br>PBIAS: ", PBIAS)) %>%
    layout(title = "NSE vs PBIAS", xaxis = list(title = "NSE"), yaxis = list(title = "PBIAS"))
  
  plot2 <- plot_ly(data = gofrunsort, x = ~KGE, y = ~PBIAS, type = 'scatter', mode = 'markers',
                   marker = list(color = ifelse(gofrunsort$run == best_run, 'red', '#56B4E9'),
                                 size = ifelse(gofrunsort$run == best_run, 20, 12),
                                 line = list(color = ifelse(gofrunsort$run == best_run, 'red', '#56B4E9'))),
                   text = ~paste("Run: ", run, "<br>KGE: ", KGE, "<br>PBIAS: ", PBIAS)) %>%
    layout(title = "KGE vs PBIAS", xaxis = list(title = "KGE"), yaxis = list(title = "PBIAS"))
  
  plot3 <- plot_ly(data = gofrunsort, x = ~NSE, y = ~KGE, type = 'scatter', mode = 'markers',
                   marker = list(color = ifelse(gofrunsort$run == best_run, 'red', '#56B4E9'),
                                 size = ifelse(gofrunsort$run == best_run, 20, 12),
                                 line = list(color = ifelse(gofrunsort$run == best_run, 'red', '#56B4E9'))),
                   text = ~paste("Run: ", run, "<br>NSE: ", NSE, "<br>KGE: ", KGE)) %>%
    layout(title = "NSE vs KGE", xaxis = list(title = "NSE"), yaxis = list(title = "KGE"))
  
  plot4 <- plot_ly(data = gofrunsort, x = ~LogNSE, y = ~NSE, type = 'scatter', mode = 'markers',
                   marker = list(color = ifelse(gofrunsort$run == best_run, 'red', '#56B4E9'),
                                 size = ifelse(gofrunsort$run == best_run, 20, 12),
                                 line = list(color = ifelse(gofrunsort$run == best_run, 'red', '#56B4E9'))),
                   text = ~paste("Run: ", run, "<br>LogNSE: ", LogNSE, "<br>NSE: ", NSE)) %>%
    layout(title = "LogNSE vs NSE", xaxis = list(title = "LogNSE"), yaxis = list(title = "NSE"))
  
  annotations <- list(
    list(x = 0.24, y = 0.98, text = "<b>NSE vs PBIAS</b>", xref = "paper", yref = "paper",
         xanchor = "center", yanchor = "bottom", showarrow = FALSE),
    list(x = 0.76, y = 0.98, text = "<b>KGE vs PBIAS</b>", xref = "paper", yref = "paper",
         xanchor = "center", yanchor = "bottom", showarrow = FALSE),
    list(x = 0.24, y = 0.41, text = "<b>NSE vs KGE</b>", xref = "paper", yref = "paper",
         xanchor = "center", yanchor = "bottom", showarrow = FALSE),
    list(x = 0.76, y = 0.41, text = "<b>LogNSE vs NSE</b>", xref = "paper", yref = "paper",
         xanchor = "center", yanchor = "bottom", showarrow = FALSE)
  )
  
  final_plot <- subplot(plot1, plot2, plot3, plot4, nrows = 2, titleX = TRUE, titleY = TRUE) %>%
    layout(title = paste("<b>\n Objective Functions @ ", station_name, "</b>", "\n", titre, sep = ""),
           annotations = annotations,
           margin = 0.15)
  
  htmlwidgets::saveWidget(config(final_plot,
                                 scrollZoom = TRUE,
                                 displaylogo = FALSE,
                                 modeBarButtonsToAdd = list('drawline', 'drawopenpath',
                                                            'drawclosedpath', 'drawcircle',
                                                            'drawrect', 'eraseshape')),
                          paste("Gof@", station_name, "_", variable, ".html", sep = ""))
  
  return(list(gofrun = gofrun,
              gofrunsort = gofrunsort,
              imax_best_sim = best_run,
              gof_tibble = gof_tibble))
}


# ------------------------------------------------------------------------------
# Function: Compute_day_interannual
# Description: This function computes the interannual average of a daily time series
#              for a given dataset, with optional filtering based on specified date
#              ranges. It also supports plotting data from a specific start date.
#
# Inputs:
#   - data: A data frame where the first column is the date and the second column 
#           contains the values to aggregate (e.g., discharge, precipitation).
#   - Date_ini: (Optional) A character string specifying the start date for filtering 
#               (format: "dd-mm-yyyy").
#   - Date_end: (Optional) A character string specifying the end date for filtering 
#               (format: "dd-mm-yyyy").
#   - DayMonth_ini_plot: (Optional) A character string representing the starting 
#                         date in "dd-mm-yyyy" format for aligning the dates.
#
# Outputs:
#   - A data frame containing:
#     - day: Day of the month.
#     - month: Month of the year.
#     - q_intAn: Interannual mean for each day of the month.
#     - count: Number of values used for each aggregation.
#     - date: The combined day and month in "dd-mm-yyyy" format.
#
# Example:
#   - `Compute_day_interannual(data, Date_ini = "01-01-2000", Date_end = "31-12-2020")`
#     This will compute the interannual average for the specified date range.
#
# ------------------------------------------------------------------------------
Compute_day_interannual <- function(data, Date_ini = NULL, Date_end = NULL, DayMonth_ini_plot = NULL) {
  
  # Convert the date column to Date format
  data[[1]] <- as.Date(data[[1]], format = "%d-%m-%Y")
  
  # Filter data based on the provided date range (if any)
  if (!is.null(Date_ini) & !is.null(Date_end)) {
    Date_ini <- as.Date(Date_ini, format = "%d-%m-%Y")
    Date_end <- as.Date(Date_end, format = "%d-%m-%Y")
    data <- data[data[[1]] >= Date_ini & data[[1]] <= Date_end, ]
  } else if (!is.null(Date_ini)) {
    Date_ini <- as.Date(Date_ini, format = "%d-%m-%Y")
    data <- data[data[[1]] >= Date_ini, ]
  } else if (!is.null(Date_end)) {
    Date_end <- as.Date(Date_end, format = "%d-%m-%Y")
    data <- data[data[[1]] <= Date_end, ]
  }
  
  # Extract day, month, and year from the date
  day <- format(data[[1]], format = "%d")
  month <- format(data[[1]], format = "%m")
  year <- format(data[[1]], format = "%Y")
  
  # Aggregate the data by day and month, calculating the mean and count
  X_day_interAnn <- aggregate(data[[2]] ~ day + month, data = data, 
                              FUN = function(x) c(mean = mean(x), count = length(x)))
  
  # Extract the aggregated values and count
  X_day_interAnn$q_intAn <- X_day_interAnn[[3]][, 1]
  X_day_interAnn$count <- X_day_interAnn[[3]][, 2]
  X_day_interAnn$date <- paste(X_day_interAnn$day, X_day_interAnn$month, sep = "-")
  
  # Clean up the intermediate column and rename the columns for clarity
  X_day_interAnn <- X_day_interAnn[-3]
  colnames(X_day_interAnn) <- c("day", "month", "q_intAn", "count", "date")
  
  # Adjust the date range if a specific starting date for plotting is provided
  if (!is.null(DayMonth_ini_plot)) {
    i <- 1
    # Find the row where the date matches the given start date
    while (DayMonth_ini_plot != X_day_interAnn$date[i]) {
      X_day_interAnn$date[i] <- paste(X_day_interAnn$date[i], "1000", sep = "-")
      i <- i + 1
    }
    # Modify the dates after the found start date
    for (j in i:length(X_day_interAnn$date)) {
      X_day_interAnn$date[j] <- paste(X_day_interAnn$date[j], "999", sep = "-")
    }
    # Convert the dates to Date format and reorder the data
    X_day_interAnn$date <- as.Date(X_day_interAnn$date, format = "%d-%m-%Y")
    X_day_interAnn <- X_day_interAnn[order(X_day_interAnn$date), ]
  }
  
  # Return the processed data frame
  return(X_day_interAnn)
}


# ------------------------------------------------------------------------------
# Function: Compute_month_interannual
# Description: This function computes the interannual average for each month
#              based on a dataset, with optional filtering based on a given date
#              range. It also supports aligning data to a specific start month 
#              for plotting purposes.
#
# Inputs:
#   - data: A data frame where the first column is the date and the second column
#           contains the values to aggregate (e.g., discharge, precipitation).
#   - Date_ini: (Optional) A character string specifying the start date for filtering
#               (format: "dd-mm-yyyy").
#   - Date_end: (Optional) A character string specifying the end date for filtering
#               (format: "dd-mm-yyyy").
#   - DayMonth_ini_plot: (Optional) A character string representing the starting 
#                         month in "dd-mm-yyyy" format for aligning the dates.
#
# Outputs:
#   - A data frame containing:
#     - month: Month of the year.
#     - q_intAn: Interannual mean for each month.
#     - count: Number of values used for each aggregation.
#     - date: The combined day (16) and month in "dd-mm-yyyy" format.
#
# Example:
#   - `Compute_month_interannual(data, Date_ini = "01-01-2000", Date_end = "31-12-2020")`
#     This will compute the interannual average for the specified date range.
#
# ------------------------------------------------------------------------------
Compute_month_interannual <- function(data, Date_ini = NULL, Date_end = NULL, DayMonth_ini_plot = NULL) {
  
  # Convert the date column to Date format
  data[[1]] <- as.Date(data[[1]], format = "%d-%m-%Y")
  
  # Filter data based on the provided date range (if any)
  if (!is.null(Date_ini) & !is.null(Date_end)) {
    Date_ini <- as.Date(Date_ini, format = "%d-%m-%Y")
    Date_end <- as.Date(Date_end, format = "%d-%m-%Y")
    data <- data[data[[1]] >= Date_ini & data[[1]] <= Date_end, ]
  } else if (!is.null(Date_ini)) {
    Date_ini <- as.Date(Date_ini, format = "%d-%m-%Y")
    data <- data[data[[1]] >= Date_ini, ]
  } else if (!is.null(Date_end)) {
    Date_end <- as.Date(Date_end, format = "%d-%m-%Y")
    data <- data[data[[1]] <= Date_end, ]
  }
  
  # Compute the monthly average for the given dataset
  X_month_interAnn <- monthly_average(data)
  
  # Aggregate the data by month, calculating the mean and count
  X_month_interAnn <- aggregate(X_month_interAnn$q_m ~ month, data = X_month_interAnn, 
                                FUN = function(x) c(mean = mean(x), count = length(x)))
  
  # Extract the aggregated values and count
  X_month_interAnn$q_intAn <- X_month_interAnn$`X_month_interAnn$q_m`[, 1]
  X_month_interAnn$count <- X_month_interAnn$`X_month_interAnn$q_m`[, 2]
  X_month_interAnn$date <- paste(16, X_month_interAnn$month, sep = "-")
  
  # Clean up the intermediate column and rename the columns for clarity
  X_month_interAnn <- X_month_interAnn[-2]
  colnames(X_month_interAnn) <- c("month", "q_intAn", "count", "date")
  
  # Adjust the date range if a specific starting month for plotting is provided
  if (!is.null(DayMonth_ini_plot)) {
    month <- substr(DayMonth_ini_plot, start = 4, stop = 5)
    DayMonth_ini_plot <- paste("16", month, sep = "-")
    i <- 1
    # Find the row where the date matches the given start month
    while (DayMonth_ini_plot != X_month_interAnn$date[i]) {
      X_month_interAnn$date[i] <- paste(X_month_interAnn$date[i], "1000", sep = "-")
      i <- i + 1
    }
    # Modify the dates after the found start month
    for (j in i:length(X_month_interAnn$date)) {
      X_month_interAnn$date[j] <- paste(X_month_interAnn$date[j], "999", sep = "-")
    }
    # Convert the dates to Date format and reorder the data
    X_month_interAnn$date <- as.Date(X_month_interAnn$date, format = "%d-%m-%Y")
    X_month_interAnn <- X_month_interAnn[order(X_month_interAnn$date), ]
  }
  
  # Return the processed data frame
  return(X_month_interAnn)
}

# ------------------------------------------------------------------------------
# Function: Plot_calib_curve
# Description: This function creates an interactive plotly visualization of two 
#              calibration curves (e.g., observed vs simulated values),
#              with optional observed data and gauge data.
#
# Inputs:
#   - station_name: Station name to include in the plot title.
#   - x1_name, y1_name: Names of the variables for the first plot (e.g., "Q", "h").
#   - gaug_yx_1: Data frame for gauged values (first plot), with x in column 1 and y in column 2.
#   - obs_yx_1: (Optional) Observed values (first plot), same format.
#   - sim_yx_1: Simulated values (first plot), same format.
#   - x2_name, y2_name: Names of the variables for the second plot.
#   - gaug_yx_2, obs_yx_2, sim_yx_2: Same as above, for the second plot.
#
# Outputs:
#   - An interactive subplot (plotly), saved as an HTML file.
# ------------------------------------------------------------------------------

Plot_calib_curve <- function(station_name, 
                             x1_name, y1_name, gaug_yx_1,
                             obs_yx_1 = NULL, sim_yx_1,
                             x2_name, y2_name, gaug_yx_2,
                             obs_yx_2 = NULL, sim_yx_2) {
  
  # Helper function to format axis labels
  format_axis_label <- function(var_name) {
    switch(var_name,
           "Q" = "Q (m³/s)",
           "h" = "h (m)",
           "u" = "u (m/s)",
           "p" = "p (mm)",
           "Qss" = "Qss (m³/s)",
           "Qsf" = "Qsf (m³/s)",
           "Qst" = "Qst (m³/s)",
           "Unknown Variable")
  }
  
  # Define axis labels
  xaxis_title1 <- format_axis_label(x1_name)
  yaxis_title1 <- format_axis_label(y1_name)
  xaxis_title2 <- format_axis_label(x2_name)
  yaxis_title2 <- format_axis_label(y2_name)
  
  # First plot: y1 vs x1
  plot1 <- plot_ly(data = sim_yx_1, x = sim_yx_1[[1]], y = sim_yx_1[[2]], 
                   type = "scatter", mode = "markers", 
                   marker = list(size = 6, color = Listcol[5], line = list(color = "black")),
                   name = paste(y1_name, "Sim"))
  
  if (!is.null(obs_yx_1)) {
    plot1 <- plot1 %>%
      add_trace(data = obs_yx_1, x = obs_yx_1[[1]], y = obs_yx_1[[2]], 
                type = "scatter", mode = "markers",
                marker = list(size = 6, color = Listcol[3], line = list(color = "black")),
                name = paste(y1_name, "Obs"))
  }
  
  plot1 <- plot1 %>%
    add_trace(data = gaug_yx_1, x = gaug_yx_1[[1]], y = gaug_yx_1[[2]],
              type = "scatter", mode = "markers",
              marker = list(size = 9, color = Listcol[6], line = list(color = "black", width = 1)),
              name = paste(y1_name, "Gauged")) %>%
    layout(xaxis = list(title = xaxis_title1),
           yaxis = list(title = yaxis_title1))
  
  # Second plot: y2 vs x2
  plot2 <- plot_ly(data = sim_yx_2, x = sim_yx_2[[1]], y = sim_yx_2[[2]], 
                   type = "scatter", mode = "markers", 
                   marker = list(size = 6, color = Listcol[5], line = list(color = "black")),
                   name = paste(y2_name, "Sim"))
  
  if (!is.null(obs_yx_2)) {
    plot2 <- plot2 %>%
      add_trace(data = obs_yx_2, x = obs_yx_2[[1]], y = obs_yx_2[[2]], 
                type = "scatter", mode = "markers",
                marker = list(size = 6, color = Listcol[3], line = list(color = "black")),
                name = paste(y2_name, "Obs"))
  }
  
  plot2 <- plot2 %>%
    add_trace(data = gaug_yx_2, x = gaug_yx_2[[1]], y = gaug_yx_2[[2]],
              type = "scatter", mode = "markers",
              marker = list(size = 9, color = Listcol[6], line = list(color = "black", width = 1)),
              name = paste(y2_name, "Gauged")) %>%
    layout(xaxis = list(title = xaxis_title2),
           yaxis = list(title = yaxis_title2))
  
  # Text annotations
  annotations <- list(
    list(
      x = 0.24,
      y = 0.90,
      text = paste("<b>", y1_name, " = f(", x1_name, ")</b>", sep = ""),
      font = list(size = 14),
      xref = "paper", yref = "paper",
      xanchor = "center", yanchor = "bottom",
      showarrow = FALSE
    ),
    list(
      x = 0.76,
      y = 0.90,
      text = paste("<b>", y2_name, " = f(", x2_name, ")</b>", sep = ""),
      font = list(size = 14),
      xref = "paper", yref = "paper",
      xanchor = "center", yanchor = "bottom",
      showarrow = FALSE
    )
  )
  
  # Combine subplots
  combined_plot <- subplot(plot1, plot2, nrows = 1, titleX = TRUE, titleY = TRUE) %>%
    layout(title = paste("<b>Rating Curves @ ", station_name, "</b>", sep = ""),
           annotations = annotations)
  
  # Save plot as interactive HTML
  htmlwidgets::saveWidget(
    config(combined_plot,
           scrollZoom = TRUE,
           displaylogo = FALSE,
           modeBarButtonsToAdd = list('drawline', 'drawopenpath', 'drawclosedpath',
                                      'drawcircle', 'drawrect', 'eraseshape')),
    paste0("Rating_Curve@", station_name, "_", y1_name, x1_name, "_", y2_name, x2_name, ".html")
  )
}



# ------------------------------------------------------------------------------
# Function: Plot_interannual
# Description: Plots interannual mean data (both daily and monthly) for a specific variable
#              across different datasets (observed, simulated, best calibration).
#
# Inputs:
#   - station_name: The name of the station for the plot title.
#   - variablename: The name of the variable being plotted.
#   - obs: Data frame containing observed data.
#   - DayMonth_ini_plot: The initial day-month for plotting purposes.
#   - qsim_0: Data frame containing the first simulation (optional).
#   - qsim_tests: Data frame containing test simulations (optional).
#   - qsim_bestcal: Data frame containing the best calibration simulation (optional).
#   - Date_ini: Start date for data filtering (optional).
#   - Date_end: End date for data filtering (optional).
#
# Outputs:
#   - An interactive plot showing the interannual daily and monthly mean for the specified
#     variable across different datasets. The plot is saved as an HTML file with the name format:
#     "InterAnnual@<station_name>_<variablename>.html".
#
# Example:
#   - `Plot_interannual("Station1", "Q", observed_data, "01-jan", qsim_0, qsim_tests, qsim_bestcal, "01-01-2000", "31-12-2020")`
#     This will create an interactive plot comparing observed, simulated, and calibrated interannual means for the variable "Q".
#
# ------------------------------------------------------------------------------

Plot_interannual <- function(station_name,variablename,obs,DayMonth_ini_plot,
                             qsim_0=NULL,qsim_tests=NULL,qsim_bestcal=NULL,
                             Date_ini=NULL,Date_end=NULL){
  
  # Compute daily and monthly interannual means for observed data
  d1 <- Compute_day_interannual(obs, Date_ini, Date_end, DayMonth_ini_plot)
  m1 <- Compute_month_interannual(obs, Date_ini, Date_end, DayMonth_ini_plot)
  
  # Compute for qsim_0 if provided
  if (!is.null(qsim_0)) {
    d2 <- Compute_day_interannual(qsim_0, Date_ini, Date_end, DayMonth_ini_plot)
    m2 <- Compute_month_interannual(qsim_0, Date_ini, Date_end, DayMonth_ini_plot)
  }
  
  # Compute for qsim_tests if provided
  if (!is.null(qsim_tests)) {
    d3 <- Compute_day_interannual(qsim_tests, Date_ini, Date_end, DayMonth_ini_plot)
    m3 <- Compute_month_interannual(qsim_tests, Date_ini, Date_end, DayMonth_ini_plot)
  }
  
  # Compute for qsim_bestcal if provided
  if (!is.null(qsim_bestcal)) {
    d4 <- Compute_day_interannual(qsim_bestcal, Date_ini, Date_end, DayMonth_ini_plot)
    m4 <- Compute_month_interannual(qsim_bestcal, Date_ini, Date_end, DayMonth_ini_plot)
  }
  
  # Initialize the interactive plot with observed data
  GraphQ <- plot_ly() %>%
    add_trace(data = d1, x = d1$date, y = d1$q_intAn,
              xaxis = list(title = "Q_day_interAnn", tickformat = "%d-%b"),
              type = "scatter", mode = "lines",
              text = ~paste("n: ", count),
              line = list(color = "#56B4E9"),
              name = paste("Obs Int-Ann-Daily Mean", variablename, sep = " ")) %>%
    add_trace(data = m1, x = m1$date, y = m1$q_intAn,
              xaxis = list(title = "Q_month_interAnn", tickformat = "%d-%b"),
              type = "scatter", mode = "lines",
              text = ~paste("n: ", count),
              line = list(color = "#56B4E9", dash = "dash"),
              name = paste("Obs Int-Ann-Monthly Mean", variablename, sep = " "))
  
  # Add qsim_0 traces if provided
  if (!is.null(qsim_0)) {
    GraphQ <- GraphQ %>%
      add_trace(data = d2, x = d2$date, y = d2$q_intAn,
                xaxis = list(title = "Q_day_interAnn", tickformat = "%d-%b"),
                type = "scatter", mode = "lines",
                text = ~paste("n: ", count),
                line = list(color = "orange"),
                name = paste("qsim_0 Int-Ann-Daily Mean", variablename, sep = " ")) %>%
      add_trace(data = m2, x = m2$date, y = m2$q_intAn,
                xaxis = list(title = "Q_month_interAnn", tickformat = "%d-%b"),
                type = "scatter", mode = "lines",
                text = ~paste("n: ", count),
                line = list(color = "orange", dash = "dash"),
                name = paste("qsim_0 Int-Ann-Monthly Mean", variablename, sep = " "))
  }
  
  # Add qsim_tests traces if provided
  if (!is.null(qsim_tests)) {
    GraphQ <- GraphQ %>%
      add_trace(data = d3, x = d3$date, y = d3$q_intAn,
                xaxis = list(title = "Q_day_interAnn", tickformat = "%d-%b"),
                type = "scatter", mode = "lines",
                text = ~paste("n: ", count),
                line = list(color = "green"),
                name = paste("qsim_test Int-Ann-Daily Mean", variablename, sep = " ")) %>%
      add_trace(data = m3, x = m3$date, y = m3$q_intAn,
                xaxis = list(title = "Q_month_interAnn", tickformat = "%d-%b"),
                type = "scatter", mode = "lines",
                text = ~paste("n: ", count),
                line = list(color = "green", dash = "dash"),
                name = paste("qsim_test Int-Ann-Monthly Mean", variablename, sep = " "))
  }
  
  # Add qsim_bestcal traces if provided
  if (!is.null(qsim_bestcal)) {
    GraphQ <- GraphQ %>%
      add_trace(data = d4, x = d4$date, y = d4$q_intAn,
                xaxis = list(title = "Q_day_interAnn", tickformat = "%d-%b"),
                type = "scatter", mode = "lines",
                text = ~paste("n: ", count),
                line = list(color = "violet"),
                name = paste("qsim_bestcal Int-Ann-Daily Mean", variablename, sep = " ")) %>%
      add_trace(data = m4, x = m4$date, y = m4$q_intAn,
                xaxis = list(title = "Q_month_interAnn", tickformat = "%d-%b"),
                type = "scatter", mode = "lines",
                text = ~paste("n: ", count),
                line = list(color = "violet", dash = "dash"),
                name = paste("qsim_bestcal Int-Ann-Monthly Mean", variablename, sep = " "))
  }
  
  # Final layout and formatting
  GraphQ <- GraphQ %>%
    layout(title = paste("<b>", station_name, ": Inter-Annual Mean ", variablename, "</b>", sep = " "),
           xaxis = list(title = "Date", tickformat = "%d-%b"),
           yaxis = list(title = variablename))
  
  # Save the interactive plot as an HTML file
  htmlwidgets::saveWidget(config(GraphQ, scrollZoom = TRUE, displaylogo = FALSE,
                                 modeBarButtonsToAdd = list('drawline',
                                                            'drawopenpath',
                                                            'drawclosedpath',
                                                            'drawcircle',
                                                            'drawrect',
                                                            'eraseshape')),
                          paste("InterAnnual@", station_name, "_", variablename, ".html"))
}


# ------------------------------------------------------------------------------
# Function: VAR_bound_ggPlot
# Description: Plots a variable of interest (e.g., discharge, sand flux, water depth, velocity) over time.
#              The plot includes:
#                - A shaded area representing the minimum and maximum bounds from ensemble simulations,
#                - A line for the best-calibrated simulation,
#                - Points for observed data.
#
# Inputs:
#   - variable: Character string. The variable to plot ("Q", "Qss", "h", or "u").
#   - sim: Data frame. Contains simulation ensemble with a 'date' column and one or more simulation columns.
#   - obs: Data frame. Observed data with the first column as date and the second as the observed values.
#   - bestcal: Data frame. Best-calibrated simulation with 'date' and one simulation column.
#
# Output:
#   - A ggplot object with all the above data overlaid for visual comparison.
#
# Example:
#   VAR_bound_ggPlot("Q", sim_data, observed_data, best_calibration)
#
# Notes:
#   - Dates in 'obs' and 'bestcal' must cover the date range of 'sim'.
#   - Y-axis label is automatically adapted to the variable.
#   - For variable "h", a reference horizontal line is added.
# ------------------------------------------------------------------------------

VAR_bound_ggPlot <- function(variable, sim, obs, bestcal) {
  
  # Filter observed data to match simulation date range
  obs <- subset(obs, as.Date(obs[, 1]) >= sim[[1, 1]])
  obs <- subset(obs, as.Date(obs[, 1]) <= sim[[nrow(sim), 1]])
  
  # Compute min and max bounds across all simulation columns (excluding date)
  q_bound <- sim %>%
    select(-date) %>%
    mutate(
      qmax = pmap_dbl(., max, na.rm = TRUE),
      qmin = pmap_dbl(., min, na.rm = TRUE)
    ) %>%
    select(qmin, qmax) %>%
    mutate(date = sim$date, .before = 1)
  
  # Merge all data sources by date
  merged_data <- merge(q_bound, obs, by.x = "date", by.y = names(obs)[1], all.x = TRUE)
  merged_data <- merge(merged_data, bestcal, by = "date", all.x = TRUE)
  
  # Start building the plot
  VAR_plot <- ggplot(merged_data) +
    geom_ribbon(aes(x = date, ymin = qmin, ymax = qmax), fill = 'grey30', alpha = 0.3) +
    geom_line(aes(x = date, y = qmin), color = 'grey30') +
    geom_line(aes(x = date, y = qmax), color = 'grey30') +
    geom_line(aes(x = date, y = bestcal[[2]]), color = 'violet', linewidth = 1, show.legend = TRUE) +
    geom_point(aes(x = date, y = obs[[2]]), color = 'red', size = 1, show.legend = TRUE) +
    labs(
      x = "Date",
      y = switch(variable,
                 "Q"   = expression(Discharge~(m^3~s^{-1})),
                 "Qss" = expression(Sand~Flux~(t~day^{-1})),
                 "h"   = expression(Water~Depth~(m)),
                 "u"   = expression(Velocity~(m~s^{-1})),
                 "Unknown Variable")
    ) +
    scale_x_date(date_breaks = "2 months", date_labels = "%b") +
    theme_bw() +
    theme(
      axis.title.x = element_blank(),
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  # Add a reference line for water depth if applicable
  if (variable == "h") {
    VAR_plot <- VAR_plot +
      geom_hline(yintercept = 14.5, color = "blue", linetype = "dashed", linewidth = 0.8)
  }
  
  return(VAR_plot)
}


# ------------------------------------------------------------------------------
# Function: Temp_Analysis_ggPlot
# Description: Performs a temporal sensitivity analysis using the Morris or Sobol method
#              and generates a time series plot of sensitivity indices.
#
# Inputs:
#   - method: Character string. Either "Morris" or "Sobol".
#   - sim: Data frame. First column is 'date', other columns are simulation outputs.
#   - par_names: Character vector. Names of parameters used in the analysis.
#   - n: Integer. Required for Sobol analysis, indicating number of runs (default NULL).
#   - morris_sample: Morris object. Required for Morris analysis (default NULL).
#   - chunk_size: Integer. Size of chunks for parallel processing (default = 10).
#   - n_cores: Integer. Number of cores to use for parallel computing (default = 7).
#
# Outputs:
#   - A list with:
#     - sens_plot: ggplot object of sensitivity indices over time.
#     - s: List or data frame of computed sensitivity results.
#
# Example:
#   Temp_Analysis_ggPlot("Morris", sim_data, par_names, morris_sample = morris_obj)
#   Temp_Analysis_ggPlot("Sobol", sim_data, par_names, n = 100)
# ------------------------------------------------------------------------------

Temp_Analysis_ggPlot <- function(method, sim, par_names, n = NULL, morris_sample = NULL,
                                 chunk_size = 10, n_cores = 7) {
  s <- list()
  
  # Split simulation rows into chunks for potential parallel processing
  chunk_indices <- split(1:nrow(sim), ceiling(seq_along(1:nrow(sim)) / chunk_size))
  
  # Use parallel computing for Sobol method when number of simulations is large
  if ((ncol(sim) - 1) > 5000) {
    plan(multicore, workers = n_cores)
    
    # Function to compute Sobol indices on a single chunk
    calculate_sobol_chunk <- function(chunk, sim, n, par_names) {
      chunk_results <- lapply(chunk, function(i) {
        Y <- unlist(sim[i, 2:ncol(sim)])
        sobol_res <- sobol_indices(
          Y = Y, N = n, params = par_names,
          first = "jansen", total = "jansen",
          boot = TRUE, R = 500
        )
        sobol_res$results %>%
          as_tibble() %>%
          mutate(date = sim$date[i])
      })
      bind_rows(chunk_results)
    }
    
    # Run Sobol sensitivity analysis in parallel across chunks
    s <- future_map(
      .x = chunk_indices,
      .f = ~calculate_sobol_chunk(.x, sim = sim, n = n, par_names = par_names),
      .options = furrr_options(seed = TRUE)
    )
    s <- bind_rows(s)  # Combine all results into a single data frame
    
  } else {
    # Serial computation for Morris or Sobol method (small simulations)
    for (i in 1:nrow(sim)) {
      if (method == "Morris") {
        morris_var <- morris_sample
        tell(morris_var, unlist(sim[i, 2:ncol(sim)]))
        
        mu_star <- map_df(as_tibble(morris_var$ee), ~ mean(abs(.x), na.rm = TRUE))
        sigma    <- map_df(as_tibble(morris_var$ee), ~ sd(.x, na.rm = TRUE))
        
        s[[i]] <- tibble(
          mustar = c(t(mu_star)),
          sigma = c(t(sigma)),
          parameters = colnames(mu_star),
          date = sim$date[i]
        )
      } else if (method == "Sobol") {
        Y <- unlist(sim[i, 2:ncol(sim)])
        s[[i]] <- sobol_indices(
          Y = Y, N = n, params = par_names,
          first = "jansen", total = "jansen",
          boot = TRUE, R = 500
        )$results %>%
          as_tibble() %>%
          mutate(date = sim$date[i])
      }
    }
    s <- bind_rows(s)
  }
  
  # Plot generation depending on the method
  if (method == "Morris") {
    sens_plot <- ggplot(s) +
      geom_line(aes(x = date, y = mustar), color = 'tomato3', linewidth = 0.75) +
      geom_line(aes(x = date, y = sigma), color = 'steelblue', linewidth = 0.75) +
      scale_color_manual(name = "Morris indices", values = c('mustar' = 'tomato3', 'sigma' = 'steelblue')) +
      guides(color = guide_legend(override.aes = list(shape = c(16, 16)))) +
      scale_fill_manual(values = c('tomato3', 'steelblue')) +
      labs(x = 'Date', y = expression(mu^"* and "~sigma)) +
      facet_grid(rows = vars(parameters)) +
      theme_bw() +
      theme(legend.position = 'bottom')
    
  } else if (method == "Sobol") {
    sens_plot <- ggplot(s) +
      geom_hline(yintercept = 0, linetype = 'dotted') +
      geom_ribbon(aes(x = date, ymin = low.ci, ymax = high.ci, fill = sensitivity), alpha = 0.3) +
      geom_line(aes(x = date, y = low.ci, color = sensitivity), linewidth = 0.25, alpha = 0.3) +
      geom_line(aes(x = date, y = high.ci, color = sensitivity), linewidth = 0.25, alpha = 0.3) +
      geom_line(aes(x = date, y = original, color = sensitivity), linewidth = 0.75) +
      scale_color_manual(values = c('tomato3', 'steelblue')) +
      scale_fill_manual(values = c('tomato3', 'steelblue')) +
      labs(
        x = 'Date', y = 'First and total order sensitivity',
        color = 'Sensitivity index', fill = 'Sensitivity index'
      ) +
      facet_grid(rows = vars(parameters)) +
      coord_cartesian(ylim = c(-0.1, 1.1)) +
      theme_bw() +
      theme(legend.position = 'bottom')
  }
  
  return(list(sens_plot = sens_plot, s = s))
}
