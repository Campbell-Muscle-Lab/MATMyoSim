function [optimization_structure, p] = load_optimization_structure(opt_structure_file_string)
% Function loads optimization structure from json file

% Load optimization structure
json_structure = loadjson(opt_structure_file_string);
temp_struct = json_structure.MyoSim_optimization.optimization_structure

% Converts to a cell to deal with only one parameter in the structure
if ~iscell(temp_struct.parameter)
    temp_struct.parameter = {temp_struct.parameter};
end 

% Builds structure
for i=1:numel(temp_struct.parameter)

    optimization_structure(i).name = temp_struct.parameter{i}.name;
    optimization_structure(i).min_value = temp_struct.parameter{i}.min_value;
    optimization_structure(i).max_value = temp_struct.parameter{i}.max_value;
    optimization_structure(i).p_value = temp_struct.parameter{i}.p_value;
    optimization_structure(i).p_mode = temp_struct.parameter{i}.p_mode;
end

% Extract p vector
for i=1:numel(optimization_structure)
    p(i) = optimization_structure(i).p_value;
end
