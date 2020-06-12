function h=plot_with_error_bars(varargin)

params.axis_handle = [];

params.x_data=[];
params.x_limits=[];
params.y_data=[];
params.y_limits=[];

params.error_bar_line_width=1;
params.error_bar_colors=[0 0 0];
params.rel_error_bar_size=0.02;

params.marker_size=10;
params.marker_edge_colors=zeros(5,3);
params.marker_face_colors=[1 0 0; 0 1 0; 0 0 1; 0 1 1; 1 0 1];
params.marker_symbols={'o','s','v','^','d'};
params.marker_transparency = 0;

params.straight_join_style = 'none';
params.straight_join_line_width = 1;

params.display_factor=0.5;

% Update
params = parse_pv_pairs(params,varargin);

% Code
hold_status=ishold;
% Work out axis limits
if (length(params.x_limits)==0)
    % x_data
    x_min_holder=[];
    x_max_holder=[];
    for i=1:length(params.x_data)
        x_min_holder=[x_min_holder ; ...
            params.x_data(i).mean_values-params.x_data(i).error_values];
        x_max_holder=[x_max_holder ; ...
            params.x_data(i).mean_values+params.x_data(i).error_values];
    end
    
    x_limits=[min(x_min_holder(isfinite(x_min_holder))) ...
        max(x_max_holder(isfinite(x_min_holder)))];
else
    x_limits=params.x_limits;
end

if (length(params.y_limits)==0)
    % y_data
    y_min_holder=[];
    y_max_holder=[];
    for i=1:length(params.y_data)
        
y = params.y_data(1)        
yy = params.y_data(i).mean_values
yy2 = params.y_data(1).error_values
        
        y_min_holder=[y_min_holder ; ...
            params.y_data(i).mean_values-params.y_data(i).error_values];
        y_max_holder=[y_max_holder ; ...
            params.y_data(i).mean_values+params.y_data(i).error_values];
    end
    
    y_limits=[min(y_min_holder(isfinite(y_min_holder))) ...
        max(y_max_holder(isfinite(y_min_holder)))];
else
    y_limits=params.y_limits;
end

% Now plot the data

set(params.axis_handle,'XLimMode','manual');
xlim(params.axis_handle,x_limits);
set(params.axis_handle,'YLimMode','manual');
ylim(params.axis_handle,y_limits);
hold(params.axis_handle,'on');

% Hold vi
vi=[];

% Error bars first
for i=1:length(params.x_data)
    
    x_mean = params.x_data(i).mean_values;
    x_lhs = x_mean - params.x_data(i).error_values;
    x_rhs = x_mean + params.x_data(i).error_values;
    x_cap = params.rel_error_bar_size*diff(x_limits);
    x_plus = x_mean + x_cap;
    x_minus = x_mean - x_cap;
    
    y_mean = params.y_data(i).mean_values;
    y_top = y_mean + params.y_data(i).error_values;
    y_bottom = y_mean - params.y_data(i).error_values;
    y_cap = params.rel_error_bar_size*(diff(y_limits));
    y_plus = y_mean + y_cap;
    y_minus = y_mean - y_cap;
    
    % Find valid points
    vi=find(isfinite(x_lhs)&isfinite(y_top));
    holder(i).vi=vi;
    
    % Find line color
    [no_of_error_bar_colors,temp]=size(params.error_bar_colors);
    if (no_of_error_bar_colors>1)
        error_bar_color_index=mod(i,no_of_error_bar_colors);
        if (error_bar_color_index==0)
            error_bar_color_index=no_of_error_bar_colors;
        end
    else
        error_bar_color_index=1;
    end
    
    % Get the length of the x-axis in points
    current_units=get(params.axis_handle,'Units');
    set(params.axis_handle,'Units','points');
    position=get(params.axis_handle,'Position');
    x_axis_length_points=position(3);
    y_axis_length_points=position(4);
    set(params.axis_handle,'Units',current_units);
    
    x_marker_units = params.display_factor * ...
        (params.marker_size/x_axis_length_points)*diff(x_limits);
    y_marker_units = params.display_factor * ...
        (params.marker_size/y_axis_length_points)*diff(y_limits);

    % Draw the x bars one at a time
    for j=1:length(vi)
        if ((x_mean(vi(j))-x_lhs(vi(j)))> x_marker_units)
            plot(params.axis_handle, ...
                [x_lhs(vi(j)) x_mean(vi(j))-x_marker_units]', ...
                [y_mean(vi(j)) y_mean(vi(j))]','-', ...
                'Color',params.error_bar_colors(error_bar_color_index,:), ...
                'LineWidth',params.error_bar_line_width);

            plot(params.axis_handle, ...
                [x_mean(vi(j))+x_marker_units x_rhs(vi(j))]', ...
                [y_mean(vi(j)) y_mean(vi(j))]','-', ...
                'Color',params.error_bar_colors(error_bar_color_index,:), ...
                'LineWidth',params.error_bar_line_width);
            plot(params.axis_handle, ...
                [x_lhs(vi(j)) x_lhs(vi(j))]',[y_plus(vi(j)) y_minus(vi(j))]','-', ...
                'Color',params.error_bar_colors(error_bar_color_index,:), ...
                'LineWidth',params.error_bar_line_width);
            plot(params.axis_handle, ...
                [x_rhs(vi(j)) x_rhs(vi(j))]',[y_plus(vi(j)) y_minus(vi(j))]','-', ...
                'Color',params.error_bar_colors(error_bar_color_index,:), ...
                'LineWidth',params.error_bar_line_width);
        end
    
        if ((y_mean(vi(j))-y_bottom(vi(j)))>y_marker_units)

            plot(params.axis_handle, ...
                [x_mean(vi(j)) x_mean(vi(j))]', ...
                [y_top(vi(j)) y_mean(vi(j))+y_marker_units]','-', ...
                'Color',params.error_bar_colors(error_bar_color_index,:), ...
                'LineWidth',params.error_bar_line_width);
            plot(params.axis_handle, ...
                [x_mean(vi(j)) x_mean(vi(j))]', ...
                [y_bottom(vi(j)) y_mean(vi(j))-y_marker_units]','-', ...
                'Color',params.error_bar_colors(error_bar_color_index,:), ...
                'LineWidth',params.error_bar_line_width);
            plot(params.axis_handle, ...
                [x_minus(vi(j)) x_plus(vi(j))]',[y_top(vi(j)) y_top(vi(j))]','-', ...
                'Color',params.error_bar_colors(error_bar_color_index,:), ...
                'LineWidth',params.error_bar_line_width);
            plot(params.axis_handle, ...
                [x_minus(vi(j)) x_plus(vi(j))]',[y_bottom(vi(j)) y_bottom(vi(j))]','-', ...
                'Color',params.error_bar_colors(error_bar_color_index,:), ...
                'LineWidth',params.error_bar_line_width);
        end
    end
   
