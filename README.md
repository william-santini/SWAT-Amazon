# SWAT-Amazon

`SWAT-Amazon` is a regionally adapted version of the [SWAT2012](https://swat.tamu.edu/) hydrological model, developed to improve the representation of water and sediment routing processes in the Amazon Basin and other large-scale river basins. [(Santini, 2020;](http://dx.doi.org/10.13140/RG.2.2.32547.60964) [Santini et al., 2025)]() 
This modeling framework consists of a **Fortran-based executable (SWAT-Amazon.exe)**, derived from the standard SWAT2012 code, and an **R Notebook (Run-SWAT-Amazon.Rmd)** designed to support the entire modeling workflow. 
This notebook enable model run, simulation analysis, interactive result visualization, as well as sensitivity analysis and calibration procedures, with the [SWATrunR](https://github.com/chrisschuerz/SWATrunR?tab=readme-ov-file) package [(Schürz et al., 2019)](https://zenodo.org/records/6517027).


![SWAT-Amazon](https://github.com/user-attachments/assets/6d56a93b-cc14-40bb-97d3-1bdc14e33412)


## What's New in SWAT-Amazon?

`SWAT-Amazon` introduces several enhancements over the standard SWAT2012 model, particularly in the representation of water and sediment routing processes. Users can now select among multiple water routing methods by adjusting the `EQROUTING` parameter in the `.BSN` file. This selection can be managed directly from the R Notebook `Run-SWAT-Amazon.Rmd`. 
A total of five routing options are available:

**Table 1:** Water Routing Methods in SWAT-Amazon

| `EQROUTING` | Water Routing Method (`.rte` file)                      | Boundary Condition Requirement         |
|-------------|---------------------------------------------------------|----------------------------------------|
| 0           | Variable storage method *(Default SWAT method)*         | No                                     |
| 1           | Muskingum method *(Default SWAT method)*                | No                                     |
| 2           | Muskingum with variable K *(New; see Santini, 2020)*    | No                                     |
| 3           | Kinematic wave method *(New; see Santini et al., 2025)* | No                                     |
| 4           | Diffusive wave method *(New; see Santini et al., 2025)* | **Yes**: requires `hdwnstrm.TXT` file  |

> **Note:**  
> In the *Muskingum with variable K* method (Santini, 2020), the storage time `K` varies with the water level. This allows the model to dynamically increase the lag time of flood wave propagation—and consequently, the volume of water stored—when the floodplain becomes active.  
>  
> For the hydraulic wave methods (*Kinematic* and *Diffusive*), a conceptual **floodplain reservoir** can be activated to simulate flood wave attenuation. Two floodplain geometries are available:  
> - A **rectangular cross-section**, defined by the width coefficient `KFP`;  
> - A **triangular cross-section**, defined by the slope angle `THETA_FP`.  
> The parameter `FPGEOM` controls the geometry:  
> - `FPGEOM = 0`: rectangular floodplain cross-section;  
> - `FPGEOM = 1`: triangular floodplain cross-section.

**The sand and fine sediment routing method cannot be changed: `SWAT-Amazon` exclusively uses the new sediment routing modules developed for this version.** The default SWAT sediment routing methods are not available due to extensive modifications to the original code.

### Parameter Description Table

**Table 2:** Parameters that can be calibrated in the new routing modules of SWAT-Amazon according to [Santini et al. (2025)](#)

| Variable name | Unit         | Routing module | Definition                                                                                                     | Input file |
|---------------|--------------|----------------|----------------------------------------------------------------------------------------------------------------|------------|
| `CHD`         | (m)          | Water          | Water height that triggers the floodplain activation                                                           | `.rte`     |
| `CHW2`        | (m)          | Water          | Width of the rectangular main channel                                                                          | `.rte`     |
| `CH_S2`       | (–)          | Water          | Channel bed slope, calculated from the MERIT DEM with QWAT                                                     | `.rte`     |
| `KFP`         | (–)          | Water          | Coefficient to determine the floodplain width: *W_fp = k_fp × B* (rectangular cross-section)                   | `.rte`     |
| `THETA_FP`    | (rad)        | Water          | Angle of the floodplain riverward slope (triangular cross-section)                                             | `.rte`     |
| `CH_N2`       | (s·m⁻¹ᐟ³)     | Water         | Manning coefficient                                                                                            | `.rte`     |
| `CNFP`        | (–)          | Water          | Coefficient for increasing flow resistance in the main channel when the floodplain is active                   | `.rte`     |
| `HCH`         | (m)          | Water          | Water height that ends the additional bed roughness influence                                                  | `.rte`     |
| `CNCH`        | (–)          | Water          | Coefficient for increasing flow resistance in the main channel during low flows                                | `.rte`     |
| `DSS`         | (m)          | Sand           | Arithmetic mean diameter of suspended sands                                                                    | `.rte`     |
| `DB`          | (m)          | Sand           | Arithmetic mean diameter of riverbed sands                                                                     | `.rte`     |
| `S`           | (–)          | Sand           | Relative sand density                                                                                          | `.rte`     |
| `BETA`        | (–)          | Sand           | Ratio of suspended sand to eddy diffusivity, imposed or calculated using Santini et al. (2019)                 | `.rte`     |
| `NU`          | (m²·s⁻¹)     | Sand           | Kinematic water viscosity                                                                                      | `.rte`     |
| `SIGMA`       | (–)          | Sand           | Coefficient to determine *k_s′*: *k_s′ = σ × d_b*                                                              | `.rte`     |
| `KCH`         | (–)          | Sand           | Main channel susceptibility to erosion (riverbed only), value between 0 and 1                                  | `.rte`     |
| `CBK`         | (t·m⁻³)      | Sand           | Concentration of bank and bar inputs (constant)                                                                | `.rte`     |
| `ETA`         | (–)          | Sand           | Correction exponent for transport capacity when the floodplain is active                                       | `.rte`     |


## Download and Installation

### Downloads

- **`SWAT-Amazon.exe`**  
  Download the executable file and place it in your SWAT project working directory:  
  `your_project/scenarios/Default/TxtInOut/`  
  *No installation is required.*

- **Run-SWAT-Amazon.Rmd**  
  Download the R Notebook and it dependency R scripts:
  - **tools_and_functions.R**
  - **setpar_test.R**
  - **setpar_paral_test.R**
  - **setpar_bestcal.R**
  - **setpar_sensi.R**

- **Supplementary files**  
  Download the required additional files to ensure proper execution of the model:
  - **`station_obs.xlsx`** — **Observation file** to be placed in the same directory as the Notebook `Run-SWAT-Amazon.Rmd`
  - **`Qss_forcing.PRN`** — Input file to force **Suspended Sand load** in reaches, if needed (to be placed in `TxtInOut`)
  - **`Qsf_forcing.PRN`** — Input file to force **Suspended Fine load** in reaches, if needed (to be placed in `TxtInOut`).
  - **`hdwnstrm.TXT`** — File containing **boundary water levels** for simulations using the Diffusive Wave option (to be placed in `TxtInOut`)

> **Note:** The file `How_to_generate_inputs_files.TXT` provides instructions on how to create or modify the supplementary files listed above.

### Structure your Project Folder

your_project/  
├── TxtInOut/  
│   ├── SWAT-Amazon.exe  
│   ├── Qss_forcing.PRN  
│   ├── Qsf_forcing.PRN  
│   ├── hdwnstrm.TXT  
│   └── ... (all the txtInOut files generated by the standard SWAT2012 model)  
├── Run-SWAT-Amazon.Rmd  
├── tools_and_functions.R  
├── setpar_test.R  
├── setpar_bestcal.R  
├── setpar_paral_test.R 
├── setpar_sensi.R   
└── station_obs.xlsx  

### Install `SWATrunR`

The final step is to install the [`SWATrunR`](https://github.com/chrisschuerz/SWATrunR?tab=readme-ov-file) package in your R environment. This package enables interaction with the SWAT-Amazon executable directly from R.

To install it, open your R IDE (e.g., RStudio) and run the following command:

```r
# If the package remotes is not installed run first:
install.packages("remotes")
remotes::install_github("chrisschuerz/SWATrunR")
```

**!!! It is highly recommended to learn the basics of the `SWATrunR` package before starting with `SWAT-Amazon` !!!**

## Getting Started

### Load the demo or use your own SWAT project

You can download the demo project [here](#) or use the `TxtInOut` folder from your own SWAT project.
 
### Set the General Parameters

You can define the working directory and the path to your SWAT project in the R code chunk labeled `{r General parameters}`.

### Add the New `SWAT-Amazon` Parameters to the `TxtInOut` files

Since SWAT-Amazon introduces additional parameters, it is necessary to add them to the `.RTE` and `.BSN` files within the `TxtInOut` directory of your SWAT project.  
This can be done automatically using the code chunk `{r Adding new parameters in TxtInOut files}` provided in the Notebook.

> **Note:** This operation only needs to be performed once.  
> To prevent accidental modifications or duplication, it is recommended to **comment out the code chunk** after it has been executed successfully.


### Load Observed Data
Use the Template_Station_SWAT.xlsx files to load the observed data in your R environement with the chunk `{r Loading observation data}`

```
Obs_path <- "Stations_obs.xlsx"

Obs_station_template <- read_excel(Obs_path, sheet = "Your_Station",
                                   col_types = c("date", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric",
                                   "date", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric",
                                   "numeric", "numeric", "numeric","numeric","numeric","numeric"))
```

### Configure Simulation
Now, you can configure the simulation in the chunk `{r Parametring simulations}`:

- Setting simulation period 
```
Date_ini <- as.Date("2000-01-01",  format = "%Y-%m-%d")
Date_fin <- as.Date("2024-12-31",  format = "%Y-%m-%d")
```

- Modification of the SWAT file `BASINS.BSN`
```
bsn_file <- list.files(project_path,pattern = ".bsn",full.names = TRUE)
modif_par_bsn(bsn_file,"IPET", 2)
modif_par_bsn(bsn_file,"EQROUTING", 4)
modif_par_bsn(bsn_file,"BCFACTOR", 1)
```

- Routing headwaters or not: modifying the SWAT file `FILE.CIO`:
```
# Function to be written... the FILE.CIO file need to be manually modificated:
# By default, headwaters are not routed in SWAT2012
# I_SUBW = 0 : Default value: Headwaters are not routed (and it is not possible to force the Qss and Qsf with the .PRN files)
# I_SUBW = 1 : Headwaters are routed (and Qss or Qsf can be forced if required with the .PRN files)
# NB: Qss and Qsf forcing is achieved through the Qss_forcing.prn or Qsf_forcing.PRN input files
```

- Settings outputs

```
# List of sub-basins in which outputs are to be displayed
sub_basins = c(19, 5, 20, 2, 21)

l_out_files <- list.files(project_path, pattern = "output", full.names = TRUE) # find the output files in the txtInOut

q_set   <- define_output(file = 'rch', variable = 'FLOW_OUT', unit = sub_basins)
h_set   <- define_output(file = 'rch', variable = 'WAT_DEP', unit = sub_basins)
u_set   <- define_output(file = 'rch', variable = 'AV_VEL', unit = sub_basins)
qsf_set <- define_output(file = 'sed', variable = 'FINES_OUT', unit = sub_basins)
qss_set <- define_output(file = 'sed', variable = 'SAND_OUT', unit = sub_basins)

# Define the list of the output variables
l_output  <- list(q = q_set, h = h_set, u = u_set, qsf = qsf_set, qss = qss_set)
```

### Prepare your Parameter Sets
Parameter changes in a R notebook is already available thanks to parameter sets as described in [`SWATrunR`](https://github.com/chrisschuerz/SWATrunR?tab=readme-ov-file).
In `SWAT-Amazon`, 3 main parameter set are considered:

  - **setpar_test.R** is for testing changes
  - **setpar_bestcal.R** is for keeping the best simulation
  - **setpar_paral_test.R** is for parallel processing

Example of parameter set (setpar_bestcal.R) for a subbasin 21:

```
setpar_bestcal <- c(
  # Reach & flow routing
    "CH_S2_sub21::CH_S2.rte      | change = absval | sub = 21" = 3.0e-05,
    "CH_N2_sub21::CH_N2.rte      | change = absval | sub = 21" = 1/44, 
    "CNCH_sub21::CNCH.rte        | change = absval | sub = 21" = 0.4,
    "HCH_sub21::HCH.rte          | change = absval | sub = 21" = 14.5,
    "CHD_sub21::CHD.rte          | change = absval | sub = 21" = 14.59,
    "CH_W2_sub21::CHW2.rte       | change = absval | sub = 21" = 750,  
    "FPGEOM_sub21::FPGEOM.rte    | change = absval | sub = 21" = 1,
    "THETAFP_sub21::THETA_FP.rte | change = absval | sub = 21" = 0.0002,
    "CNFP_sub21::CNFP.rte        | change = absval | sub = 21" = 1,

  # Sand routing    
    "DB_sub21::DB.rte            | change = absval | sub = 21" = 219.4, 
    "DSS_sub21::DSS.rte          | change = absval | sub = 21" = 80,
    "CBK_sub21::CBK.rte          | change = absval | sub = 21" = 188.1,
    "KCH_sub21::KCH.rte          | change = absval | sub = 21" = 0.01,
    "BETA_sub21::BETA.rte        | change = absval | sub = 21" = 1.64,
    "ETA_sub21::ETA.rte          | change = absval | sub = 21" = 6.95
)
```

### Run the Model
Use the `SWATrunR` function `run_swat2012()` to run `SWAT-Amazon`.

- **`{r First Run without any calibration}`**
```
setpar_0 <- c()
sim_0 <- run_swat2012(project_path = project_path, output = l_output,
                      parameter = setpar_0, output_interval = "d",
                      start_date = Date_ini, end_date = Date_fin,
                      years_skip = 2, add_parameter = TRUE, keep_folder = F)
```
- **`{r Test Run}`**
```
source("setpar_tests.R") # load the corresponding parameter set

sim_tests <- run_swat2012(project_path = project_path, output = l_output,
                          parameter = setpar_tests, output_interval = "d",
                          start_date = Date_ini, end_date = Date_fin,
                          keep_folder = F, years_skip = 2)
```

- **`{r Best calibration}`**
```
source("setpar_bestcal.R")

sim_bestcal <- run_swat2012(project_path = project_path, output = l_output,
                            parameter = setpar_bestcal, output_interval = "d",
                            start_date = Date_ini, end_date = Date_fin,
                            keep_folder = F, years_skip = 2)
```

- **`{r Parallel processing}`**
```
n <- 1000 # Number of runs
source("setpar_paral_test.R")

sim_tests_tibble <- run_swat2012(project_path = project_path, output = l_output,
                                 parameter = setpar_paral_test, output_interval = "d",
                                 start_date = Date_ini, end_date = Date_fin,
                                 years_skip = 2, n_thread = 8)
```

### Display and Analyse Results

Several functions are available in the `tools_and_functions_global.R` file to help visualize and analyze simulation outputs. These functions are **not included in a package**, so users can **easily modify or extend** them as needed.

All functions rely on the **`plotly`** package for interactive visualization.

#### Available functions:

- **`Graphstation()`**  
  Displays simulated and observed time series for a selected variable (`h`, `u`, `Q`, `Qss`, `Qsf`, etc.) and station.  
  It also show results from parallel simulations and sort them based on the best combinations of objective function scores.

- **`Plot_calib_curve()`**  
  Plots the rating curves for a simulation and compares them with observed data.
  Useful for evaluating the consistency between simulated and measured discharge-sediment relationships.

- **`Plot_interannual()`**  
  Displays interannual simulations for a selected variable across years to highlight long-term trends or anomalies.

- **`monthly_average()`**  
  Computes monthly averages from daily or sub-daily time series.

- **`Compute_day_interannual()`**  
  Computes the interannual average of each day of the year (e.g., mean annual cycle) for a given variable.

- **`Compute_month_interannual()`**  
  Computes the interannual average of each calendar month for a given variable.

- **`Compute_gof()`**  
  Calculates objective functions (e.g., NSE, KGE, PBIAS) to assess model performance.

- **`Plot_gof()`**  
  Plots the results of the objective functions calculated for each run of the parallel processing (e.g., NSE vs. KGE, NSE vs. PBIAS), allowing visual comparison between simulations and for selecting the best run.

- **`VAR_bound_ggPlot()`**  
  Plots the simulation envelope (min–max range) from multiple runs of a Sobol Analysis, along with observed data and the best calibration. Useful for visualizing uncertainty and model variability over time.

- **`Temp_Analysis_ggPlot()`**  
  Performs temporal sensitivity analysis using either the Morris or Sobol method, computing sensitivity indices (e.g., μ*, σ, first-order, total-order) for each time step across all simulations.  
  The function supports chunk-based **parallel processing** for high-dimensional outputs and returns both a `ggplot` object and raw sensitivity data. Particularly useful for identifying time-dependent parameter influence in dynamic models.


**Example of use for subbasin 5 with the chunk `{r Display results @ 5}`**  

```
# To be configured:
station_name = "XXX"
code_station = "5"       # station code in station_obs.xlsx  (observations file)
n_sub = 5                # subbasin number
sim_name = "sim_tests"   # simulation to display in inter-annual graph and rating curve

# Observations
Obs_template = eval(parse(text = paste0("Obs_", code_station, "_template")))
obs_h <- data.frame(Obs_template$Date, Obs_template$h_obs)
obs_u <- data.frame(Obs_template$Date, Obs_template$u_obs)
obs_Q <- data.frame(Obs_template$Date, Obs_template$Q_obs)
obs_Qss <- data.frame(Obs_template$Date, Obs_template$Qss_obs*10^(6))

# Gaugings (punctual measurements)
gaug_h <- data.frame(Obs_template$Date_gauging, Obs_template$h_gauging)
gaug_u <- data.frame(Obs_template$Date_gauging, Obs_template$u_gauging)
gaug_Q <- data.frame(Obs_template$Date_gauging, Obs_template$Q_gauging)
gaug_Qss <- data.frame(Obs_template$Date_gauging, Obs_template$Qss_gauging*10^(6))

# Display time-series results
Graphstation(station_name,"h", obs_h, gaug_h,
             eval(parse(text = paste0("sim_0$simulation$h_", n_sub))),
             eval(parse(text = paste0("sim_tests$simulation$h_", n_sub))),
             eval(parse(text = paste0("sim_bestcal$simulation$h_", n_sub))),
             eval(parse(text = paste0("sim_tests_tibble$simulation$h_", n_sub))) )

Graphstation(station_name,"u", obs_u, gaug_u,
             eval(parse(text = paste0("sim_0$simulation$u_", n_sub))),
             eval(parse(text = paste0("sim_tests$simulation$u_", n_sub))),
             eval(parse(text = paste0("sim_bestcal$simulation$u_", n_sub))),
             eval(parse(text = paste0("sim_tests_tibble$simulation$u_", n_sub))) )

Graphstation(station_name,"Q", obs_Q, gaug_Q,
             eval(parse(text = paste0("sim_0$simulation$q_", n_sub))), 
             eval(parse(text = paste0("sim_tests$simulation$q_", n_sub))),
             eval(parse(text = paste0("sim_bestcal$simulation$q_", n_sub))),
             eval(parse(text = paste0("sim_tests_tibble$simulation$q_", n_sub))) )

Graphstation(station_name,"Qss", obs_Qss, gaug_Qss,
             eval(parse(text = paste0("sim_0$simulation$qss_", n_sub))),
             eval(parse(text = paste0("sim_tests$simulation$qss_", n_sub))),
             eval(parse(text = paste0("sim_bestcal$simulation$qss_", n_sub))),
             eval(parse(text = paste0("sim_tests_tibble$simulation$qss_", n_sub))) )

# Display inter-annual results
variablename <- "h" 
obs <- data.frame(Obs_template$Date, Obs_template$h_obs)
sim <- data.frame(eval(parse(text = paste0(sim_name, "$simulation$h_", n_sub)))$date,
                  eval(parse(text = paste0(sim_name, "$simulation$h_", n_sub)))$run_1 )

Plot_interannual(station_name, variablename, obs, qsim_test = sim, "01-09")
 
variablename <- "u"
obs <- data.frame(Obs_template$Date, Obs_template$u_obs)
sim <- data.frame(eval(parse(text = paste0(sim_name, "$simulation$u_", n_sub)))$date,
                  eval(parse(text = paste0(sim_name, "$simulation$u_", n_sub)))$run_1 )

Plot_interannual(station_name, variablename, obs, qsim_test = sim, "01-09")
 
variablename <- "Q"
obs <- data.frame(Obs_template$Date, Obs_template$Q_obs)
sim <- data.frame(eval(parse(text = paste0(sim_name, "$simulation$Q_", n_sub)))$date,
                  eval(parse(text = paste0(sim_name, "$simulation$Q_", n_sub)))$run_1 )

Plot_interannual(station_name, variablename, obs, qsim_test = sim, "01-09")

variablename <- "Qss"
obs <- data.frame(Obs_template$Date, Obs_template$Qss_obs)
sim <- data.frame(eval(parse(text = paste0(sim_name, "$simulation$Qss_", n_sub)))$date,
                  eval(parse(text = paste0(sim_name, "$simulation$Qss_", n_sub)))$run_1 )

Plot_interannual(station_name, variablename, obs, qsim_test = sim, "01-09")

# Rating curves
gaug_hQ <- data.frame(Obs_template$h_gauging, Obs_template$Q_gauging)
obs_hQ  <- data.frame(Obs_template$h_obs, Obs_template$Q_obs)
sim_hQ  <- data.frame(eval(parse(text = paste0(sim_name, "$simulation$h_", n_sub)))$run_1,
                      eval(parse(text = paste0(sim_name, "$simulation$q_", n_sub)))$run_1 )

gaug_hu <- data.frame(Obs_template$h_gauging, Obs_template$u_gauging)
obs_hu  <- data.frame(Obs_template$h_obs, Obs_template$u_obs)
sim_hu  <- data.frame(eval(parse(text = paste0(sim_name, "$simulation$h_", n_sub)))$run_1,
                      eval(parse(text = paste0(sim_name, "$simulation$u_", n_sub)))$run_1 )


Plot_calib_curve(station_name,"h","Q",gaug_hQ, obs_yx_1 = obs_hQ , sim_hQ,
                              "h","u",gaug_hu, obs_yx_2 = obs_hu, sim_hu)

```

### Going Further

#### Suggested Calibration Procedure

The calibration strategy for stations with robust, long-term hydro-sediment monitoring is:
- Start by calibrating Q in each reach, for 〖h< h〗_f only, using the SWAT’s default hydrologic parameters.
- Calibrate Q, considering floodplain effects, using h_f, C_nfp and k_fp  (or θ_fp).
- Calibrate u and h by adjusting n and B only; Q is unaffected by this calibration.
- Check the relationships Q(h) and u(h), revisiting step 3 if needed.
- Compute the Q_s (h,u,Q), independently of n and B. If necessary, adjust Q_s using parameters in Table 1, particularly d_b, the most sensible parameter.

It is important to emphasize that the optimal calibration for water discharge may not align with the best calibration for water level, velocity, and sand load time series. A compromise must be made. 


#### Sensitivity Analysis




## Contact
Created by William Santini (william.santini@ird.fr) and Alexandre Delort-Ylla (alexandre.delort-ylla@ird.fr).

## References
Santini, W., Camenen, B., Le Coz, J., Vauchel, P., Guyot, J.-L., Lavado, W., Carranza, J., Paredes, M. A., Pérez Arévalo, J. J., Arévalo, N., Espinoza Villar, R., Julien, F., and Martinez, J.M.: An index concentration method for suspended load monitoring in large rivers of the Amazonian foreland, Earth Surface Dynamics, 7, 515–536, https://doi.org/10.5194/esurf-7-515-2019, **2019**.

Santini, W.: Caractérisation de la dynamique hydro-sédimentaire du bassin de l’Ucayali (Pérou), par une approche intégrant réseau de mesures, télédétection et modélisation hydrologique, PhD thesis, Université Toulouse III - Paul Sabatier, Toulouse, France, **2020**.

Santini, W., Delort-Ylla, A., Martinez, J.M., Lavado, W., Camenen, B., Le Coz, J., Roussillon, J., Pérez-Arévalo, J.J., & Molina-Carpio, J.: Coupling Remote Sensing and Modelling for Hydro-Sediment Flux Monitoring in the Amazon Basin: The Ucayali Case Study. **Submitted**.




