function generate_protocols
% Generates protocols for this demo

% Variables
no_of_curves = 4;
pCa_values = [8.0 6.0 5.8 5.6 5.4 5.2 4.8];

raw_data_file_string = 'raw_data/raw_data.xlsx';
target_data_file_string = 'target_data/target_data.xlsx';

% Code

% Make sure the path allows us to find the right files
addpath(genpath('../../../../code'));

% Load target data
raw_data = readtable(raw_data_file_string);

% Keep track of experimental data to make target
vi_out = [];

for curve_counter = 1 : no_of_curves
    for i=1:numel(pCa_values)
        
        % Keep track of the raw data
        vi = find((raw_data.curve == curve_counter) & ...
                (raw_data.pCa == pCa_values(i)));
        vi_out = [vi_out ; vi];

        % Create the file string for the protocol
        file_string = sprintf('sim_input/%.0f/%.0f/protocol_%.0f.txt', ...
            curve_counter, [10 10]*pCa_values(i))

        % Make the directory if required
        path_string = fileparts(fullfile(cd, file_string));
        if (~isdir(path_string))
            [s,msg] = mkdir(path_string);
        end

        generate_isometric_pCa_protocol( ...
            'time_step', 0.002, ...
            'no_of_points', 500, ...
            't_start_s', 0.1, ...
            't_stop_s', inf, ...
            'pre_pCa', 8.0, ...
            'during_pCa', pCa_values(i), ...
            'output_file_string', file_string);
   end
end

% Save the target data
target_data = raw_data(vi_out, :);
writetable(target_data, target_data_file_string);