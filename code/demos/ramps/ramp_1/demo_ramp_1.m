function demo_ramp_1
% Function illustrates how to run a simulation of a single-half-sarcomere
% with a linear passive elastic component and no cycling cross-bridges

% Variables
protocol_file_string = 'ramp_1_protocol.txt';
model_parameters_json_file_string = 'ramp_1_parameters.json';
options_file_string = 'ramp_1_options.json';
model_output_file_string = '..\..\temp\ramp_1_output.myo';

% Make sure the path allows us to find the right files
addpath(genpath('..\..\..\..\code'));

% Run a simulation
sim_output = simulation_driver( ...
    'simulation_protocol_file_string', protocol_file_string, ...
    'model_json_file_string', model_parameters_json_file_string, ...
    'options_json_file_string', options_file_string, ...
    'output_file_string', model_output_file_string);

% Load it back up and display to show how that can be done
sim = load(model_output_file_string,'-mat')
sim_output = sim.sim_output

figure(2);
clf;
subplot(2,1,1);
plot(sim_output.time_s,sim_output.muscle_force,'b-');
ylabel('Force (N m^{-2})');
subplot(2,1,2);
plot(sim_output.time_s,sim_output.hs_length,'b-');
ylabel('Half-sarcomere length (nm)');
xlabel('Time (s)');