function [e, trial_e, sim_output, y_attempt, target_data] = ...
    fit_worker(p_vector,opt_struct, batch_struct)

% Get the number of jobs in the optimization task
no_of_jobs = numel(batch_struct.job)

% Cycle through the jobs creating the model file for each one
% Store created models in all_models to allow for intra-job referencing
all_models = [];
for job_counter = 1 : no_of_jobs
    all_models = update_json_model_file( ...
                        opt_struct, batch_struct, ...
                        job_counter, p_vector, all_models);
end

% Run batch
run_batch(batch_struct);

% Check for special fit_handler
if (isfield(opt_struct, 'fit_handler'))
    [trial_e, sim_output, y_attempt, target_data] = ...
        opt_struct.fit_handler(opt_struct, batch_struct);
    
else
    % Run one of the standard fits
    switch opt_struct.fit_mode

        case 'fit_pCa_curve'

            % Pull off target data
            target = readtable(opt_struct.files.target_file_string)

            % Treat each curve by itself
            unique_curves = unique(target.curve);
            for i=1:numel(unique_curves)
                vi = find(target.curve == unique_curves(i));
                target_data{i} = target.(opt_struct.target_field)(vi);

                y_attempt{i} = [];
                for j=1:numel(vi)
                    sim = load(batch_struct.job{vi(j)}.results_file_string, ...
                                '-mat');
                    sim = sim.sim_output;
                    y_attempt{i}(j) = sim.(opt_struct.fit_variable)(end);

                    % Store store complete simulation for potential use
                    sim_output{i}.sim(j) = sim;
                end

                % Calculate error
                rel_e = ((y_attempt{i} - target_data{i}') ./ ...
                            max(abs(target_data{i})))^2;
                trial_e(i) = sum(rel_e);

            end

        case 'fit_pCa_curve_params'

            % Pull off target data
            target = readtable(opt_struct.files.target_file_string);

            % Treat each curve by itself
            unique_curves = unique(target.curve);
            for i=1:numel(unique_curves)
                vi = find(target.curve == unique_curves(i));
                target_data{i} = target.(opt_struct.target_field)(vi);

                td = [];
                sd = [];

                y_attempt{i} = [];
                for j=1:numel(vi)
                    sim = load(batch_struct.job{vi(j)}.results_file_string, ...
                                '-mat');
                    sim = sim.sim_output;
                    y_attempt{i}(j) = sim.(opt_struct.fit_variable)(end);

                    % Store data for curve fit
                    td.pCa(j) = -log10(sim.Ca(end));
                    td.y(j) = target_data{i}(j);
                    td.y_error(j) = 0;

                    sd.pCa(j) = td.pCa(j);
                    sd.y(j) = y_attempt{i}(j);
                    sd.y_error(j) = 0;

                    % Store store complete simulation for potential use
                    sim_output{i}.sim(j) = sim;
                end

                [td.pCa50,td.n_H, td.min_value, td.amp, ~, ...
                    td.x_fit, td.y_fit] = fit_Hill_curve(td.pCa, td.y);

                [sd.pCa50,sd.n_H, sd.min_value, sd.amp, ~, ...
                    sd.x_fit, sd.y_fit] = fit_Hill_curve(sd.pCa, sd.y);

                % Calculate error
                field_strings = {'pCa50', 'n_H', 'min_value', 'max_value'};
                for j = 1 : 4

                    switch field_strings{j}
                        case 'pCa50'
                            sim_y = sd.pCa50;
                            tar_y = td.pCa50;
                            w = 40;
                            d = tar_y;
                        case 'n_H'
                            sim_y = sd.n_H;
                            tar_y = td.n_H;
                            w = 0.5;
                            d = tar_y;
                        case 'min_value'
                            sim_y = sd.min_value;
                            tar_y = td.min_value;
                            w = 1;
                            d = max(td.y);
                        case 'max_value'
                            sim_y = sd.min_value + sd.amp;
                            tar_y = td.min_value + td.amp;
                            w = 1;
                            d = max(td.y);
                    end

                    if (tar_y == 0)
                        error('Normalizing error in fit_worker');
                    end

                    rel_e(j) = (w * (sim_y - tar_y) / d)^2;
                end

                trial_e(i) = sum(rel_e);

                sim_output{i}.rel_e = rel_e
            end

        case 'fit_fv_curve'
            % Pull off target data
            target = readtable(opt_struct.files.target_file_string);

            % Treat each curve by itself
            unique_curves = unique(target.curve);
            for i = 1 : numel(unique_curves)
                vi = find(target.curve == unique_curves(i));
                target_f{i} = target.force(vi);
                target_v{i} = target.velocity(vi);

                sim_f{i} = [];
                sim_v{i} = [];

                y_attempt{i} = [];
                target_data{i} = [];

                for j = 1 : numel(vi)
                    % Load up the simulation
                    sim = load(batch_struct.job{vi(j)}.results_file_string, ...
                            '-mat');
                    sim = sim.sim_output;

                    % Deduce shortening velocity
                    ti = find( ...
                            (sim.time_s > opt_struct.fit_time_s(1)) & ...
                            (sim.time_s <= opt_struct.fit_time_s(end)));

                    p = polyfit(sim.time_s(ti), sim.hs_length(ti), 1);
                    sim_v{i}(j) = -p(1) / sim.hs_length(1);
                    sim_f{i}(j) = mean(sim.hs_force(ti));
                    sim_pow{i}(j) = sim_v{i}(j) * sim_f{i}(j);

                    % Store for output
                    y_attempt{i} = [y_attempt{i} ; sim_f{i}(j) sim_v{i}(j)];
                    target_data{i} = [target_data{i} ; target_f{i} target_v{i}];
                    sim_output{i}.sim(j) = sim;
                end

                % Normalize to max force and velocity
                rel_target_f{i} = target_f{i} ./ max(target_f{i});
                rel_target_v{i} = target_v{i} ./ max(target_v{i});

                rel_sim_f{i} = sim_f{i} ./ max(target_f{i});
                rel_sim_v{i} = sim_v{i} ./ max(target_v{i});

                % Add in k_act
                k_tr = [35 26];
                ki = find((sim.time_s > 0.1) & (sim.time_s < 0.3));
                [~,~,sim_rate(i),~,y_fit] = fit_single_exponential( ...
                    sim.time_s(ki), sim.hs_force(ki));

                % Calculate error
                trial_e(i) = sum((rel_sim_f{i} - rel_target_f{i}').^2) + ...
                    sum((rel_sim_v{i} - rel_target_v{i}').^2) + ...
                    ((sim_rate(i) - k_tr(i))/k_tr(i))^2;
            end             

            sim_rate = sim_rate




        case 'fit_fv_curve2'
            % Pull off target data
            target = readtable(opt_struct.files.target_file_string);

            % Treat each curve by itself
            unique_curves = unique(target.curve);
            for i = 1 : numel(unique_curves)
                vi = find(target.curve == unique_curves(i));
                target_f{i} = target.force(vi);
                target_v{i} = target.velocity(vi);

                sim_f{i} = [];
                sim_v{i} = [];

                y_attempt{i} = [];
                target_data{i} = [];

                for j = 1 : numel(vi)
                    % Load up the simulation
                    sim = load(batch_struct.job{vi(j)}.results_file_string, ...
                            '-mat');
                    sim = sim.sim_output;

                    % Deduce shortening velocity
                    ti = find( ...
                            (sim.time_s > opt_struct.fit_time_s(1)) & ...
                            (sim.time_s <= opt_struct.fit_time_s(end)));

                    p = polyfit(sim.time_s(ti), sim.hs_length(ti), 1);
                    sim_v{i}(j) = -p(1) / sim.hs_length(1);

                    if (sim_v{i}(j)>0)
                        ti2 = find(sim.hs_length > 1050, 1, 'last');
                    else
                        ti2 = numel(sim.hs_length);
                    end
                    sim_f{i}(j) = sim.hs_force(ti2);
                    sim_pow{i}(j) = sim_v{i}(j) * sim_f{i}(j);

                    % Store for output
                    y_attempt{i} = [y_attempt{i} ; sim_f{i}(j) sim_v{i}(j)];
                    target_data{i} = [target_data{i} ; target_f{i} target_v{i}];
                    sim_output{i}.sim(j) = sim;
                end

                % Normalize to max force and velocity
                rel_target_f{i} = target_f{i} ./ max(target_f{i});
                rel_target_v{i} = target_v{i} ./ max(target_v{i});

                rel_sim_f{i} = sim_f{i} ./ max(target_f{i});
                rel_sim_v{i} = sim_v{i} ./ max(target_v{i});

                % Calculate error
                trial_e(i) = sum((rel_sim_f{i} - rel_target_f{i}').^2) + ...
                    sum((rel_sim_v{i} - rel_target_v{i}').^2)
            end        


        case 'fit_in_time_domain'
            if (numel(batch_struct.job)>1)
                % Multiple jobs - run in parallel
                parfor i=1:numel(batch_struct.job)
                    % Pull off the target data
                    target_data{i} = dlmread(fullfile(cd, ...
                            batch_struct.job{i}.target_file_string));

                    % Evaluate the trial
                    [trial_e(i), sim_output{i}, y_attempt{i}, target_data{i}] = ...
                        evaluate_single_trial( ...
                            'model_json_file_string', batch_struct.job{i}.model_file_string, ...
                            'simulation_protocol_file_string', batch_struct.job{i}.protocol_file_string, ...
                            'options_file_string',batch_struct.job{i}.options_file_string, ...
                            'fit_mode', opt_struct.fit_mode, ...
                            'fit_variable',opt_struct.fit_variable, ...
                            'target_data',target_data{i});
                end
            else
                % There is just a single job
                % Pull off the target data
                target_data{1} = dlmread(batch_struct.job{1}.target_file_string);

                % Evaluate the trial
                [trial_e(1), sim_output{1}, y_attempt{1}, target_data{1}] = ...
                    evaluate_single_trial( ...
                        'model_json_file_string', batch_struct.job{1}.model_file_string, ...
                        'simulation_protocol_file_string', batch_struct.job{1}.protocol_file_string, ...
                        'options_file_string', batch_struct.job{1}.options_file_string, ...
                        'fit_mode', opt_struct.fit_mode, ...
                        'fit_variable', opt_struct.fit_variable, ...
                        'target_data', target_data{1});
            end

        otherwise
            error('Fit mode not yet implemented');

    end
end

% Calculate e
e = mean(trial_e);

  