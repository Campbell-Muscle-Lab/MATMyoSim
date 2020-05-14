function out = process_SLControl_file_to_MATLAB_MyoSim(slc_file_string,varargin)
% Takes a SLControl data file and generates a protocol file

p = inputParser;
addRequired(p,'slc_file_string');
addOptional(p,'transform_slcontrol_record_mode',1);
addOptional(p,'protocol_file_string',[]);
addOptional(p,'target_file_string',[]);
addOptional(p,'target_value','force');
addOptional(p,'start_time_s',0);
addOptional(p,'stop_time_s',[]);
addOptional(p,'t_inc',0.001);
addOptional(p,'smooth_fl_points',0);
addOptional(p,'pre_points',100);
addOptional(p,'pCa',[]);
addOptional(p,'figure_number',0);
addOptional(p,'force_gain',1);
parse(p, slc_file_string, varargin{:});
p = p.Results;

% Code

% Load file
td = transform_slcontrol_record(load_slcontrol_file( ...
        p.slc_file_string), ...
        p.transform_slcontrol_record_mode);
    
% Adjust for force gain
td.force = td.force / td.force_gain;
    
% Some defaults
if (isempty(p.stop_time_s))
    p.stop_time_s = td.time(end);
end
   
% Interpolate to t_inc
slc_dt = diff(td.time);
slc_dt = slc_dt(1);
if (~isequal(slc_dt,p.t_inc))
    new_time = 0:p.t_inc:td.time(end);
    td.force = interp1(td.time,td.force,new_time)';
    td.fl = interp1(td.time,td.force,new_time)';
    td.time = new_time';
end

% Smooth fl
if (p.smooth_fl_points>0)
    td.fl = smoothdata(td.fl,'movmean',p.smooth_fl_points);
end

% Find index points
ti = find(td.time > p.start_time_s,1,'first') : ...
            find(td.time < p.stop_time_s,1,'last');
        
% Save force
out.force = td.force(ti);

% Generate protocol_file
if (~isempty(p.protocol_file_string))
    
    % Generate protocol
    dt = p.t_inc * ones(numel(ti),1);

    % Generate mode_vectpr
    Mode = -2*ones(numel(ti),1);
    
    % Generate dhsl
    normalized_fl = td.fl(ti)./td.fl(ti(1));
    diff_normalized_fl = diff(normalized_fl);
    diff_normalized_fl = [0 ; diff_normalized_fl];
    dhsl = 0.5 * 1e9 * td.sarcomere_length * diff_normalized_fl;
    
    % Generate pCa
    pCa = td.pCa * ones(numel(ti),1);
    
    % Generate pre_data
    if (~isempty(p.pre_points))
        dt = [p.t_inc * ones(p.pre_points,1) ; dt];
        Mode = [-2 * ones(p.pre_points,1) ; Mode];
        dhsl = [zeros(p.pre_points,1) ; dhsl];
        pCa = [td.pCa * ones(p.pre_points,1) ; pCa];
    end
    
    % Write file
    writetable(table(dt,Mode,dhsl,pCa),p.protocol_file_string, ...
        'delimiter','\t');
    
    % Write target
    if (~isempty(p.target_file_string) && strcmp(p.target_value,'force'))
       writematrix(out.force, p.target_file_string,'Delimiter','tab');
    end
end
    
    
% Display if required
if (p.figure_number)
    figure(p.figure_number);
    clf;
    r=5;
    c=1;
    
    t_disp = (p.pre_points * p.t_inc) + td.time(ti) - td.time(ti(1));
    
    subplot(r,c,1);
    plot(t_disp, td.force(ti), 'b-');
    ylabel('Force');
    xlim([0 max(t_disp)]);
    
    subplot(r,c,2);
    plot(t_disp, td.fl(ti), 'b-');
    ylabel('FL');
    xlim([0 max(t_disp)]);
    
    subplot(r,c,3);
    plot(cumsum(dt), cumsum(dhsl), 'b-');
    ylabel('cumsum(dhsl)');
    xlim([0 sum(dt)]);

    subplot(r,c,4);
    plot(t_disp, out.force, 'b-');
    ylabel('target');
    xlim([0 sum(dt)]);
end