end
    
% Now plot markers
for i=1:length(params.x_data)
    % for i=1:0
    % Get data
    x_mean = params.x_data(i).mean_values;
    y_mean = params.y_data(i).mean_values;
    
    x_mean = x_mean(holder(i).vi);
    y_mean = y_mean(holder(i).vi);
    
    face_color=return_marker_face_color(i,params.marker_face_colors);

    set(gca,'Clipping','off')
    
    h(i)=plot(params.axis_handle, ...
        x_mean,y_mean, ...
        'Marker',params.marker_symbols{ ...
            return_marker_symbols_index(i,params.marker_symbols)}, ...
        'MarkerEdgeColor',params.marker_edge_colors( ...
            return_marker_edge_colors_index(i,params.marker_edge_colors),:), ...
        'MarkerFaceColor',face_color, ...
        'LineStyle','none', ...
        'MarkerSize',params.marker_size);
    
    if (~strcmp(params.straight_join_style,'none'))
        plot(x_mean,y_mean,'-','Color',params.marker_face_colors( ...
            return_marker_face_colors_index(i,params.marker_face_colors),:), ...
            'LineWidth',params.straight_join_line_width);
    end
        
end

% Reset axis status
if (~hold_status)
    hold(params.axis_handle,'off');
end

end


function marker_symbols_index=return_marker_symbols_index(i,marker_symbols)
    % Find marker symbol
    [temp,no_of_marker_symbols]=size(marker_symbols);
    if (no_of_marker_symbols>1)
        marker_symbols_index=mod(i,no_of_marker_symbols);
        if (marker_symbols_index==0)
            marker_symbols_index=no_of_marker_symbols;
        end
    else
        marker_symbols_index=1;
    end
end

function marker_edge_colors_index=return_marker_edge_colors_index( ...
    i,marker_edge_colors);

    % Find marker line color
    [no_of_marker_edge_colors,temp]=size(marker_edge_colors);
    if (no_of_marker_edge_colors>1)
        marker_edge_colors_index=mod(i,no_of_marker_edge_colors);
        if (marker_edge_colors_index==0)
            marker_edge_colors_index=no_of_marker_edge_colors;
        end
    else
        marker_edge_colors_index=1;
    end
end

function marker_color=return_marker_face_color(i,marker_face_colors)
    [no_of_marker_face_colors,~]=size(marker_face_colors);
    if (no_of_marker_face_colors>1)
        ii=mod(i,no_of_marker_face_colors);
        if (ii==0)
            marker_color=marker_face_colors(no_of_marker_face_colors,:);
        else
            marker_color=marker_face_colors(ii,:);
        end
    else
        marker_color=marker_face_colors(1,:);
    end
    if (any(~isfinite(marker_color)))
        marker_color='none';
    end
end

function marker_face_colors_index=return_marker_face_colors_index( ...
    i,marker_face_colors);

    % Find marker face color
    [no_of_marker_face_colors,temp]=size(marker_face_colors);
    if (no_of_marker_face_colors>1)
        marker_face_colors_index=mod(i,no_of_marker_face_colors);
        if (marker_face_colors_index==0)
            marker_face_colors_index=no_of_marker_face_colors;
        end
    else
        marker_face_colors_index=1;
    end
end