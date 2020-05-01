function fit_controller(opt_structure)

% Pull out initial p_vector
p_vector = [];
for i=1:numel(opt_structure.parameter)
    p_vector(i) = opt_structure.parameter{i}.p_value;
end

% Set up for optimization
best_e = inf;
all_e_values = [];
y_best = [];

% Run the optimization
[best_p, ~, status] = fminsearch(@run_trial, p_vector, ...
    [], opt_structure);

    function e = run_trial(p_vector, opt_structure)
        
        p_vector = p_vector

        [e, trial_e, sim_output, y_attempt, target_data] = ...
            fit_worker(p_vector,opt_structure);

        all_e_values = [all_e_values e];

        % First time
        if (numel(all_e_values) == 1)
            best_e = e;
            y_best = y_attempt;
        end
        
        if (e < best_e)
            best_e = e;
            y_best = y_attempt
            copyfile(opt_structure.model_working_file_string, ...
                opt_structure.best_model_file_string);
        end
        
        % Update figures
        if (opt_structure.figure_simulation_progress)
            draw_figure_simulation_progress(opt_structure, all_e_values);
        end
        
        if (opt_structure.figure_current_fit)
            draw_figure_current_fit(opt_structure, sim_output, ...
                y_attempt, target_data, ...
                trial_e, y_best, p_vector);
        end
    end
end

