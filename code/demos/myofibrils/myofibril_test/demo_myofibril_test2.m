function demo_myofibril_test
% Demo 

% Variables
protocol_file_string = 'sim_input/protocol_45_pulse.txt';
model_file_string = 'sim_input/myo_file2.json'
options_file_string = 'sim_input/sim_options2.json'
output_file_string = '../../test/sim_output/sim_output.myo'

% Make sure the path allows us to find the right files
addpath(genpath('../../../../code'));

% Run a simulation
sim_output = simulation_driver( ...
    'simulation_protocol_file_string', protocol_file_string, ...
    'model_json_file_string', model_file_string, ...
    'options_json_file_string', options_file_string, ...
    'output_file_string', output_file_string);

% Load it back up and display to show how that can be done
sim = load(output_file_string,'-mat')
sim_output = sim.sim_output

figure(3);
clf;
subplot(2,1,1);
plot(sim_output.time_s,sim_output.muscle_force,'b-');
ylabel('Force (N m^{-2})');
subplot(2,1,2);
plot(sim_output.time_s,sim_output.hs_length,'b-');
ylabel('Half-sarcomere length (nm)');
