function all_models = update_json_model_file(opt_structure, job_counter, ...
                        p_vector, all_models)
% Function creates a new model file based on opt structure and p vector

% Pull of the filnames we want
original_json_model_file_string = opt_structure.model_template_file_string;
new_json_model_file_string = ...
    opt_structure.job{job_counter}.model_file_string;

% Load original model
model_struct = loadjson(original_json_model_file_string);

% Set parameter data
par_structure = opt_structure.parameter;

% Pull out par_labels
[~,~,par_labels] = extract_p_data_from_opt_structure(opt_structure);

% Get the fieldnames
model_fields = fieldnamesr(model_struct);

% Loop through the parameters
for i = 1 : numel(par_structure)
      
    % Set the parameter value
    par_value = return_parameter_value( ...
        par_structure{i}, p_vector(i));

    % Create the par_string
    par_string = sprintf('parameters.%s', par_structure{i}.name);
   
    % Update model struct
    update_model_struct(par_string, par_value);
    
end

% Update hsl if required
if (isfield(opt_structure, 'initial_delta_hsl'))
    model_struct.MyoSim_model.hs_props.hs_length = ...
        model_struct.MyoSim_model.hs_props.hs_length + ...
            opt_structure.initial_delta_hsl(job_counter);
end

% Update cb number density if required
if (isfield(opt_structure, 'relative_cb_number_density'))
    model_struct.MyoSim_model.hs_props.parameters.cb_number_density = ...
        opt_structure.relative_cb_number_density(job_counter) * ...
            model_struct.MyoSim_model.hs_props.parameters.cb_number_density;
end

% Update intra and extracellular passive proportions if required
if (isfield(opt_structure, 'intracellular_passive_proportion'))
    model_struct.MyoSim_model.hs_props.parameters.intracellular_passive_proportion = ...
        opt_structure.intracellular_passive_proportion(job_counter);
        
    model_struct.MyoSim_model.hs_props.parameters.extracellular_passive_proportion = ...
        (1-opt_structure.intracellular_passive_proportion(job_counter));
end

% Set counter for constrain p values
p_counter = numel(par_structure);

% Check for constraints
if (isfield(opt_structure, 'constraint'))
   
    % Now we search for a job number
    for i = 1 : numel(opt_structure.constraint)
        constrained_jobs(i) = opt_structure.constraint{i}.job_number;
    end
   
    vi = find(constrained_jobs == job_counter);
   
    % Do some checking
    if (numel(vi)>1)
        error('Constrained job duplicate in optimization structure');
    end
   
    if (numel(vi)==1)
        % Handle the constraints for the job
        constraint = opt_structure.constraint{vi};
        
        % Check for parameter modifiers
        if (isfield(constraint, 'parameter_multiplier'))
            for i = 1 : numel(constraint.parameter_multiplier)
                
                % Get the base value
                base_job_number = constraint.parameter_multiplier{i}. ...
                    base_job_number;
                par_name = constraint.parameter_multiplier{i}.name;
                
                base_value = all_models{base_job_number}.MyoSim_model. ...
                    hs_props.parameters.(par_name);

                % Set the par string
                par_string = sprintf('parameters.%s', ...
                    constraint.parameter_multiplier{i}.name);

                % Find the right index for the p_vector
                test_label = ...
                    sprintf('mult_%s',constraint.parameter_multiplier{i}.name);
                p_index = find(strcmp(par_labels, test_label));
                
                multiplier_value = return_parameter_value( ...
                    constraint.parameter_multiplier{i}, ...
                    p_vector(p_index));

                % Update model
                update_model_struct(par_string, ...
                    multiplier_value * base_value);
            end
        end

        if (isfield(constraint, 'parameter_copy'))
            for i = 1 : numel(constraint.parameter_copy)
                % Get the parameter value
                job_copy = constraint.parameter_copy{i}.copy_job_number;
                par_value = all_models{job_copy}.MyoSim_model.hs_props. ...
                    parameters.(constraint.parameter_copy{i}.name);

                % Set the par string
                par_string = sprintf('parameters.%s', ...
                    constraint.parameter_copy{i}.name);

                % Update model
                update_model_struct(par_string, par_value);
            end
        end
   end
end       

% Save the model for a potential next job
all_models{job_counter} = model_struct;

% Write it out
% Check for directory and make it if required
path_string = fileparts(new_json_model_file_string);
if (~isfolder(path_string))
    mkdir(fullfile(cd, path_string))
end

% Dump struct to json
out_string = savejson('MyoSim_model', model_struct.MyoSim_model);
out_string = strrep(out_string, '\/', '/');

out_file = fopen(new_json_model_file_string, 'w');
fprintf(out_file, '%s', out_string);
fclose(out_file);

    % Nested function
    function update_model_struct(par_string, par_value)
        % Find the model field
        vi = find(cellfun(@(model_fields) ~isempty(model_fields), ...
            strfind(model_fields, par_string)));

        % Check
        if (numel(vi)==0)
            error(sprintf('Parameter %s not found in %s', ...
                par_string, original_json_model_file_string));
        end
        if (numel(vi)>1)
            error(sprintf('Parameter %s found more than once in %s', ...
                par_string, original_json_model_file_string));
        end

        % Set the field
        temp_string = sprintf('model_struct.%s = %g;', ...
            model_fields{vi}, par_value);
        eval(temp_string)
    end
end
   
   
