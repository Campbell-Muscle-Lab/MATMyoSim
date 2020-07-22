function [e, trial_e, sim_output, y_attempt, target_data] = ...
    fit_worker(p_vector,opt_structure)

% Get the number of jobs in the optimization task
no_of_jobs = numel(opt_structure.job);

% Cycle through the jobs creating the model file for each one
% Store created models in all_models to allow for intra-job referencing
all_models = [];
for job_counter = 1 : no_of_jobs
    all_models = update_json_model_file( ...
                        opt_structure, job_counter, p_vector, ...
                        all_models);
end

% Run batch
run_batch(opt_structure);

switch opt_structure.fit_mode
    case 'fit_pCa_curve'
        
        % Pull off target data
        target = readtable(fullfile(cd, opt_structure.target_file_string));
        
        % Treat each curve by itself
        unique_curves = unique(target.curve);
        for i=1:numel(unique_curves)
            vi = find(target.curve == unique_curves(i));
            target_data{i} = target.(opt_structure.target_field)(vi);
            
            y_attempt{i} = [];
            for j=1:numel(vi)
                sim = load( fullfile(cd, ...
                                opt_structure.job{vi(j)}.results_file_string), ...
                            '-mat');
                sim = sim.sim_output;
                y_attempt{i}(j) = sim.(opt_structure.fit_variable)(end);
                
                % Store store complete simulation for potential use
                sim_output{i}.sim(j) = sim;
            end
            
            % Calculate error
            rel_e = (y_attempt{i} - target_data{i}') ./ ...
                        max(abs(target_data{i}));
            trial_e(i) = sum(rel_e.^2);
            
        end
        
    case 'fit_in_time_domain'
        if (numel(opt_structure.job)>1)
            % Multiple jobs - run in parallel
            parfor i=1:numel(opt_structure.job)
                % Pull off the target data
                target_data{i} = dlmread(fullfile(cd, ...
                        opt_structure.job{i}.target_file_string));

                % Evaluate the trial
                [trial_e(i), sim_output{i}, y_attempt{i}, target_data{i}] = ...
                    evaluate_single_trial( ...
                        'model_json_file_string', fullfile(cd, ...
                            opt_structure.job{i}.model_file_string), ...
                        'simulation_protocol_file_string', fullfile(cd, ...
                            opt_structure.job{i}.protocol_file_string), ...
                        'options_file_string',opt_structure.job{i}.options_file_string, ...
                        'fit_mode', opt_structure.fit_mode, ...
                        'fit_variable',opt_structure.fit_variable, ...
                        'target_data',target_data{i});
            end
        else
            % There is just a single job
            % Pull off the target data
            target_data{1} = dlmread(opt_structure.job{1}.target_file_string);

            % Evaluate the trial
            [trial_e(1), sim_output{1}, y_attempt{1}, target_data{1}] = ...
                evaluate_single_trial( ...
                    'model_json_file_string', opt_structure.job{1}.model_file_string, ...
                    'simulation_protocol_file_string', opt_structure.job{1}.protocol_file_string, ...
                    'options_file_string', opt_structure.job{1}.options_file_string, ...
                    'fit_mode', opt_structure.fit_mode, ...
                    'fit_variable', opt_structure.fit_variable, ...
                    'target_data', target_data{1});
        end
        
    otherwise
        error('Fit mode not yet implemented');

end

% Calculate e
e = mean(trial_e);

  