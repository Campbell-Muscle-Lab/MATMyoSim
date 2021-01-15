function demo_recreate_best_fit
% Function demonstrates fitting a simple tension-pCa curve

% Variables
optimization_file_string = 'workers/best_tension_pCa_model_after_optimization.json';
target_data_file_string = 'target_data/target_data.xlsx';

marker_symbols = repmat({'o','s','^','v'},[1 2]);
marker_colors = [zeros(4,3) ; [1 0 0;0 1 0;0 0 1;1 1 0]]; 

% Code

% Make sure the path allows us to find the right files
addpath(genpath('../../../../code'));

% Load optimization job
opt_json = loadjson(optimization_file_string);
opt_structure = opt_json.MyoSim_optimization;

% Start the optimization
fit_controller(opt_structure, ...
    'single_run', 1);

a = opt_structure
no_of_curves = 4;
pCa_values_per_curve = 7;


% Read in target data
td = readtable(target_data_file_string);

% Create curves
for curve_counter = 1 : no_of_curves
    vi = find(td.curve == curve_counter);
    for pCa_counter = 1 : numel(vi)
        pd(curve_counter).pCa(pCa_counter) = ...
            td.pCa(vi(pCa_counter));
        pd(curve_counter).y(pCa_counter) = ...
            td.force(vi(pCa_counter));
        pd(curve_counter).y_error(pCa_counter) = ...
            0;
    end
    [pd(curve_counter).pCa50, pd(curve_counter).n_h, ~,~,~, ...
        pd(curve_counter).x_fit, pd(curve_counter).y_fit] = ...
            fit_Hill_curve(pd(curve_counter).pCa, ...
                pd(curve_counter).y);
end

% Add in simulation data
ind = 1;
for curve_counter = 1 : no_of_curves
    for pCa_counter = 1 : pCa_values_per_curve
        result_file_string = opt_structure.job{ind}.results_file_string;
        
        sim = load(result_file_string, '-mat');
        sim_output= sim.sim_output;

        pd(curve_counter + no_of_curves).pCa(pCa_counter) = -log10(sim_output.Ca(end));
        pd(curve_counter + no_of_curves).y(pCa_counter) = sim_output.hs_force(end);
        pd(curve_counter + no_of_curves).y_error(pCa_counter) = 0;
        
        ind = ind + 1;
    end
    
    [pd(curve_counter + no_of_curves).pCa50, ...
        pd(curve_counter + no_of_curves).n_h, ~,~,~, ...
        pd(curve_counter + no_of_curves).x_fit, ...
        pd(curve_counter + no_of_curves).y_fit] = ...
            fit_Hill_curve(pd(curve_counter + no_of_curves).pCa, ...
                pd(curve_counter + no_of_curves).y);
end

figure(1);
clf;
plot_pCa_data_with_y_errors(pd, ...
        'marker_face_colors',marker_colors, ...
        'marker_symbols',marker_symbols, ...
        'high_pCa_value', 8.0, ...
        'title',{'Target in black','Simulation in color'}, ...
        'title_y_offset', 0.9);