function draw_figure_current_fit(opt_structure, sim_output, ...
    y_attempt, target_data, ...
    trial_e, y_best, p_vector)

figure(opt_structure.figure_current_fit)
clf;
subplot(3,1,1);
if (strcmp(opt_structure.fit_mode,'fit_in_time_domain'))
    hold on;
    tn = numel(target_data{1});
    for i=1:numel(target_data)
        h(1) = plot(sim_output{i}.time_s(end-tn+1:end),target_data{i},'k-');
        label{1} = 'Target';
        switch (opt_structure.fit_variable)
            case 'muscle_force'
                y_attempt{i} = sim_output{i}.muscle_force;
            otherwise
        end
        h(2)=plot(sim_output{i}.time_s, y_attempt{i},'b-');
        label{2} = 'Attempt';
        if (~isempty(y_best))
            h(3) = plot(sim_output{i}.time_s, y_best{i},'r-');
            label{3} = 'Best attempt';
        end
    end
    xlabel('Time (s)');
    ylabel(opt_structure.fit_variable, ...
        'Interpreter','none');
end
legend(h, label,'Location','northwest');

subplot(3,1,2);
plot(log10(trial_e),'bo');
ylabel('log_{10} (Trial error)');
xlabel('Trial number');

subplot(3,1,3);
hold on;
for i=1:numel(p_vector)
    y = 2+numel(p_vector)-i;
    plot(p_vector(i), y, 'bo');
    text(-5, y, opt_structure.parameter{i}.name, ...
        'HorizontalAlignment','left', ...
        'Interpreter','none');
    text(3, y, sprintf('%4g', ...
            return_parameter_value(opt_structure.parameter{i}, p_vector(i))), ...
        'HorizontalAlignment','left');
end
for i=-2:2
    plot([i i],[0 2+numel(p_vector)],'k:');
end
xlim([-5 4]);
ylim([0 2+numel(p_vector)]);
xlabel('p_value', 'Interpreter', 'none');
ax =gca;
ax.YAxis.Visible = 'off';
    
