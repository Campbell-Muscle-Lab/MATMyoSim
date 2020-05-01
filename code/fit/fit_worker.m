function [e, trial_e, sim_output, y_attempt, target_data] = ...
    fit_worker(p_vector,opt_structure)

% Update the working model file
update_json_model_file( ...
    opt_structure.model_template_file_string, ...
    opt_structure.model_working_file_string, ...
    opt_structure.parameter, ...
    p_vector);

% Get the options
json_struct = loadjson(opt_structure.simulation_options_file_string);
obj.myosim_options = json_struct.MyoSim_options;

% Cycle through the trials

job_structure = opt_structure.job;

if (opt_structure.run_simulations_in_parallel)
    
    switch opt_structure.fit_mode
        case 'fit_in_time_domain'

            parfor i=1:numel(job_structure)
                
                % Pull off the target data
                target_data{i} = dlmread(job_structure{i}.target_file_string);

                % Evaluate the trial
                [trial_e(i), sim_output{i}, y_attempt{i}, target_data{i}] = ...
                    evaluate_single_trial( ...
                        'model_json_file_string',opt_structure.model_working_file_string, ...
                        'simulation_protocol_file_string',job_structure{i}.protocol_file_string, ...
                        'options_file_string',opt_structure.simulation_options_file_string, ...
                        'fit_mode',opt_structure.fit_mode, ...
                        'fit_variable',opt_structure.fit_variable, ...
                        'target_data',target_data{i});
            end
            
        otherwise
            error('Fit mode not yet implemented');
    end
        
end

% Calculate e
e = mean(trial_e);

  