function fit_MATLAB_MyoSim_to_data(varargin)
% Fits a MATLAB_MyoSim model to data

pars = inputParser;
addOptional(pars,'model_template_file_string',[]);
addOptional(pars,'model_working_file_string',[]);
addOptional(pars,'protocol_file_strings',[]);
addOptional(pars,'target_data',[]);
addOptional(pars,'optimization_template_file_string',[]);
addOptional(pars,'fit_mode','time_fit');
addOptional(pars,'fit_variable','muscle_force');
addOptional(pars,'simulation_options_file_string',[]);
addOptional(pars,'best_base_file_string',[]);
parse(pars,varargin{:});
pars = pars.Results;

% Load optimization structure
json_structure = loadjson(pars.optimization_template_file_string);
temp_struct = json_structure.MyoSim_optimization.optimization_structure

for i=1:numel(temp_struct.parameter)
    optimization_structure(i).name = temp_struct.parameter{i}.name;
    optimization_structure(i).min_value = temp_struct.parameter{i}.min_value;
    optimization_structure(i).max_value = temp_struct.parameter{i}.max_value;
    optimization_structure(i).p_value = temp_struct.parameter{i}.p_value;
    optimization_structure(i).p_mode = temp_struct.parameter{i}.p_mode;
end

% Extract p vector
for i=1:numel(optimization_structure)
    p(i) = optimization_structure(i).p_value;
end

p = p

% Set up a worker structure
worker_structure.fit_mode = pars.fit_mode;
worker_structure.target_data = pars.target_data;
worker_structure.model_template_file_string = pars.model_template_file_string;
worker_structure.model_working_file_string = pars.model_working_file_string;
worker_structure.optimization_structure = optimization_structure;
worker_structure.protocol_file_strings = pars.protocol_file_strings;
worker_structure.fit_mode = pars.fit_mode;
worker_structure.fit_variable = pars.fit_variable;
worker_structure.simulation_options_file_string = pars.simulation_options_file_string;
worker_structure.best_base_file_string = pars.best_base_file_string;
worker_structure.figure_current_fit = 41;


% Run the fit
all_e_values = [];
best_e = inf;
[p,~,status] = fminsearch(@run_trial,p, ...
        [], ...
        worker_structure);

% n = numel(p);
% [p,~,status] = particleswarm(@run_trial,n,zeros(n,1),ones(n,1))

    function e = run_trial(p_vector, worker_structure)
       
        e = fit_worker(p_vector, worker_structure);
        
        all_e_values = [all_e_values e];

        if (e<best_e)
            
            best_model_file_string = sprintf('%s_model.json', ...
                worker_structure.best_base_file_string);
            
            copyfile(worker_structure.model_working_file_string, ...
                best_model_file_string);
            
            best_optimization_structure = [];
            for j=1:numel(p)
                best_optimization_structure.optimization_structure.parameter(j) = ...
                    optimization_structure(j);
                best_optimization_structure.optimization_structure.parameter(j).p_value = ...
                    p_vector(j);
            end
            
            best_template_file_string = sprintf('%s_template.json', ...
                worker_structure.best_base_file_string);
            savejson("MyoSim_optimization", ...
                best_optimization_structure, ...
                best_template_file_string);
        end
            

        figure(32);
        clf
        plot(log10(all_e_values),'b-');
        ylabel('log fit error');
        xlabel('iteration');
        drawnow;
    end
end







