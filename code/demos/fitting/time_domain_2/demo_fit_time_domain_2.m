function demo_fit_time_domain_2
% Function demonstates adusting two parameters to fit a ramp stretch

% Add path to the code
addpath(genpath('..\..\..\..\code'));

% Variables
optimization_job_file_string = 'optimization_job.json';

% Code
opt_structure = loadjson(optimization_job_file_string);

% Call controller
fit_controller(opt_structure.MyoSim_optimization);
