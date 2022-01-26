function fit_controller(opt_file, varargin)

p = inputParser;
addRequired(p, 'opt_file');
addOptional(p, 'single_run', 0);
addOptional(p, 'fit_handler', []);
addOptional(p, 'output_handler', []);
parse(p, opt_file, varargin{:});
p = p.Results;

% Load the opt stucture
opt_struct = load_opt_structure(opt_file);

% Add in fit handler if required
if (~isempty(p.fit_handler))
    opt_struct.fit_handler = p.fit_handler;
end

% Pull out initial p_vector
p_vector = extract_p_data_from_opt_structure(opt_struct);

% Pull out batch_struct
batch_struct = load_batch_structure(opt_file);

% Set up for optimization
best_e = inf;
all_e_values = [];
y_best = [];
best_p = p_vector;

fh = @(x)run_trial(x, opt_struct, batch_struct);

switch opt_struct.optimizer
    case 'particle_swarm'
        s.solver = 'particleswarm';
        s.objective = fh;
        s.nvars = numel(p_vector);
        s.lb = zeros(numel(p_vector),1);
        s.ub = ones(numel(p_vector),1);
        s.options = optimoptions('particleswarm', ...
                        'Display','iter')

        particleswarm(s);
        
    case 'ga'
        s.solver = 'ga';
        s.fitnessfcn = fh;
        s.nvars = numel(p_vector);
        s.lb = zeros(numel(p_vector),1);
        s.ub = ones(numel(p_vector),1);
        s.options = [];
        
        ga(s);        
    
    case 'fminsearch'
        fminsearch(fh, p_vector);
        
    case 'fmincon'
        fmincon(fh, p_vector, [], [], [], [], ...
            zeros(numel(p_vector),1), ones(numel(p_vector),1), [], ...
            optimoptions('fmincon', 'FiniteDifferenceStepSize',0.01));
end

    function e = run_trial(p_vector, opt_struct, batch_struct)

        [e, trial_e, sim_output, y_attempt, target_data] = ...
            fit_worker(p_vector,opt_struct, batch_struct);

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
            for i = 1 : numel(batch_struct.job)
                [~, a, b] = fileparts(batch_struct.job{i}.model_file_string);
                file_string = sprintf('%s%s',a,b);
                new_file_string = ...
                    fullfile(opt_struct.files.best_model_folder, file_string);
                if (~isdir(fileparts(new_file_string)))
                    mkdir(fileparts(new_file_string));
                end
                copyfile(batch_struct.job{i}.model_file_string, ...
                    new_file_string, 'f');
            end
            
            % Update best_opt_file
            % Cannot write function handle
            try
                opt_struct = rmfield(opt_struct, 'fit_handler');
            end
            update_best_opt_file(opt_struct, p_vector);
        end
        
        % Update figures
        if (opt_struct.figure_optimization_progress)
            draw_figure_optimization_progress(opt_struct, all_e_values);
        end
        
        if (opt_struct.figure_current_fit)
            draw_figure_current_fit(opt_struct, sim_output, ...
                y_attempt, target_data, ...
                trial_e, y_best, ...
                p_vector, best_p);
        end
        
        if (~isempty(p.output_handler))
            p.output_handler(opt_struct, sim_output, ...
                y_attempt, target_data, y_best)
        end
               
        if (p.single_run)
            error('fit_controller stopped after single run');
        end
    end
end

