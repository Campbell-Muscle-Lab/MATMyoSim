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

+ `model_template_file_string` - the 'base' [model](../model/model.html) for the simulations. The values of the parameters in this file will be adjusted during the fitting procedures in an effort to match the simulations to target data.

+ `fit_mode` - one of
  + `fit_in_time_domain`
    + In this mode, each `job` in the optimization task must include a `target_file_string` containing the data the simulation is trying to match. See [fitting_time_domain_1](../../demos/fitting/time_domain_1/fitting_time_domain_1.html) for an example.
  + `fit_pCa_curve`
    + In this mode, there is a single target file (in a format that can be obtained by MATLAB readtable(), for example, an Excel file) which contains the data for the pCa curve(s) which will be generated from the sequence of jobs. See [fitting_pCa_single_curve](../../demos/fitting/pCa_single_curve/pCa_single_curve.html) for an example.
  + `fit_variable` - a string defining the column name for the target data.

+ `best_model_folder` - a folder containing files related to the best fitting model attained to date.
+ `best_opt_file_string` - a version of the optimization file with the best-fitting p-values attained to date. 

+ `figure_current_fit` - a figure number that shows the current model, the best-fit attained to date, and some information about the current parameter values. Set to 0 to avoid showing the figure.

+ `figure_optimization_progress` - a figure number that shows the fitting metric for successive iterations. The lower the value of the metric, the better the fit. Set to 0 to avoid showing the figure.


## Job

The optimization file defines each `job` in the task using the [batch structure format](../batch/batch.html)

Each job requires:
+ a [model file](../model/model.html)
+ a [protocol file](../protocol/protocol.html)
+ an [options file](../options/options.html)
+ a [results file](../results/results.html)

When fitting in the time domain, each `job` also requires a target file containing the data the job is trying to match.

## Parameter

The parameter section defines which model parameters can be adjusted during the fitting procedures. Here is an example.

````
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
]
````

Here, the fitting procedures can adjust 2 parameters: `passive_hsl_slack` and `passive_k_linear`. In addition to its name, each parameter has 4 fields:
+ min_value - the minimum parameter value allowed during the fitting
+ max_value - the maximum parameter value alowed during the fitting
+ p_value - a floating point number
+ p_mode - one of 'lin' or 'log'

p_values map the parameter between the minimum and maximum values allowed during the simulation using a saw-tooth profile. This is a good way of performing a bound optimization and the 'wrap-around' feature of the saw-tooth profile reduces the probability of the optimization getting stuck in a local minima. Here is the relevant function.

````
function parameter_value = return_parameter_value(par_structure, p_value)
% Function returns parameter value for a given p_value

temp_value = mod(p_value,2);
if (temp_value<1)
    parameter_value = par_structure.min_value + ...
        temp_value * ...
            (par_structure.max_value - par_structure.min_value);
else
    parameter_value = par_structure.max_value - ...
        (temp_value-1) * ...
            (par_structure.max_value - par_structure.min_value);
end
if (strcmp(par_structure.p_mode,'log'))
    parameter_value = 10^parameter_value;
end
````

Accordingly, p_values of -2, 0, 2 etc. map to `min_value`. p_values of -3, -1, 1, 3 etc. map to `max_value`.

If `p_mode` is log:
+ -2, 0, 2, etc map to 10^min_value
+ -3, -1, 1, 3, etc. map to 10^max_value

The log mode makes it easier to search over a larger range of values.

## Initial_delta_hsl

## Constraints
