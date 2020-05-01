function [e, y_attempt] = evaluate_time_fit(sim_output,target_data,varargin)

p = inputParser;
p.addParamValue('figure_time_fit',0);
p.addParamValue('fit_variable','muscle_force');
parse(p,varargin{:});
p = p.Results;

% Pull off appropriate variable
switch p.fit_variable
    case 'muscle_force'
        y_attempt = sim_output.muscle_force;
    otherwise
        error('Invalid fit_variable');
end

% Sum of squares error for last part of simulation
target_stats = summary_stats(target_data);

if (target_stats.max == target_stats.min)
    error('target_data has no range');
end

e = sum(((y_attempt(end-target_stats.n+1:end) - target_data)./ ...
            (target_stats.max - target_stats.min)).^2) / ...
            target_stats.n;

% Plot result
if (p.figure_time_fit);
    figure(p.figure_time_fit);
    clf;
    hold on;
    plot(sim_output.time_s(end-target_stats.n+1:end),target_data,'k-');
    plot(sim_output.time_s,y_attempt,'b-');
    drawnow;
end