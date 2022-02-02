function demo_simple_twitch
% Function illustrates how to run a simulation of a single-half-sarcomere
% held isometric and activated by a transient pulse of Ca2+

% Variables
protocol_file_string = 'protocol.txt';
model_parameters_json_file_string = 'model.json';
options_file_string = 'options.json';
model_output_file_string = '../../temp/simple_twitch_output.myo';

% Make sure the path allows us to find the right files
addpath(genpath('../../../../code'));

% Run a simulation
sim_output = simulation_driver( ...
    'simulation_protocol_file_string', protocol_file_string, ...
    'model_json_file_string', model_parameters_json_file_string, ...
    'options_json_file_string', options_file_string, ...
    'output_file_string', model_output_file_string);

% Load it back up and display to show how that can be done
sim = load(model_output_file_string,'-mat')
sim_output = sim.sim_output

figure(3);
clf;
subplot(2,1,1);
plot(sim_output.time_s,sim_output.muscle_force,'b-');
ylabel('Force (N m^{-2})');
subplot(2,1,2);
plot(sim_output.time_s,sim_output.hs_length,'b-');
ylabel('Half-sarcomere length (nm)');

% Save the figures as images to the documentation
doc_image_folder = ...
    '../../../../docs/pages/demos/getting_started/simple_twitch';

figure(1);
figure_export('output_file_string', ...
    sprintf('%s/fig_1_simulation_output', doc_image_folder), ...
    'output_type', 'png');

figure(2);
figure_export('output_file_string', ...
    sprintf('%s/fig_2_rates', doc_image_folder), ...
    'output_type', 'png');

figure(3);
figure_export('output_file_string', ...
    sprintf('%s/fig_3_replotted', doc_image_folder), ...
    'output_type', 'png');