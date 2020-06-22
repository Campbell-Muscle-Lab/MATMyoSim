---
title: Optimization structure
has_children: false
parent: Structures
nav_order: 4
---

# Optimization structure

Optimization structures are stored using the JSON format. Each file contains:

+ header information
+ job data
  + defined as for [batch stuctures](../batch/batch.html)
+ parameter data
+ (optional) initial_delta_hsl
+ (optional) constraints

## Header information

## Job data

## Parameter data

## Initial_delta_hsl

## Constraints

````
{
	"MyoSim_optimization":
	{
        "model_template_file_string": "model_parameters.json",
        "model_working_file_string": "..\\..\\temp\\model_worker.json",
        "simulation_options_file_string": "sim_options.json",
        "best_model_file_string": "..\\..\\temp\\best_model.json",
        "fit_mode": "fit_in_time_domain",
        "fit_variable": "muscle_force",

        "figure_current_fit": 2,
        "figure_optimization_progress": 3, 
        
        "job":
        [
            {
                "protocol_file_string": "protocol_1.txt",
                "results_file_string": "..\\..\\temp\\temp_1.myo",
                "target_file_string": "target_force_1.txt"
            },
            {
                "protocol_file_string": "protocol_2.txt",
                "results_file_string": "..\\..\\temp\\temp_2.myo",
                "target_file_string": "target_force_2.txt"
            },
            {
                "protocol_file_string": "protocol_3.txt",
                "results_file_string": "..\\..\\temp\\temp_3.myo",
                "target_file_string": "target_force_3.txt"
            }
        ],

        "parameter":
        [
            {
                "name": "passive_hsl_slack",
                "min_value": 1000,
                "max_value": 1500,
                "p_value": 0.1,
                "p_mode": "lin"
            },
            {
                "name": "passive_k_linear",
                "min_value": 1,
                "max_value": 3,
                "p_value": 0.75,
                "p_mode": "log"
            },
            {
                "name": "k_3",
                "min_value": 5,
                "max_value": 30,
                "p_value": 0.5,
                "p_mode": "lin"
            },
            {
                "name": "k_4_0",
                "min_value": 0,
                "max_value": 2,
                "p_value": 0.6,
                "p_mode": "log"
            }
        ]
    }
}
````
#### model_template_file_string

This is the base version of the MATMyoSim model file. One or more of the parameters in this file will be modified in an attempt to fit the simulations to the target data. The template file itself is never changed.

#### model_working_file_string

This is the file that defines the simulations. It changes each time the parameters are adjusted.

#### simulation_options_file_string

This is the [simulation_options_file](..\simulation_options\simulation_options.html) that will be used to run all of the simulations. This file never changes.

#### best_model_file_string

This is the model file for the best-fit attained to date. It is updated each time the simulation gets closer to the experimental data. When the optimization finishes, it describes the best model that was found.

#### fit_mode

One of:
+ fit_in_time_domain
+ fit_pCa_curves
+ fit_in_frequency_domain


### figure_current_fit

A figure number that shows the current model, the best-fit attained to date, and some information about the current parameter values. Set to 0 to avoid showing the figure.



Options depend on the fit_mode

+ fit_in_time_domain
  + muscle_force

        "figure_current_fit": 2,
        "figure_simulation_progress": 3, 

