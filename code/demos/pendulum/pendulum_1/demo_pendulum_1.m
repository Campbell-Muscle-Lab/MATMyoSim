function demo_pendulum_1

% Variables
model_file = 'sim_input/model.json'
pendulum_file = 'sim_input/pendulum.json'
options_file = 'sim_input/options.json'
output_file = 'sim_output/output.myo'

% Make sure the path allows us to find the right files
addpath(genpath('../../../../code'));

% Create a simulation
sim = simulation(model_file)

% Set up a mini protocol with the number of time-points
% and pCa held at 9
no_of_time_points = 5000;
pCa = 9.0 * ones(no_of_time_points, 1);
dt = 0.001*ones(no_of_time_points,1);

% Implement the protocol
sim.implement_pendulum_protocol( ...
    'pendulum_file_string', pendulum_file, ...
    'options_file_string', options_file, ...
    'dt', dt, ...
    'pCa', pCa);

% Save the output
sim_output = sim.sim_output;

if (~isempty(output_file))
    % Check directory exists
    output_dir = fileparts(output_file);
    if (~isdir(output_dir))
        sprintf('Creating output directory: %s', fullfile(cd,output_dir))
        [status, msg, msgID] = mkdir(output_dir);
    end
    save(output_file,'sim_output');
end

% Convert sim_output to a table - this requires deleting some fields
sim_output = sim.sim_output;
sim_output = rmfield(sim_output, 'myosim_muscle');
sim_output = rmfield(sim_output, 'subplots');
sim_output = rmfield(sim_output, 'no_of_time_points');
sim_output = rmfield(sim_output, 'cb_pops')
sim_output = struct2table(sim_output);

% Draw some of the output fields as a stacked plot
figure(3);
clf
stackedplot(sim_output, ...
    {'pendulum_position', 'muscle_length', 'hs_length', ...
    'hs_force'}, ...
    'XVariable', 'time_s', ...
    'DisplayLabels', { ...
        {'Pendulum','Position','(m)'}, ...
        {'MATMyoSim','muscle','length','(nm)'}, ...
        {'Half-sarcomere','length','(nm)'}, ...
        {'Muscle','stress','(N m^{-2})'}});
        
