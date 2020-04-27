function e = fit_worker(p_vector,worker_structure)

ws = worker_structure

% Update the working model file
update_json_model_file( ...
    worker_structure.model_template_file_string, ...
    worker_structure.model_working_file_string, ...
    worker_structure.optimization_structure, ...
    p_vector);

% Get the options
json_struct = loadjson(worker_structure.simulation_options_file_string);
obj.myosim_options = json_struct.MyoSim_options

% Cycle through the trials
if (obj.myosim_options.run_in_parallel)
    parfor i=1:numel(worker_structure.protocol_file_strings)

        % Evaluate the trial
        [trial_e(i), sim_output{i}, target_data{i}] = ...
            evaluate_single_trial( ...
                'model_json_file_string',worker_structure.model_working_file_string, ...
                'simulation_protocol_file_string',worker_structure.protocol_file_strings{i}, ...
                'options_file_string',worker_structure.simulation_options_file_string, ...
                'fit_mode',worker_structure.fit_mode, ...
                'target_data',worker_structure.target_data(:,i))
    end
else
    for i=1:numel(worker_structure.protocol_file_strings)

        % Evaluate the trial
        [trial_e(i), sim_output{i}, target_data{i}] = ...
            evaluate_single_trial( ...
                'model_json_file_string',worker_structure.model_working_file_string, ...
                'simulation_protocol_file_string',worker_structure.protocol_file_strings{i}, ...
                'options_file_string',worker_structure.simulation_options_file_string, ...
                'fit_mode',worker_structure.fit_mode, ...
                'target_data',worker_structure.target_data(:,i))
    end
end

% Return e
e = mean(trial_e);

if (worker_structure.figure_current_fit)
    figure(worker_structure.figure_current_fit)
    clf;
    if (strcmp(worker_structure.fit_mode,'time_fit'))
        subplot(2,1,1);
        hold on;
        tn = numel(target_data{1});
        for i=1:numel(worker_structure.protocol_file_strings)
            plot(sim_output{i}.time_s(end-tn+1:end),target_data{i},'k-');
            switch (worker_structure.fit_variable)
                case 'muscle_force'
                    y_attempt = sim_output{i}.muscle_force;
                otherwise
            end
            plot(sim_output{i}.time_s,y_attempt,'b-');
        end
    end
    subplot(2,1,2);
    plot(trial_e,'bo');
end
  