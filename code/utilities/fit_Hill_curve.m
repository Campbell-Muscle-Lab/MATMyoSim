function [pCa50,n,min_value,amplitude,r_squared,x_fit,y_fit]= ...
    fit_Hill_curve(x_data,y_data,varargin)
% Fits Hill curve to data with some options

% Defaults
params.x_fit = [];
params.p = [];
params.constrain_min_y_to_zero = 0;
params.figure_number = 0;

% Update
params = parse_pv_pairs(params,varargin);

% Some defaults
if (isempty(params.x_fit))
    params.x_fit = linspace(min(x_data),max(x_data),100);
end

% Screen for NaNs
x_data = x_data(find(~isnan(y_data)));
y_data = y_data(find(~isnan(y_data)));

% Initial guess
p = params.p;

% Set some defaults
if (isempty(p))
    p(1) = min(y_data);
    p(2) = max(y_data)-min(y_data);
    p(3) = 6;
    p(4) = 2;
    
    % Attempt to correct for y decreasing with Ca
    [x_sort,si] = sort(x_data);
    y_sort = y_data(si);
    if (y_sort(1)<y_sort(end))
        p(1) = max(y_data);
        p(2) = min(y_data)-max(y_data);
    end
end

% Fit
p=fminsearch(@return_hill_curve_error,p,[],x_data,y_data, ...
    params.constrain_min_y_to_zero, ...
    params.figure_number);

% Store data
min_value = p(1);
amplitude = p(2);
pCa50 = p(3);
n = p(4);

y_calculated = hill_curve_function(p,x_data,params.constrain_min_y_to_zero);
r_squared = calculate_r_squared(y_calculated,y_data);
x_fit = params.x_fit;
y_fit = hill_curve_function(p,params.x_fit,params.constrain_min_y_to_zero);

% Display if required
if (params.figure_number)
    figure(params.figure_number)
    clf;
    hold on;
    plot(x_data,y_data,'bo');
    plot(x_fit,y_fit,'r-');
    set(gca,'XDir','reverse');
    x_limits = xlim;
    text(x_limits(end),0.6*mean(ylim),sprintf('n=%.3f',n));
    text(x_limits(end),0.4*mean(ylim),sprintf('pCa_{50}=%.3f',pCa50));
end


end

function e = return_hill_curve_error(p,x_data,y_data, ...
        constrain_min_y_to_zero,figure_number)
    
    y_fit = hill_curve_function(p,x_data,constrain_min_y_to_zero);
    
    if (size(y_fit)~=size(y_data))
        y_fit = y_fit';
    end
    e = sum((y_fit-y_data).^2);
    
    if (figure_number>0)
        figure(figure_number)
        clf;
        hold on;
        plot(x_data,y_data,'bo');
        plot(x_data,y_fit,'r-');
        set(gca,'XDir','reverse');
        x_limits = xlim;
%         drawnow;
    end
    
end

function y = hill_curve_function(p,x,constrain_min_y_to_zero)

    if (constrain_min_y_to_zero)
        p(1) = 0;
    end

    for i=1:numel(x)
        y(i) = p(1) + p(2)*((10^-x(i))^p(4)) / ...
            (((10^-x(i))^p(4)) + ((10^-p(3))^p(4)));
    end
end
