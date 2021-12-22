function draw_figure_current_fit(opt_struct, sim_output, ...
    y_attempt, target_data, trial_e, y_best, p_vector, best_p)

figure(opt_struct.figure_current_fit)
clf;
subplot(3,1,1);

if (strcmp(opt_struct.fit_mode, 'fit_pCa_curve') | ...
        strcmp(opt_struct.fit_mode, 'fit_pCa_curve_params'))
    
    % Plot force traces as we go
    subplot(3,2,1);
    hold on;
    
    no_of_curves = numel(target_data);
    for i = 1:no_of_curves
        
        % Pull off simulation data - do this first to get pCa values
        for j=1:numel(sim_output{i}.sim)
            s = sim_output{i}.sim(j);
            pd(i+2*no_of_curves).pCa(j) = -log10(s.Ca(end));
            pd(i+2*no_of_curves).y(j) = s.(opt_struct.fit_variable)(end);
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

if (strcmp(opt_struct.fit_mode, 'fit_fv_curve'))
    % Draw fv curves
    
    no_of_curves = numel(trial_e);
    cm = jet(no_of_curves);
    for i = 1 : no_of_curves
        for j = 1 : numel(sim_output{i}.sim)
            s = sim_output{i}.sim(j);
    
            di = find( ...
                    (s.time_s > opt_struct.display_time_s(1)) & ...
                        (s.time_s <= opt_struct.display_time_s(end)));
            
            subplot(6,2,1);
            hold on;
            plot(s.time_s(di), s.hs_force(di), '-', 'Color', cm(i,:));
            
            subplot(6,2,3);
            hold on;
            plot(s.time_s(di), s.hs_length(di), '-', 'Color', cm(i,:));
            
            fi = find( ...
                    (s.time_s > opt_struct.fit_time_s(1)) & ...
                        (s.time_s <= opt_struct.fit_time_s(end)));
            po = polyfit(s.time_s(fi), s.hs_length(fi), 1);
            fy = polyval(po, s.time_s(fi));
            plot(s.time_s(fi), fy, 'k-');

        end
        subplot(6,2,1);
        ylabel({'Stress','(kN m^{-2})'});
        
        subplot(6,2,3);
        ylabel({'HS length','(nm)'});
        
        
        subplot(3,2,2);
        hold on;
        plot(y_attempt{i}(:,1), y_attempt{i}(:,2),'bo');
        [attempt_x0(i), attempt_a(i), attempt_b(i), attempt_r_sq(i), ...
            attempt_x_fit{i}, attempt_y_fit{i}] = ...
                fit_hyperbola('x_data', y_attempt{i}(:,1), ...
                    'y_data', y_attempt{i}(:,2));
        si = find(attempt_y_fit{i} > 0);
        plot(attempt_x_fit{i}, attempt_y_fit{i}, 'b-');
        xlabel({'Stress','(kN m^{-2})'});
        ylabel({'Shortening','velocity','(l_0 s^{-1})'});
        
        plot(target_data{i}(:,1), target_data{i}(:,2),'k^');
        [target_x0(i), target_a(i), target_b(i), target_r_sq(i), ...
            target_x_fit{i}, target_y_fit{i}] = ...
                fit_hyperbola('x_data', target_data{i}(:,1), ...
                    'y_data', target_data{i}(:,2));
        si = find(target_y_fit{i} > 0);
        plot(target_x_fit{i}, target_y_fit{i}, 'k-');
        if (~isempty(y_best))
            h(3) = plot(y_best{i}(:,1), y_best{i}(:,2),'rs');
            [best_x0(i), best_a(i), best_b(i), best_r_sq(i), ...
            best_x_fit{i}, best_y_fit{i}] = ...
                fit_hyperbola('x_data', y_best{i}(:,1), ...
                    'y_data', y_best{i}(:,2));
            si = find(best_y_fit{i} > 0);
            plot(best_x_fit{i}, best_y_fit{i}, 'r-');
        end
    end
end

if (strcmp(opt_struct.fit_mode, 'fit_fv_curve2'))
    % Draw fv curves
    
    no_of_curves = numel(trial_e);
    cm = jet(no_of_curves);
