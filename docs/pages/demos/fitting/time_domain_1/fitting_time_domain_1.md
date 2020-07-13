---
title: Time domain 1
parent: Fitting
grand_parent: Demos
nav_order: 1
---

# Fitting in time domain 1

This demo shows how to fit a simulation of a single twitch to a trace showing force against time.

## Instructions

+ Launch MATLAB
+ Change the MATLAB working directory to `<repo>/code/demos/fitting/time_domain_1/demo_fit_time_domain_1.m`
+ Open `demo_fit_time_domain_1.m`
+ Press <kbd>F5</kbd> to run the demo

## Code

The MATLAB code is very simple.

````
function demo_fit_time_domain_1
% Function demonstates adusting two parameters to fit a ramp stretch

% Add path to the code
addpath(genpath('..\..\..\..\code'));

% Variables
optimization_job_file_string = 'optimization.json';

% Code
opt_structure = loadjson(optimization_job_file_string);

% Call controller
fit_controller(opt_structure.MyoSim_optimization);
````

## What the code does

The first 3 lines of (non-commented) code
+ make sure the MATMyoSim project is available on the current path
+ sets the file which definines an [optimization structure](..\..\structures\optimization_structure.html)
  + all of the information about the optimization task is contained in this file
+ loads the structure into memory

The last line of code calls `fit_controller.m` which runs the optimization defined in `optimization.json`

## First iteration

The first iteration will produce 4 figures

Fig 1 shows the simulation.

![simulation](simulation.png)

Fig 2 shows the rates for the simulation.

![rates](rates.png)

Fig 3 summarizes how the simulation matches the target data defined in the optimization structure.
+ top panel, compares the current simulation to the target data
+ middle panel, shows the relative errors for the different trials (although there is only 1 in this case)
+ bottom panel, shows the parameter values

![summary](summary_initial.png)

Fig 4 shows a single circle. This is the value of the error function which quantifies the difference between the current simulation and the target data. The goal of the fitting procedure is to lower this value in successive iterations.

![progress](progress_initial.png)


## Iterations

The code will continue to run simulations adjusting the values of the two parameters, k_2 and k_on, in an attempt to get the simulated force values to match the target data. As the iterations progress, the value of the error function will trend down, indicating that the fit is getting better.

## Final fit

The final summary and progress figures are shown below. Note that your progress figure might look slightly different because the optimization is based on randomly generated numbers.

![summary](summary_final.png)

![progress](progress_final.png)

