function generate_targets
% Function generates target forces for defined protocols

% Variables
time_step = 0.001;
n_points = 400;
n_target_points = 300;
prot_file_string = 'protocol.txt';
sim_file_string = 'sim_1.myo';
target_file_string = 'target_force.txt';
model_json_file_string = 'model_parameters.json';
options_json_file_string = 'sim_options.json';

% Make sure the path allows us to find the right files
addpath('..\..\..\generate_protocols','..\..\..\..\code');

% Generate protocol
out.dt = time_step * ones(n_points,1);
out.pCa = 9.0 * ones(n_points,1);
out.dhsl = zeros(n_points,1);
out.dhsl(200:300) = 0.2;
out.Mode = -2 * ones(n_points,1);

writetable(struct2table(out), prot_file_string, 'Delimiter', '\t');

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

    
    
    
    


