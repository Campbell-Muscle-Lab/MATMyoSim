function [p_vector, par_values, par_labels] = ...
    exract_p_data_from_opt_structure(varargin)
% Pulls p data from opt_structure

opt_structure = varargin{1};

% Set p_vector
if (numel(varargin)==2)
    p_vector = varargin{2};
else
    for i=1:numel(opt_structure.parameter)
        p_vector(i) = opt_structure.parameter{i}.p_value;
    end
    if (isfield(opt_structure, 'constraint'))
        for i = 1 : numel(opt_structure.constraint)
            c = opt_structure.constraint{i};
            if (isfield(c, 'parameter_multiplier'))
                for j = 1 : numel(c.parameter_multiplier)
                    p_vector = [p_vector c.parameter_multiplier{j}.p_value];
                end
            end
        end
    end
end

% Now pull out par_values and par_labels for the defined parameters
for i = 1 : numel(opt_structure.parameter)
    par_values(i) = return_parameter_value( ...
        opt_structure.parameter{i}, p_vector(i));
    par_labels{i} = opt_structure.parameter{i}.name;
end

% Now search through constraints
par_counter = numel(par_labels);
if (isfield(opt_structure, 'constraint'))
    for i = 1 : numel(opt_structure.constraint)
        c = opt_structure.constraint{i};
        if (isfield(c, 'parameter_multiplier'))
            for j = 1 : numel(c.parameter_multiplier)
                par_counter = par_counter + 1;
%                 
%                 cc = c.parameter_multiplier{j}
%                 pp = p_vector(par_counter)
%                 yy = return_parameter_value( ...
%                     c.parameter_multiplier{j}, p_vector(par_counter))
% 
%                 
                par_values(par_counter) = return_parameter_value( ...
                    c.parameter_multiplier{j}, p_vector(par_counter));
                par_labels{par_counter} = ...
                    sprintf('mult_%s',c.parameter_multiplier{j}.name);
            end
        end
    end
end
