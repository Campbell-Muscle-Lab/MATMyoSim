---
title: Time domain 1
has_children: False
parent: Fitting
nav_order: 3
---

## Fitting in time domain 1

The MATLAB code for this demo is in `repo\code\demos\fitting\time_domain_1\demo_fit_time_domain_1.m` is very simple.

````
function demo_fit_time_domain_1
% Function demonstates adusting two parameters to fit a ramp stretch

% Add path to the code
addpath(genpath('..\..\..\..\code'));

% Variables
optimization_job_file_string = 'optimization_job.json';

% Code
opt_structure = loadjson(optimization_job_file_string);

% Call controller
fit_controller(opt_structure.MyoSim_optimization);
````

The first 3 lines of code
+ make sure the MATMyoSim project is available on the current path
+ sets the file defining an [optimization structure](..\..\structures\optimization_structure.html)
+ loads the structure into memory

The last line of code calls `fit_controller.m` which runs the optimization defined in `optimization_job.json`

