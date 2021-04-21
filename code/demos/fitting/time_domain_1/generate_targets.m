function generate_targets
% Function generates target forces for defined protocols

% Variables
n_target_points = 300;
prot_file_string = 'sim_input/protocol.txt';
model_json_file_string = 'sim_input/target_model.json';
options_json_file_string = 'sim_input/sim_options.json';
sim_file_string = '../../demo/target.myo';
target_file_string = 'target/target_force.txt';

% Make sure the path allows us to find the right files
addpath(genpath('..\..\..\..\code'));

% Run simulation
sim_output = simulation_driver( ...
    'simulation_protocol_file_string', prot_file_string, ...
    'model_json_file_string', model_json_file_string, ...
    'options_json_file_string', options_json_file_string, ...
    'output_file_string', sim_file_string);

% Load it back up and pull of last n points of force as a target
sim = load(sim_file_string, '-mat');
sim_output = sim.sim_output;

target_force = sim_output.muscle_force((end-n_target_points+1):end);
dlmwrite(target_file_string, target_force);

    
    
    
    


