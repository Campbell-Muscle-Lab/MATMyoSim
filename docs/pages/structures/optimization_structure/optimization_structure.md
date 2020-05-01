---
title: Optimization structure
has_children: false
parent: Structures
nav_order: 3
---

## Optimization structure

Optimization structures are stored using the JSON format. Here is an example.

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
        "figure_simulation_progress": 3, 
        
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



In this context, fitting means adjusting model parameters to obtain the best possible fit between the simulations and experimental data.

This can be done by fitting:
+ in the time domain
  + matching simulations and experimental traces plotted against time
+ pCa curves
  + matching simulations and experimental data plotted as a function of activating Ca<sup>concentration</sup>
+ in the frequency domain
  + matching Nyquist plots showing elastic and viscous moduli as a function of frequency

Fitting in MATMyoSim is performed using an [Optimization structure](optimization_structure.html)









