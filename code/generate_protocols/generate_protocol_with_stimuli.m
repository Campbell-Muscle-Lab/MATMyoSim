function generate_protocol_with_stimuli(varargin)
% Function generates a protocol with Ca transients defined by a simple
% two compartment model. If input delta_half_sarcomere_length is empty,
% the protocol is isometric, otherwise, it defines the
% delta half-sarcomere length change imposed on the system at each
% time-step

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
addOptional(p,'dhsl',[]);
addOptional(p,'mode',[]);
parse(p,varargin{:});
p=p.Results;

% Generate activation pattern - this is used to create the Ca pattern
activation = zeros(p.no_of_points,1);
for i=1:numel(p.stimulus_times)
    start_index = round(p.stimulus_times(i)/p.time_step);
    stop_index = round((p.stimulus_times(i)+p.stimulus_duration)/p.time_step);
    activation(start_index:stop_index)=1;
end
activation(activation<0)=0;
activation(activation>1)=1;

% Solve 2 compartment differential equation to give fake calcium transients
y=[1e-9 p.Ca_content];
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
if (isempty(p.mode))
    output.Mode = -2 * ones(p.no_of_points,1);
else
    output.Mode = p.mode;
end

% Generate dhsl
if (isempty(p.dhsl))
    output.dhsl = zeros(p.no_of_points,1);
else
    output.dhsl = p.dhsl;
end

% Generate pCa
output.pCa = pCa_trace;

% Output
output_table = struct2table(output);
writetable(output_table,p.output_file_string,'delimiter','\t');

end