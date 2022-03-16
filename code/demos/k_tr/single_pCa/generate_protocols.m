function generate_protocols
% Generates protocols for this demo

% Variables
pCa_values = 4.5;
no_of_points = 1000;
time_step = 0.001;
k_tr_start_s = 0.5;
k_tr_step = 200;
k_tr_ramp_s = 0.005;
k_tr_duration_s = 0.02;

% Code
% Make sure the path allows us to find the right files
addpath(genpath('../../../../code'));

% Generate a dhsl
dt = time_step * ones(no_of_points, 1);
t = cumsum(dt);

dhsl = zeros(no_of_points, 1);
n_ramp = k_tr_ramp_s / time_step;
dhsl((t > k_tr_start_s) & (t <= (k_tr_start_s + k_tr_ramp_s))) = ...
    -k_tr_step / n_ramp;
dhsl((t > (k_tr_start_s + k_tr_duration_s)) & ...
        (t <= (k_tr_start_s + k_tr_duration_s + k_tr_ramp_s))) = ...
    k_tr_step / n_ramp;

m = -2 * ones(no_of_points, 1);
m((t > k_tr_start_s) & (t <=(k_tr_start_s + k_tr_duration_s + k_tr_ramp_s))) = -1;



% Code
for i=1:numel(pCa_values)
    
    % Create the file string for the protocol
    file_string = sprintf('sim_input/%.0f/protocol_%.0f.txt', ...
        [10 10]*pCa_values(i));
    
    % Make the directory if required
    path_string = fileparts(fullfile(cd, file_string));
    if (~isdir(path_string))
        mkdir(path_string);
    end
       
    generate_length_control_pCa_protocol( ...
        'time_step', 0.001, ...
        'no_of_points', 1000, ...
        't_start_s', 0.1, ...
        't_stop_s', inf, ...
        'pre_pCa', 9.0, ...
        'dhsl', dhsl, ...
        'during_pCa', pCa_values(i), ...
        'output_file_string', file_string);
end
