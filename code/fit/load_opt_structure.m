function opt_struct = load_opt_structure(input_file_string)
% Function returns an opt_structure, updating files with relative paths
% as appropriate

% Load file
full_struct = loadjson(input_file_string);
opt_struct = full_struct.MyoSim_optimization;

% Get parent directory for input file
parent_path = fileparts(GetFullPath(input_file_string));

% Update files
file_fields = fieldnames(opt_struct.files)
for i = 1 : numel(file_fields)
    if (isfield(opt_struct.files, 'relative_to'))
        if (~strcmp(file_fields{i}, 'relative_to'))
            opt_struct.files.(file_fields{i}) = ...
                fullfile(parent_path, opt_struct.files.(file_fields{i}));
        end
    end
end
