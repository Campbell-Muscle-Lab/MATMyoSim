function draw_figure_current_fit(opt_structure, sim_output, ...
    y_attempt, target_data, trial_e, y_best, p_vector, best_p)

figure(opt_structure.figure_current_fit)
clf;
subplot(3,1,1);

if (strcmp(opt_structure.fit_mode, 'fit_pCa_curve'))
    
    % Plot force traces as we go
    subplot(3,2,1);
    hold on;
    
    no_of_curves = numel(target_data);
    for i = 1:no_of_curves
        
        % Pull off simulation data - do this first to get pCa values
        for j=1:numel(sim_output{i}.sim)
            s = sim_output{i}.sim(j);
            pd(i+2*no_of_curves).pCa(j) = -log10(s.Ca(end));
            pd(i+2*no_of_curves).y(j) = s.(opt_structure.fit_variable)(end);
            pd(i+2*no_of_curves).y_error(j) = 0;
            
            plot(s.time_s, s.muscle_force, '-');
        end
        
        % Fit
        [pd(i+2*no_of_curves).pCa50, pd(i+2*no_of_curves).n_H, ~,~,~, ...
            pd(i+2*no_of_curves).x_fit, pd(i+2*no_of_curves).y_fit] = ...
            fit_Hill_curve(pd(i+2*no_of_curves).pCa, pd(i+2*no_of_curves).y);
        
        % Pull off target data
        for j=1:numel(sim_output{i}.sim)
            pd(i+no_of_curves).pCa(j) = pd(i+2*no_of_curves).pCa(j);
            pd(i+no_of_curves).y(j) = target_data{i}(j);
            pd(i+no_of_curves).y_error(j) = 0;
        end
        
        % Fit
        [pd(i+no_of_curves).pCa50, pd(i+no_of_curves).n_H, ~,~,~, ...
            pd(i+no_of_curves).x_fit, pd(i+no_of_curves).y_fit] = ...
                fit_Hill_curve( ...
                    pd(i+no_of_curves).pCa, pd(i+no_of_curves).y);
            
        % Finally, y_best
        for j=1:numel(sim_output{i}.sim)
            pd(i).pCa(j) = pd(i+2*no_of_curves).pCa(j);
            pd(i).y(j) = y_best{i}(j);
            pd(i).y_error(j) = 0;
        end
        
        % Fit
        [pd(i).pCa50, pd(i).n_H, ~,~,~, ...
            pd(i).x_fit, pd(i).y_fit] = ...
                fit_Hill_curve(pd(i).pCa, pd(i).y);
    end
    xlabel('Time (s)');
    ylabel('Force');
    
    % Set colors - red for best, black for target, colors for current
    marker_face_colors = [repmat([1 0 0],[no_of_curves,1]) ; ...
        zeros(no_of_curves,3) ; jet(no_of_curves)];
    
    plot_pCa_data_with_y_errors( pd, ...
        'axis_handle', subplot(3,2,2), ...
        'y_axis_label',{'Stress','(N m^{-2})'}, ...
        'y_label_offset', -0.1, ...
        'marker_face_colors', marker_face_colors);

end
        

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
    
    legend(h, label,'Location','northwest');
end


subplot(3,1,2);
plot(log10(trial_e),'bo');
ylabel('log_{10} (Trial error)');
xlabel('Trial number');
xlim([0 numel(trial_e)+1]);

subplot(3,1,3);
hold on;
[~, par_values, par_labels] = ...
    extract_p_data_from_opt_structure(opt_structure, p_vector);
for i=1:numel(p_vector)
    y = 2+numel(p_vector)-i;
    plot(p_vector(i), y, 'bo');
    plot(best_p(i), y, 'rs');
    text(-5, y, par_labels{i}, ...
        'HorizontalAlignment','left', ...
        'Interpreter','none');
    text(3, y, sprintf('%4g', par_values(i)), ...
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
    
drawnow;