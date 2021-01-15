function demo_fit_two_by_two_curves_tension_pCa
% Function demonstrates fitting a simple tension-pCa curve

% Variables
optimization_file_string = 'sim_input/optimization_curve_1_and_2.json';

% Code

% Make sure the path allows us to find the right files
addpath(genpath('../../../../code'));

% Load optimization job
opt_json = loadjson(optimization_file_string);
opt_structure = opt_json.MyoSim_optimization;

% Start the optimization
fit_controller(opt_structure, ...
    'single_run', 0);