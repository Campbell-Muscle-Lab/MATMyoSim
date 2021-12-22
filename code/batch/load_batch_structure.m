function batch_struct = load_batch_structure(input_file_string)
% Function creates a batch structure, updating files with relative paths
% as appropriate

% Load file
full_struct = loadjson(input_file_string);
batch_struct = full_struct.MyoSim_batch;

% Get parent directory for input file
parent_path = fileparts(GetFullPath(input_file_string))

% Update
for i = 1 : numel(batch_struct.job)
    j = batch_struct.job{i};
    if (isfield(j, 'relative_to'))
        if (strcmp(j.relative_to, 'this_file'))
            j.model_file_string = ...
                fullfile(parent_path, j.model_file_string);
            j.protocol_file_string = ...
                fullfile(parent_path, j.protocol_file_string);
            j.options_file_string = ...
                fullfile(parent_path, j.options_file_string);
            j.results_file_string = ...
                fullfile(parent_path, j.results_file_string);
        end
        batch_struct.job{i} = j;
    end
end