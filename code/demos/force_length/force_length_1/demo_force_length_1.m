function demo_force_length_1
% Demo demonstrates force_length curve

% Variables
base_model_file = 'sim_input/base_model.json';
options_file = 'sim_input/options.json';
protocol_file = 'sim_input/protocol.txt';
results_base_file = 'sim_output/results';
no_of_time_points = 500;
time_step = 0.001;
hs_lengths = linspace(700, 2100, 20);

% Image file for documentation
doc_image_file = ...
    '../../../../docs/pages/demos/force_length/force_length_1/force_length_output';

% Make sure the path allows us to find the right files
addpath(genpath('../../../../code'));

% Generate a protocol
generate_isometric_pCa_protocol( ...
    'time_step', time_step, ...
    'no_of_points', no_of_time_points, ...
    'during_pCa', 4.5, ...
    'output_file_string', protocol_file);

% Load the base_model
base_model = loadjson(base_model_file);

% Create a batch structure

% Now loop through the hs_lengths
for i = 1 : numel(hs_lengths)
    
    % Create and save a new model file for each length
    model = base_model;
    model.MyoSim_model.hs_props.hs_length = hs_lengths(i);
    
    model_file = fullfile(cd, 'sim_input', 'hs_models', ...
        sprintf('model_%i.json', i))
    savejson('MyoSim_model', model.MyoSim_model, model_file);
    
    % Set up the results file
    results_file{i} = sprintf('%s_%i.myo',results_base_file, i);
    
    % Add the job to the batch structure
    batch_structure.job{i}.model_file_string = model_file;
    batch_structure.job{i}.options_file_string = options_file;
    batch_structure.job{i}.protocol_file_string = protocol_file;
    batch_structure.job{i}.results_file_string = results_file{i};
end

% Now that you have all the files, run the batch jobs in parallel
run_batch(batch_structure);

% Now load the results files and show the force-length properties
figure(4);
clf;
cm = jet(numel(hs_lengths));

for i = 1 : numel(hs_lengths)
    
    % Load the simulation back in
    sim = load(results_file{i}, '-mat');
    sim_output = sim.sim_output;

    % Display the full simulation
    subplot(4,1,1);
    hold on;
    plot(sim_output.time_s, sim_output.hs_force, '-', 'Color', cm(i,:));
    
    % Hold the length and isometric force
    hs_lengths(i) = sim_output.hs_length(1);
    total_force(i) = sim_output.hs_force(end);
    active_force(i) = sim_output.cb_force(end);
    passive_force(i) = sim_output.int_pas_force(end);
    
    % Display the data
    subplot(4,1,2);
    hold on;
    plot(hs_lengths(i), total_force(i), 'o', 'Color', cm(i,:));
    subplot(4,1,3);
    hold on;
    plot(hs_lengths(i), active_force(i), 's', 'Color', cm(i,:));
    subplot(4,1,4);
    hold on;
    plot(hs_lengths(i), passive_force(i), '^', 'Color', cm(i,:));
    
    % Add labels
    if (i==numel(hs_lengths))
        subplot(4,1,1);
        xlabel('Time (s)');
        ylabel('Stress (kN m^{-2})');
        
        subplot(4,1,2);
        plot(hs_lengths, total_force, 'k-');
        ylabel('Total stress (kN m^{-2})');
        xlabel('Half-sarcomere length (nm)');
        ylim([0 1.2 * max(total_force)]);
        subplot(4,1,4);
        
        subplot(4,1,3);
        plot(hs_lengths, active_force, 'k-');
        xlabel('Half-sarcomere length (nm)');
        ylabel('Active stress (kN m^{-2})');
        
        subplot(4,1,4);
        plot(hs_lengths, passive_force, 'k-');
        xlabel('Time (s)');
        ylabel('Passive stress (kN m^{-2})');
        xlabel('Half-sarcomere length (nm)');
    end
        
end

% Save figure to file for documentation
figure_export('output_file', doc_image_file, ...
    'output_type', 'png');