%     if (no_of_curves == 2)
%         cm = [1 0 0 ; 0 1 0];
%     end
    
    for i = 1 : no_of_curves
        for j = 1 : numel(sim_output{i}.sim)
            s = sim_output{i}.sim(j);
    
            di = find( ...
                    (s.time_s > opt_struct.display_time_s(1)) & ...
                        (s.time_s <= opt_struct.display_time_s(end)));
            
            if (s.hs_length(end) < s.hs_length(1))
                ti = find(s.hs_length > 1000, 1, 'last');
            else
                ti = numel(s.hs_length);
            end
                    
            subplot(6,2,1);
            hold on;
            plot(s.time_s(di), s.hs_force(di), '-', 'Color', cm(i,:));
            plot(s.time_s(ti), s.hs_force(ti), 'k+');
            
            subplot(6,2,3);
            hold on;
            plot(s.time_s(di), s.hs_length(di), '-', 'Color', cm(i,:));
            plot(s.time_s(ti), s.hs_length(ti), 'k+');
            
            fi = find( ...
                    (s.time_s > opt_struct.fit_time_s(1)) & ...
                        (s.time_s <= opt_struct.fit_time_s(end)));
            po = polyfit(s.time_s(fi), s.hs_length(fi), 1);
            fy = polyval(po, s.time_s(fi));
            plot(s.time_s(fi), fy, 'k-');

        end
        
        subplot(3,2,2);
        hold on;
        plot(y_attempt{i}(:,1), y_attempt{i}(:,2),'o', 'Color', cm(i,:));
        [attempt_x0(i), attempt_a(i), attempt_b(i), attempt_r_sq(i), ...
            attempt_x_fit{i}, attempt_y_fit{i}] = ...
                fit_hyperbola('x_data', y_attempt{i}(:,1), ...
                    'y_data', y_attempt{i}(:,2));
        si = find(attempt_y_fit{i} > 0);
        plot(attempt_x_fit{i}, attempt_y_fit{i}, '-', 'Color', cm(i,:));
        
        plot(target_data{i}(:,1), target_data{i}(:,2),'ko');
        [target_x0(i), target_a(i), target_b(i), target_r_sq(i), ...
            target_x_fit{i}, target_y_fit{i}] = ...
                fit_hyperbola('x_data', target_data{i}(:,1), ...
                    'y_data', target_data{i}(:,2));
        si = find(target_y_fit{i} > 0);
        plot(target_x_fit{i}, target_y_fit{i}, 'k-');
        if (~isempty(y_best))
            h(3) = plot(y_best{i}(:,1), y_best{i}(:,2),'ro');
            [best_x0(i), best_a(i), best_b(i), best_r_sq(i), ...
            best_x_fit{i}, best_y_fit{i}] = ...
                fit_hyperbola('x_data', y_best{i}(:,1), ...
                    'y_data', y_best{i}(:,2));
            si = find(best_y_fit{i} > 0);
            plot(best_x_fit{i}, best_y_fit{i}, 'r-');
        end
    end
end
       
       

if (strcmp(opt_struct.fit_mode,'fit_in_time_domain'))
    hold on;
    tn = numel(target_data{1});
    for i=1:numel(target_data)
        h(1) = plot(sim_output{i}.time_s(end-tn+1:end),target_data{i},'k-');
        label{1} = 'Target';
        switch (opt_struct.fit_variable)
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
    ylabel(opt_struct.fit_variable, ...
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
    extract_p_data_from_opt_structure(opt_struct, p_vector);
for i=1:numel(p_vector)
    y = 2+numel(p_vector)-i;
    plot(p_vector(i), y, 'bo');
    plot(best_p(i), y, 'rs');
    text(-2, y, par_labels{i}, ...
        'HorizontalAlignment','left', ...
        'Interpreter','none');
    text(2.5, y, sprintf('%4g', par_values(i)), ...
        'HorizontalAlignment','left');
end
for i=-2:2
    plot([i i],[0 2+numel(p_vector)],'k:');
end
xlim([-2 3.5]);
ylim([0 2+numel(p_vector)]);
xlabel('p_value', 'Interpreter', 'none');
ax =gca;
ax.YAxis.Visible = 'off';
    
drawnow;