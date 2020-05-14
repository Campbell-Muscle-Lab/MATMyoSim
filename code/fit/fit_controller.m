function fit_controller(opt_structure, varargin)

p = inputParser;
addRequired(p, 'opt_structure');
addOptional(p, 'single_run', 0);
parse(p, opt_structure, varargin{:});
p = p.Results;
opt_structure = p.opt_structure;

% Pull out initial p_vector
p_vector = [];
for i=1:numel(opt_structure.parameter)
    p_vector(i) = opt_structure.parameter{i}.p_value;
end

% Set up for optimization
best_e = inf;
all_e_values = [];
y_best = [];
best_p = p_vector;

fh = @(x)run_trial(x, opt_structure);

s.solver = 'particleswarm';
s.objective = fh;
s.nvars = numel(p_vector);
s.lb = zeros(numel(p_vector),1);
s.ub = ones(numel(p_vector),1);
s.options = optimoptions('particleswarm','Display','iter');

% particleswarm(s);

fminsearch(fh, p_vector);
% n = numel(p_vector);
% ga(fh, n, [],[],[],[], zeros(n,1), ones(n,1));

    function e = run_trial(p_vector, opt_structure)

        [e, trial_e, sim_output, y_attempt, target_data] = ...
            fit_worker(p_vector,opt_structure);

        all_e_values = [all_e_values e];

        % First time
        if (numel(all_e_values) == 1)
            best_e = e;
            y_best = y_attempt;
        end
        
        if (e <= best_e)
            best_e = e;
            y_best = y_attempt
            best_p = p_vector;
            copyfile(opt_structure.model_working_file_string, ...
                opt_structure.best_model_file_string);
            
            % Update best_opt_file
            best_opt_job = opt_structure;
            for i=1:numel(p_vector)
                best_opt_job.parameter{i}.p_value = p_vector(i);
            end
            out_string = savejson('MyoSim_optimization', best_opt_job);
            of = fopen(opt_structure.best_opt_file_string,'w');
            fprintf(of,'%s',out_string);
            fclose(of);
            
            
            
        end
        
        % Update figures
        if (opt_structure.figure_optimization_progress)
            draw_figure_optimization_progress(opt_structure, all_e_values);
        end
        
        if (opt_structure.figure_current_fit)
            draw_figure_current_fit(opt_structure, sim_output, ...
                y_attempt, target_data, ...
                trial_e, y_best, ...
                p_vector, best_p);
        end
        
        if (p.single_run)
            error('fit_controller stopped after single run');
        end
    end
end

