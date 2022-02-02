function demo_tension_pCa
% Demo 

% Variables
batch_file_string = 'tension_pCa_batch.json';

% Make sure the path allows us to find the right files
addpath(genpath('../../../../code'));

% Load the batch data
batch_json = loadjson(batch_file_string);
batch_data = batch_json.MyoSim_batch;

% Run the batch
run_batch(batch_data);

% Make a figure showing each file and then plot pCa-force curve

% Make a figure
figure(1);
clf;
color_map = jet(numel(batch_data.job));

for i=1:numel(batch_data.job)
    
    % Load data
    sim = load(batch_data.job{i}.results_file_string, '-mat');
    sim_output = sim.sim_output;    
    
    % Plot force and pCa against time
    subplot(5, 1, 1);
    hold on;
    plot(sim_output.time_s, sim_output.muscle_force, '-', ...
        'Color', color_map(i,:));
    ylabel('Force (kN m^{-2})');
    
    subplot(5, 1, 2);
    hold on;
    pCa_trace = -log10(sim_output.Ca);
    plot(sim_output.time_s, pCa_trace, '-', ...
        'Color', color_map(i,:));
    ylabel('pCa');
    xlabel('Time (s)');
    
    % Keep force and pCa in a structure
    curve_data.pCa(i) = pCa_trace(end);
    curve_data.y(i) = sim_output.muscle_force(end);
    curve_data.y_error(i) = 0;
end

% Fit the tension-pCa curve
[curve_data.pCa50, curve_data.n_H, ...
    curve_data.passive_force, curve_data.active_force, ...
    curve_data.r_squared, curve_data.x_fit, curve_data.y_fit] = ...
        fit_Hill_curve(curve_data.pCa, curve_data.y);

% Plot
title_string = sprintf('pCa_{50} = %.2f n_H = %.2f', ...
                    curve_data.pCa50, curve_data.n_H);

plot_pCa_data_with_y_errors( curve_data, ...
    'axis_handle', subplot(2,1,2), ...
    'y_axis_label',{'Stress','(N m^{-2})'}, ...
    'y_label_offset', -0.1, ...
    'title', title_string);

% Save the figures as images to the documentation
doc_image_folder = ...
    '../../../../docs/pages/demos/getting_started/tension_pCa';
figure_export('output_file_string', ...
    sprintf('%s/tension_pCa_output', doc_image_folder), ...
    'output_type', 'png');

