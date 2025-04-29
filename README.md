# SWAT-Amazon
* [New Modules for Water and Sediment Routing](#Overview-of-New-Modules-for-Water-and-Sediment-Routing)
* [Installation](#Installation)
* [Getting started](#Getting-started)
* [Calibration](#Calibration)
* [Contact](#Contact)

`SWAT-Amazon`  is a regionally adapted version of the [SWAT2012](https://swat.tamu.edu/) hydrological model, developed to improve the representation of water and sediment routing processes in the Amazon Basin and other large-scale river basins. [(Santini, 2020;](http://dx.doi.org/10.13140/RG.2.2.32547.60964) [Santini et al., 2025)]() 
This modeling framework consists of a **Fortran-based executable** (SWAT-Amazon.exe), derived from the standard SWAT2012 code, and an **R Notebook** (SWAT-Amazon-Calib.Rmd) designed to support the entire modeling workflow. 
This notebook enable model run, simulation analysis, interactive result visualization, as well as sensitivity analysis and calibration procedures, with the [SWATrunR](https://github.com/chrisschuerz/SWATrunR?tab=readme-ov-file) package [(Schürz et al., 2019)](https://zenodo.org/records/6517027).

<img src="img/SWATplusHybamDiagram.png" title="SWATplusHybam diagram" alt="plot" width="100%" style="display: block; margin: auto;" />

## Overview of the New Water and Sediment Routing Modules in SWAT-Amazon

SWAT-Amazon` introduces several enhancements over the standard SWAT2012 model, particularly in the representation of water and sediment routing processes. Users can now select among multiple water routing methods by adjusting the `EQROUTING` parameter in the `.BSN` file. This selection can be managed directly from the R Notebook `SWAT-Amazon-Calib`. A total of **five** routing options are available:

**Table 1:** Water Routing Methods in SWAT-Amazon

| `EQROUTING` | Water Routing Method (`.rte` file)                      | Boundary Condition Requirement         |
|-------------|---------------------------------------------------------|----------------------------------------|
| 0           | Variable storage method *(Default SWAT method)*         | No                                     |
| 1           | Muskingum method *(Default SWAT method)*                | No                                     |
| 2           | Muskingum with variable K *(New; see Santini, 2020)*    | No                                     |
| 3           | Kinematic wave method *(New; see Santini et al., 2025)* | No                                     |
| 4           | Diffusive wave method *(New; see Santini et al., 2025)* | **Yes**: requires `hdwnstrm.TXT` file  |

> **Note:**  
> In the *Muskingum with variable K* method, the parameter `K` varies with the water level. This allows the model to dynamically increase the lag time of flood wave propagation—and consequently, the volume of water stored—when the floodplain becomes active.  
>  
> For the hydraulic wave methods (*Kinematic* and *Diffusive*), a conceptual **floodplain reservoir** can be activated to simulate flood wave attenuation. Two floodplain geometries are available:  
> - A **rectangular cross-section**, defined by the width coefficient `KFP`;  
> - A **triangular cross-section**, defined by the slope angle `THETA_FP`.  
> The parameter `FPGEOM` controls the geometry:  
> - `FPGEOM = 0`: rectangular floodplain;  
> - `FPGEOM = 1`: triangular floodplain.

**The sand and fine sediment routing method cannot be changed: `SWAT-Amazon` exclusively uses the new sediment routing modules developed for this version. The default SWAT sediment routing method is not available due to extensive modifications to the original code.**

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

- **`SWAT-Amazon.exe` executable**  
  Download the executable file and place it in your SWAT project working directory:  
  `your_project/scenarios/Default/TxtInOut/`  
  *No installation is required.*

- **R Notebook**  
  Download the R Notebook **SWAT-Amazon-Calib.RMD** and it dependency R scripts:
  - **tools_and_functions_global.R**
  - **setpar_test.R**
  - **setpar_bestcal.R**
  - **setpar_paral_tibble.R**
  - **setpar_sensi.R**

- **Supplementary files**  
  Download the required additional files to ensure proper execution of the model:
  - `Template_Station_SWAT.xlsx` — Observation file to be placed in the same directory as the Notebook `SWAT-Amazon-Calib.Rmd`.
  - `Qss_forcing.PRN` — Input file to force **Suspended Sand load** in reaches, if needed (to be placed in `TxtInOut`).
  - `Qsf_forcing.PRN` — Input file to force **Suspended Fine load** in reaches, if needed (to be placed in `TxtInOut`).
  - `hdwnstrm.TXT` — File containing **boundary water levels** for simulations using the Diffusive Wave option (to be placed in `TxtInOut`).

> **Note:** The file `How_to_generate_inputs_files.TXT` provides instructions on how to create or modify the supplementary files listed above.

### Structure your Project Folder

your_project/  
├── txtInOut/  
│   ├── SWAT-Amazon.exe  
│   ├── Qss_forcing.PRN  
│   ├── Qsf_forcing.PRN  
│   ├── hdwnstrm.TXT  
│   └── ... (all the txtInOut files generated by the standard SWAT2012 model)  
├── SWAT-Amazon-Calib.Rmd  
├── tools_and_functions_global.R  
├── setpar_test.R  
├── setpar_bestcal.R  
├── setpar_paral_tibble.R   
└── setpar_sen.R   


### Install `SWATrunR`

The final step is to install the [`SWATrunR`](https://github.com/chrisschuerz/SWATrunR?tab=readme-ov-file) package in your R environment. This package enables interaction with the SWAT-Amazon executable directly from R.

To install it, open your R IDE (e.g., RStudio) and run the following command:

```r
# If the package remotes is not installed run first:
install.packages("remotes")
remotes::install_github("chrisschuerz/SWATrunR")
```
**It is highly recommended to learn the basics of the `SWATrunR` package before starting with `SWAT-Amazon`.**

## Getting Started

### Load the demo or use your own SWAT project

You can download the demo project [here](#) or use the `txtInOut` folder from your own SWAT project.
 
### Set the general parameters
The working directory and SWAT project path 

```{r General parameters}
# Setting the Working Directory
setwd("D:/your_working_directory")
# Loading the Notebook's functions
source("tools_and_functions_global.R")
# Loading the SWAT's TxtInOut
project_path <- "Input/TxtInOut"

# List of colors for visualizations:
Listcol <- c("#000000", "#E69F00", "#56B4E9", "#F0E442", "#009E73",  "#0072B2","#D55E00", "#CC79A7", "#00AFBB")

```

### Add Sew `SWAT-Amazon` Parameters to the `TxtInOut` files

Since SWAT-Amazon introduces additional parameters, it is necessary to add them to the `.RTE` and `.BSN` files within the `TxtInOut` directory of your SWAT project.  
This can be done automatically using the code chunk `{r Adding new parameters in TxtInOut files}` provided in the Notebook.

> **Note:** This operation only needs to be performed once.  
> To prevent accidental modifications or duplication, it is recommended to **comment out the code chunk** after it has been executed successfully.


### Load Observed Data

### Configure Simulation

### Prepare your Parameter Sets
Parameter changes in a R notebook is already available thanks to parameter sets as described in [SWATplusR](https://github.com/chrisschuerz/SWATplusR). So here we are using the same trick to chose the water routing algorithm.


### Perform your Fisrt Run

### Plot

### Going further

#### Sensitivity analysis





### Analyze the model output


## Calibration




### Input files
A new feature from `SWATplusHybam` is the ability to handle observed data, in order to use them as limit conditions or to do data assimilation for example. This observed data has to come as a .txt file and has it's type has to be specified in the functions Below.
```r
setup_input_files(project_path, list("hbc.txt;hyd;1", "Qsf_lag.txt;sands;1"))
```
"hbc.txt" is the file with the observations, "hyd" is the type of file (see below) and "1" is the reach where your observed data has been measured.


Only three types are available for now but some might be added later. You can currently provide a water, sand or wash load limit condition file or files for data assimilation (in progress).
```r
q_sim_day <- run_swatplus(project_path = project_path,
                         output = define_output(file = "channel_sd",
                                                 variable = "flo_out",
                                                 unit = 1),
                         start_date = "2013-1-1",
                         end_date = "2018-1-1",
                         years_skip = 2)
                         parameter = par_single)
```


## Contact
Created by William Santini (william.santini@ird.fr)
