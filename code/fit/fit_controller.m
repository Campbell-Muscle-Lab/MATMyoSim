function fit_controller(opt_structure, varargin)

p = inputParser;
addRequired(p, 'opt_structure');
addOptional(p, 'single_run', 0);
addOptional(p, 'output_handler', []);
parse(p, opt_structure, varargin{:});
p = p.Results;
opt_structure = p.opt_structure;

% Pull out initial p_vector
p_vector = extract_p_data_from_opt_structure(opt_structure);

% Set up for optimization
best_e = inf;
all_e_values = [];
y_best = [];
best_p = p_vector;

fh = @(x)run_trial(x, opt_structure);
% 
% s.solver = 'particleswarm';
% s.objective = fh;
% s.nvars = numel(p_vector);
% s.lb = zeros(numel(p_vector),1);
% s.ub = ones(numel(p_vector),1);
% s.options = optimoptions('particleswarm','Display','iter');
% 
% % particleswarm(s);

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
            y_best = y_attempt;
            best_p = p_vector;
            
            % Copy model files to best folder
            for i = 1 : numel(opt_structure.job)
                full_file_string = ...
                    fullfile(cd, opt_structure.job{i}.model_file_string);
                [~, a, b] =fileparts(full_file_string);
                file_string = sprintf('%s%s',a,b);
                new_file_string = ...
                    fullfile(cd, opt_structure.best_model_folder, file_string);
                if (~isdir(fileparts(new_file_string)))
                    mkdir(fileparts(new_file_string));
                end
                copyfile(full_file_string, new_file_string);
            end
            
            % Update best_opt_file
            update_best_opt_file(opt_structure, p_vector);
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
        
        if (~isempty(p.output_handler))
            p.output_handler(opt_structure, sim_output, ...
                y_attempt, target_data, y_best)
        end
        
                
        if (p.single_run)
            error('fit_controller stopped after single run');
        end
    end
end

