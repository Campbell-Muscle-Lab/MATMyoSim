function draw_curves(opt_structure, sim_output, ...
        y_attempt, target_data, y_best)

% Variables
cm = [0 0 1 ; 0 0 0 ; 1 0 0];
    
no_of_curves = numel(sim_output);

% Create a figure
rows = ceil(sqrt(no_of_curves));
cols = ceil(sqrt(no_of_curves));

figure(5);

sp = initialise_publication_quality_figure( ...
        'no_of_panels_high', rows, ...
        'no_of_panels_wide', cols, ...
        'right_margin', 1, ...
        'x_to_y_axes_ratio', 2);

for c = 1 : no_of_curves
    subplot(sp(c));
    
    %
    tar = target_data{c};
    be = y_best{c};
    
    pd=[];
    jobs = sim_output{c}.sim;
    for j = 1 : numel(jobs)
        d = jobs(j);
        d.pCa = -log10(d.Ca);
        
        pd(1).pCa(j) = d.pCa(end);
        pd(1).y(j) = d.muscle_force(end);
        pd(1).y_error(j) = 0;
        
        pd(2).pCa(j) = pd(1).pCa(j);
        pd(2).y(j) = tar(j);
        pd(2).y_error(j) = 0;
        
        pd(3).pCa(j) = pd(1).pCa(j);
        pd(3).y(j) = be(j);
        pd(3).y_error(j) = 0;
    end
    
    % Fit curves
    for j = 1 : 3
        [pd(j).pCa50, pd(j).n_H, ~, ~, ~, pd(j).x_fit, pd(j).y_fit] = ...
            fit_Hill_curve(pd(j).pCa, pd(j).y);
    end
    
    % Plot
    [h,ad] = plot_pCa_data_with_y_errors(pd, ...
        'high_pCa_value', 8.0, ...
        'marker_face_colors', cm);
    
    x_anchor = 6.8;
    y_anchor = ad.y_ticks(end);
    y_spacing = 0.1*y_anchor;
    
    for j = 1 : 3
        temp_string = sprintf('pCa_{50} = %.3f n_H = %.3f', ...
            pd(j).pCa50, pd(j).n_H);
        text(x_anchor, y_anchor, temp_string, ...
            'HorizontalAlignment','left', ...
            'Color', cm(j,:), ...
            'FontSize',8);
        y_anchor = y_anchor - y_spacing;
    end
    
end

drawnow;