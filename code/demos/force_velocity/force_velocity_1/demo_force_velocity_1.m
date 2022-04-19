function demo_force_velocity_1
% Demo demonstrates calculating a force_velocity curve using
% isotonic releases

% Variables
model_file = 'sim_input/model.json';
options_file = 'sim_input/options.json';
protocol_base_file = 'sim_input/prot';
results_base_file = 'sim_output/results';
isotonic_forces = linspace(5000, 1.5e5, 12);
no_of_time_points = 500;
time_step = 0.001;
isotonic_start_s = 0.4;
fit_time_s = [0.43 0.48];
display_time_s = [0.35 0.5];

% Image file for documentation
doc_image_file = ...
    '../../../../docs/pages/demos/force_velocity/force_velocity_1/force_velocity_output.png';

% Make sure the path allows us to find the right files
addpath(genpath('../../../../code'));

% Get the local directory to make sure file paths are right
base_dir = fileparts(mfilename('fullpath'));

% Update model and options files
model_file = fullfile(base_dir, model_file);
options_file = fullfile(base_dir, options_file);

% Generate protocols, storing files as a batch structure
batch_structure = [];
for i = 1 : numel(isotonic_forces)
    protocol_file{i} = fullfile(base_dir, ...
                        sprintf('%s_%i.txt', protocol_base_file, i));
    results_file{i} = fullfile(base_dir, ...
                        sprintf('%s_%i.myo', results_base_file, i));

    generate_isotonic_pCa_protocol( ...
        'time_step', time_step, ...
        'no_of_points', no_of_time_points, ...
        'during_pCa', 4.5, ...
        'isotonic_start_s', isotonic_start_s, ...
        'isotonic_stress', isotonic_forces(i), ...
        'output_file_string', ...
            sprintf('%s_%i.txt', protocol_base_file, i));
    
    % Add job as an element of an array
    batch_structure.job{i}.model_file_string = model_file;
    batch_structure.job{i}.options_file_string = options_file;
    batch_structure.job{i}.protocol_file_string = protocol_file{i};
    batch_structure.job{i}.results_file_string = results_file{i};
end

% Now that you have all the files, run the batch jobs in parallel
run_batch(batch_structure);

% Now load the result files and calculate force-velocity and power
% Display the data as you go
fig = figure(4);
clf;
cm = jet(numel(isotonic_forces));

for i = 1 : numel(isotonic_forces)
    
    % Load the simulation back in
    sim = load(results_file{i}, '-mat');
    sim_output = sim.sim_output;

    % Display the full simulation
    subplot(3,2,1);
    hold on;
    plot(sim_output.time_s, sim_output.hs_force, '-', 'Color', cm(i,:));
    subplot(3,2,3);
    hold on;
    plot(sim_output.time_s, sim_output.hs_length, '-', 'Color', cm(i,:));
    
    % Find the indices for fitting
    vi = find((sim_output.time_s > fit_time_s(1)) & ...
            (sim_output.time_s <= fit_time_s(end)));
    
    % Pull off mean force and shortening velocity
    stress(i) = mean(sim_output.hs_force(vi));
    p = polyfit(sim_output.time_s(vi), sim_output.hs_length(vi), 1);
    velocity(i) = -p(1) ./ sim_output.hs_length(1);
    power(i) = stress(i) * velocity(i);
    
    % Display the zoomed area with the fits
    di = find((sim_output.time_s > display_time_s(1)) & ...
            (sim_output.time_s <= display_time_s(end)));
    
    subplot(3,2,2);
    hold on;
    plot(sim_output.time_s(di), sim_output.hs_force(di),  '-', 'Color', cm(i,:));
    plot(sim_output.time_s(vi), stress(i) * ones(numel(vi),1), 'k-');
    subplot(3,2,4);
    hold on;
    plot(sim_output.time_s(di), sim_output.hs_length(di),  '-', 'Color', cm(i,:));
    plot(sim_output.time_s(vi), polyval(p, sim_output.time_s(vi)), 'k-');
    
    % Add in force-velocity and force-power curves
    subplot(3,2,5);
    hold on;
    plot(stress(i), velocity(i), 'o', 'Color', cm(i,:));
    
    subplot(3,2,6);
    hold on;
    plot(stress(i), power(i), 'o', 'Color', cm(i,:));
    
    % Add labels
    if (i == numel(isotonic_forces))
        for j=1:2
            subplot(3,2,j);
            xlabel('Time (s)');
            ylabel('Stress (kN m^{-2})');
            subplot(3,2,j+2);
            xlabel('Time (s)');
            ylabel('Half-sarcomere length (nm)');
        end
        subplot(3,2,5);
        xlabel('Stress (kN m^{-2})');
        ylabel('Shortening velocity (l_0 s^{-1})');
        subplot(3,2,6);
        xlabel('Stress (kN m^{-2})');
        ylabel('Power (kN m^{-2} l_0 s^{-1})');
    end
end

% Add in fits for fv and force power curves

% First the fv curve
[x0,a,b,r_squared,stress_fit,vel_fit] = fit_hyperbola( ...
    'x_data', stress, 'y_data', velocity, ...
    'x_fit', linspace(0, 2e5, 100));
subplot(3,2,5);
vi = find(vel_fit>=0);
plot(stress_fit(vi), vel_fit(vi), 'k-');
title(sprintf('(x+a)(y+b)=b(x_0+a)\na=%g, b=%g, x_0=%g',a,b,x0));

% Now the power curve
[x0,a,b,r_squared,stress_fit,pow_fit] = fit_power_curve(...
    stress, power, ...
    'x_fit', linspace(0, 2e5, 100));
subplot(3,2,6);
vi = find(pow_fit>=0);
plot(stress_fit(vi), pow_fit(vi), 'k-');
title(sprintf('y=x*b*(((x_0+a)/(x+a))-1)\na=%g, b=%g, x_0=%g',a,b,x0));

% Save figure to file for documentation
exportgraphics(fig, doc_image_file);