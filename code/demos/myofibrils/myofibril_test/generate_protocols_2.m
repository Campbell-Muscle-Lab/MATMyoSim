function generate_protocols
% Generates protocols for this demo

% Variables
pCa_values = 4.5;

file_string = sprintf('sim_input/protocol_%.0f_pulse.txt', ...
        10*pCa_values);

generate_isometric_pCa_protocol( ...
    'time_step', 0.001, ...
    'no_of_points', 1400, ...
    't_start_s', 0.1, ...
    't_stop_s', 1.0, ...
    'pre_pCa', 9.0, ...
    'during_pCa', pCa_values, ...
    'output_file_string', file_string);
