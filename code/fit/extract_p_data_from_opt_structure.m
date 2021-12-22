function [p_vector, par_values, par_labels] = ...
    exract_p_data_from_opt_structure(varargin)
% Pulls p data from opt_structure

opt_struct = varargin{1};

% Set p_vector
if (numel(varargin)==2)
    p_vector = varargin{2};
else
    for i=1:numel(opt_struct.parameter)
        p_vector(i) = opt_struct.parameter{i}.p_value;
    end
    if (isfield(opt_struct, 'constraint'))
        for i = 1 : numel(opt_struct.constraint)
            c = opt_struct.constraint{i};
            if (isfield(c, 'parameter_multiplier'))
                for j = 1 : numel(c.parameter_multiplier)
                    p_vector = [p_vector c.parameter_multiplier{j}.p_value];
                end
            end
        end
    end
end

% Now pull out par_values and par_labels for the defined parameters
for i = 1 : numel(opt_struct.parameter)
    par_values(i) = return_parameter_value( ...
        opt_struct.parameter{i}, p_vector(i));
    par_labels{i} = opt_struct.parameter{i}.name;
end
p_vector = p_vector

% Now search through constraints
par_counter = numel(par_labels);
if (isfield(opt_struct, 'constraint'))
    for i = 1 : numel(opt_struct.constraint)
        c = opt_struct.constraint{i};
        if (isfield(c, 'parameter_multiplier'))
            for j = 1 : numel(c.parameter_multiplier)
                par_counter = par_counter + 1;
                par_values(par_counter) = return_parameter_value( ...
                    c.parameter_multiplier{j}, p_vector(par_counter));
                par_labels{par_counter} = ...
                    sprintf('mult_%s',c.parameter_multiplier{j}.name);
            end
        end
    end
end
