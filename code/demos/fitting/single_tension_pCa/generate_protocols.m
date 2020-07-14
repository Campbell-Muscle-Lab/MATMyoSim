function generate_protocols
% Generates protocols for this demo

% Variables
pCa_values = [6.5 5.6 5.4 5.2 4.8];

% Code
for i=1:numel(pCa_values)
    
    % Create the file string for the protocol
    file_string = sprintf('sim_input/%.0f/protocol_%.0f.txt', ...
        [10 10]*pCa_values(i))
    
    % Make the directory if required
    path_string = fileparts(fullfile(cd, file_string));
    if (~isdir(path_string))
        [s,msg] = mkdir(path_string)
    end
       
    generate_isometric_pCa_protocol( ...
        'time_step', 0.002, ...
        'no_of_points', 1000, ...
        't_start_s', 0.1, ...
        't_stop_s', inf, ...
        'pre_pCa', 8.0, ...
        'during_pCa', pCa_values(i), ...
        'output_file_string', file_string);
end
