function [x0,a,b,r_squared,x_fit,y_fit]= ...
    fit_hyperbola(varargin)
% Fits a curve of the form
% (x+a)(y+b)=(xo+a)*b

% Defaults
params.x_data=[];
params.y_data=[];
params.x0_guess=[];
params.a_guess=[];
params.b_guess=[];
params.x0_min=[];
params.x0_max=[];
params.x_fit=[];
params.figure_display=0;

% Update
params=parse_pv_pairs(params,varargin);

% Some defaults
if (isempty(params.x_fit))
    params.x_fit = linspace(min(params.x_data),max(params.x_data),100);
end

% Deduce some starting values
if (isempty(params.x0_guess))
    params.x0_guess=max(params.x_data);
end

if (isempty(params.a_guess))
    params.a_guess = 0.2*max(params.x_data);
end

if (isempty(params.b_guess))
    params.b_guess = 0.1;
end

if (isempty(params.x0_min))
    lower_bounds=[0 min(params.x_data)+eps 1e-2];
else
    lower_bounds=[params.x0_min min(params.x_data)+eps 1e-2];
end
if (isempty(params.x0_max))
    upper_bounds=Inf*ones(3,1);
else
    upper_bounds=[params.x0_max Inf Inf];
end

% Set p
p = [params.x0_guess params.a_guess params.b_guess];

[p,~,status]=fminsearchbnd(@hyperbola_error, ...
    p, ...
    lower_bounds, upper_bounds, ...
    optimset('MaxFunEvals',5000), ...
    params.x_data,params.y_data,params.figure_display);

% Calculate y_fit
x0=p(1);
a=p(2);
b=p(3);
y_fit=(((x0+a).*b)./(params.x_data+a))-b;
r_squared=calculate_r_squared(params.y_data,y_fit);
x_fit = params.x_fit;

% Calculate fit curve
for i=1:length(x_fit)
    y_fit(i)=(((x0+a).*b)./(x_fit(i)+a))-b;
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sub-function

function error_value=hyperbola_error(p,x,y,figure_display)

    y_fit=(((p(1)+p(2)).*p(3))./(x+p(2)))-p(3);
    error_value=sum((y-y_fit).^2);

    if (figure_display)
        figure(figure_display);
        clf;
        plot(x,y,'bo');
        hold on;
        x_plot=linspace(min(x),max(x),100);
        y_plot=(((p(1)+p(2)).*p(3))./(x_plot+p(2)))-p(3);
        plot(x_plot,y_plot,'r-');
    end
end

