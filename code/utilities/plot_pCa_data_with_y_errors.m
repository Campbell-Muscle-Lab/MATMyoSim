function [h,axes_data]=plot_pCa_data_with_y_errors(d,varargin)

p=inputParser;
addRequired(p,'d');
addOptional(p,'axis_handle',gca);
addOptional(p,'y_axis_label',{'Stress','(kN m^{-2})'});
addOptional(p,'y_label_offset',-0.15);
addOptional(p,'y_axis_offset',-0.05);
addOptional(p,'y_scale_factor',NaN);
addOptional(p,'x_axis_offset',0.05);
addOptional(p,'x_label_offset',-0.25);
addOptional(p,'high_pCa_value',9.0);
addOptional(p,'pCa90_replacement_value',7.0);
addOptional(p,'x_limits',[4.5 7]);
addOptional(p,'x_ticks',[7 6.5:-0.5:4.5]);
addOptional(p,'x_tick_decimal_places',1);
addOptional(p,'y_ticks',[]);
addOptional(p,'x_break_point',6.75);
addOptional(p,'x_break_width',0.04);
addOptional(p,'x_break_spacing',0.075);
addOptional(p,'x_break_line_width',1.5);
addOptional(p,'x_break_rel_height',0.03);
addOptional(p,'draw_data_break',1);
addOptional(p,'marker_face_colors',[]);
addOptional(p,'marker_symbols',{'o','^','s','d','p','v'});
addOptional(p,'marker_transparency',[]);
addOptional(p,'marker_size',8);
addOptional(p,'fit_line_colors',[]);
addOptional(p,'label_font_size',12);
addOptional(p,'tick_font_size',12);
addOptional(p,'x_tick_length',0.03);
addOptional(p,'y_tick_length',0.025);
addOptional(p,'y_tick_decimal_places',0);
addOptional(p,'y_tick_label_horizontal_offset',-0.04);
addOptional(p,'fit_line_width',1.5);
addOptional(p,'straight_join_style','none');
addOptional(p,'title','');
addOptional(p,'title_text_interpreter','tex');
addOptional(p,'title_font_weight','normal');
addOptional(p,'title_y_offset',1.05);
addOptional(p,'x_axis_off',0);
addOptional(p,'y_axis_off',0);
addOptional(p,'gui_scale_factor',0);

parse(p,d,varargin{:});
p=p.Results;

% Code
if (isempty(p.axis_handle))
    figure;
    clf;
else
    subplot(p.axis_handle);
    hold on;
end

if (isempty(p.marker_face_colors))
    p.marker_face_colors = jet(numel(d));
end

if (isempty(p.fit_line_colors))
    p.fit_line_colors = p.marker_face_colors;
end

% Correct for y_scale_factor
if (~isnan(p.y_scale_factor))
    for i=1:numel(d)
        d(i).y = p.y_scale_factor * d(i).y;
        d(i).y_error = p.y_scale_factor * d(i).y_error;
        d(i).y_fit = p.y_scale_factor * d(i).y_fit;
    end
end

if (isempty(p.y_ticks))
    y=[];
    for i=1:numel(d)
        [r,c]=size(d(i).y);
        if (r>c)
            y_temp = d(i).y;
        else
            y_temp = d(i).y';
        end
        y = [y ; y_temp];
    end
    min_y = min(y);
    max_y = max(y);
    if (min_y>0)
        p.y_ticks = [0 multiple_greater_than(max(y(:)),10^floor(log10(max(y(:)))))];
    else
        if (max_y<0)
            p.y_ticks = [-multiple_greater_than(-min_y,10^floor(log10(-min_y))) 0];
        else
            p.y_ticks = [-multiple_greater_than(-min_y,10^floor(log10(-min_y))) ...
                multiple_greater_than(max_y,10^floor(log10(max_y)))];
            if (isnan(p.y_ticks(1)))
                p.y_ticks(1)=0;
            end
        end
    end
    if (isnan(p.y_ticks(end)))
        p.y_ticks(end) = max_y;
    end
end

% Replace pCa 9.0 values
if (~isempty(p.pCa90_replacement_value))
    for i=1:numel(d)
        vi = find(d(i).pCa == p.high_pCa_value);
        d(i).pCa(vi) = p.pCa90_replacement_value;
    end
end

% Make sure data are in column vectors
for i=1:numel(d)
    [r,c]=size(d(i).pCa);
    if (c>r)
        d(i).pCa = d(i).pCa';
    end
    [r,c]=size(d(i).y);
    if (c>r)
        d(i).y = d(i).y';
    end
    [r,c]=size(d(i).y_error);
    if (c>r)
        d(i).y_error = d(i).y_error';
    end
end

