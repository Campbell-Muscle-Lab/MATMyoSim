function e = evaluate_Nyquist_fit(sim_output,target_data,varargin)

p = inputParser;
p.addParamValue('figure_Nyquist',31);
p.addParamValue('no_of_frequencies',4);
p.addParamValue('no_of_cycles',3);
p.addParamValue('first_analysis_cycle',2);
p.addParamValue('model_xml_file_string','');
parse(p,varargin{:});
p = p.Results;

% Analyze sim_output to get Nqyuist data
[sim.frequencies,sim.elastic_mod,sim.viscous_mod,sim.r_squared] =  ...
    analyze_sinusoidal_data( ...
        sim_output.time_s, ...
        sim_output.muscle_length, ...
        sim_output.muscle_force, ...
        sim_output.hs_length, ...
        'no_of_frequencies',p.no_of_frequencies, ...
        'no_of_cycles',p.no_of_cycles, ...
        'first_analysis_cycle',p.first_analysis_cycle);

% Calculate normalized fit
x_e = [];
y_e = [];
for i=1:p.no_of_frequencies
    x_e(i) = (sim.elastic_mod(i) - target_data.elastic_mod(i)) / ...
                (max(target_data.elastic_mod) - min(target_data.elastic_mod));
    y_e(i) = (sim.viscous_mod(i) - target_data.viscous_mod(i)) / ...
                (max(target_data.viscous_mod) - min(target_data.viscous_mod));
end
x_e = x_e
y_e = y_e
e = sqrt(sum((x_e).^2) + sum((y_e).^2)) / sqrt(2*p.no_of_frequencies);

% Hold best fit
global best_fit;
best_fit.all_e_values = [best_fit.all_e_values e];

if (numel(best_fit.all_e_values)==1)||(e<=min(best_fit.all_e_values))
    best_fit.e_value = e;
    best_fit.elastic_mod = sim.elastic_mod;
    best_fit.viscous_mod = sim.viscous_mod;
    copyfile(p.model_xml_file_string,'best_fit\best_fit_nyquist.xml');
end

% Display Nyquist plot if required
if (p.figure_Nyquist > 0)
    figure(p.figure_Nyquist);
    clf;
    hold on;
    
    h(1) = plot(best_fit.elastic_mod,best_fit.viscous_mod,'rs-');
    h(2) = plot(target_data.elastic_mod,target_data.viscous_mod,'ks-');
    h(3) = plot(sim.elastic_mod,sim.viscous_mod,'bo-');
    
    xlabel('Elastic modulus (N m^{-2})');
    ylabel('Viscous modulus (N m^{-2})');
    legendflex(h,{'Best fit','Experiment','Simulation'});
end