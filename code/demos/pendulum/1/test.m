function test

model_file = 'model.json'
protocol_file = 'protocol_2.txt'
options_file = 'options.json'
pendulum_file = 'pendulum.json'

% Make sure the path allows us to find the right files
addpath(genpath('../../../../code'));

sim = simulation(model_file)
% sim.implement_protocol(protocol_file, options_file)
% 
% m = muscle(model_file)

sim.implement_pendulum_protocol(protocol_file, ...
    pendulum_file, options_file, [0.1 0]);