% Set up data
for i=1:numel(d)
    x_data(i).mean_values = d(i).pCa;
    x_data(i).error_values = 0*d(i).pCa;
    y_data(i).mean_values = d(i).y;
    y_data(i).error_values = d(i).y_error;
end

if (isempty(p.marker_transparency))
    h=plot_with_error_bars( ...
        'axis_handle',p.axis_handle, ...
        'x_data',x_data, ...
        'y_data',y_data, ...
        'y_limits',[p.y_ticks(1) p.y_ticks(end)], ...
        'marker_face_color',p.marker_face_colors, ...
        'marker_symbols',p.marker_symbols, ...
        'marker_size',p.marker_size, ...
        'straight_join_style',p.straight_join_style);
else
    h=scatter_with_error_bars( ...
        'axis_handle',p.axis_handle, ...
        'x_data',x_data, ...
        'y_data',y_data, ...
        'y_limits',[p.y_ticks(1) p.y_ticks(end)], ...
        'marker_face_color',p.marker_face_colors, ...
        'marker_symbols',p.marker_symbols, ...
        'marker_size',p.marker_size, ...
        'straight_join_style',p.straight_join_style, ...
        'marker_transparency',p.marker_transparency);
end

if (isfield(d(1),'x_fit'))
    for i=1:numel(d)
        % plot line in two parts
        for j=1:2
            if (j==1)
                vi = find( (d(i).x_fit<max(p.x_ticks)) & ...
                        (d(i).x_fit>(p.x_break_point+p.x_break_spacing)));
            else
                vi = find( (d(i).x_fit<(p.x_break_point-p.x_break_spacing)) & ...
                        (d(i).x_fit>min(p.x_ticks)));
            end
            
            if (isempty(vi))
                % Deals with special case where there are no points
                % in a part of the curve
                continue;
            end

            h_line(i) = plot(p.axis_handle,d(i).x_fit(vi),d(i).y_fit(vi),'-', ...
                'LineWidth',p.fit_line_width, ...
                'Color',p.fit_line_colors(i,:));
        end
    end
    for i=numel(d):-1:1
        uistack(h_line(i),'bottom');
    end
end

% Generate x_tick_labels
for i=1:length(p.x_ticks)
    format_string = sprintf('%%.%.0ff',p.x_tick_decimal_places);
    
    if (p.x_ticks(i)==p.pCa90_replacement_value)
        x_tick_labels{i}=sprintf(format_string,p.high_pCa_value);
    else
        x_tick_labels{i}=sprintf(format_string,p.x_ticks(i));
    end
end

axes_data = improve_axes(...
    'axis_handle',p.axis_handle, ...
    'x_ticks',p.x_ticks, ...
    'x_tick_label_positions',p.x_ticks, ...
    'x_tick_labels',x_tick_labels, ...
    'x_axis_label','pCa', ...
    'x_label_offset',p.x_label_offset, ...
    'y_axis_label',p.y_axis_label, ...
    'label_font_size',p.label_font_size, ...
    'tick_font_size',p.tick_font_size, ...
    'y_label_offset',p.y_label_offset, ...
    'y_axis_offset',p.y_axis_offset, ...
    'y_tick_label_horizontal_offset',p.y_tick_label_horizontal_offset, ...
    'y_tick_decimal_places',p.y_tick_decimal_places, ......
    'y_ticks',p.y_ticks, ...
    'x_tick_length',p.x_tick_length, ...
    'y_tick_length',p.y_tick_length, ...
    'title',p.title, ...
    'title_y_offset',p.title_y_offset, ...
    'title_font_weight',p.title_font_weight, ...
    'title_text_interpreter',p.title_text_interpreter, ...
    'gui_scale_factor',p.gui_scale_factor, ...
    'x_axis_offset',p.x_axis_offset, ...
    'x_axis_off',p.x_axis_off, ...
    'y_axis_off',p.y_axis_off);

% Add in a break
if (p.x_break_point<max(p.x_ticks))
    xb=p.x_break_point+p.x_break_width*[1 -1];
    yb_axis=p.x_break_rel_height*(max(p.y_ticks)-min(p.y_ticks))*[-1 1];
    % yb_data=yb_axis+mean(pCa90_y_values);
    % Draw over the axis
    plot(p.axis_handle,p.x_break_point+[0 p.x_break_spacing], ...
        axes_data.x_axis_y_location*[1 1], ...
        'w-','LineWidth',axes_data.axis_line_width+1);
    % Now draw lines
    for i=1:2
        plot(p.axis_handle,xb,yb_axis + axes_data.x_axis_y_location, ...
                'k-','LineWidth',p.x_break_line_width);
    %     if (p.draw_data_break)
    %         plot(xb,yb_data, ...
    %             'k-','LineWidth',params.x_break_line_width);
    %     end
        xb=xb+p.x_break_spacing;
    end
end
