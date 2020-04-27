function generate_isometric_stimulus_protocol(varargin)
% Function generates in isometric stimulus protocol

p = inputParser;
addOptional(p,'time_step',0.001);
addOptional(p,'output_file_string','protocol\isometric_stimulus.txt');
addOptional(p,'no_of_points',2000);
addOptional(p,'stimulus_times',[0.1 0.4 0.7 0.85 1.0:0.05:1.4]);
addOptional(p,'stimulus_duration',0.03);
addOptional(p,'Ca_content',1e-3);
addOptional(p,'k_leak',2e-2);
addOptional(p,'k_act',3e-1);
addOptional(p,'k_serca',20);
parse(p,varargin{:});
p=p.Results;

% Generate activation pattern
activation = zeros(p.no_of_points,1);
for i=1:numel(p.stimulus_times)
    start_index = round(p.stimulus_times(i)/p.time_step);
    stop_index = round((p.stimulus_times(i)+p.stimulus_duration)/p.time_step);
    activation(start_index:stop_index)=1;
end
activation(activation>1)=1;

% Solve 2 compartment differential equation to give fake calcium transients
y=[0 p.Ca_content];
for i=2:p.no_of_points
    act = activation(i);
    [t,y_temp]=ode45(@derivs,[0 p.time_step],y(i-1,:));
    y(i,:) = y_temp(end,:);
end
pCa_trace = -log10(y(:,1));

    function dydt = derivs(t,y)
        dydt=zeros(2,1);
        dydt(1) = (p.k_leak + act * p.k_act)*y(2) - p.k_serca*y(1);
        dydt(2) = -dydt(1);
    end

% Generate the rest of the protocol

% Generate dt
output.dt = p.time_step * ones(p.no_of_points,1);

% Generate mode
output.Mode = -2 * ones(p.no_of_points,1);

% Generate dhsl
output.dhsl = zeros(p.no_of_points,1);

% Generate pCa
output.pCa = pCa_trace;

% Output
output_table = struct2table(output);
writetable(output_table,p.output_file_string,'delimiter','\t');

end