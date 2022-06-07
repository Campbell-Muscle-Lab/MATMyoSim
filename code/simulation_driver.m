function sim_output = simulation_driver(varargin)
% Runs a MyoSim simulation and returns a structure containing data

p = inputParser;
addOptional(p,'model_json_file_string',[]);
addOptional(p,'simulation_protocol_file_string',[]);
addOptional(p,'options_json_file_string',[]);
addOptional(p,'output_file_string',[]);
addOptional(p,'tag',[]);
parse(p,varargin{:});
p = p.Results;

% Create a simulation
myosim_simulation = simulation(p.model_json_file_string);

% Implement the protocol
myosim_simulation.implement_protocol( ...
    p.simulation_protocol_file_string, ...
    p.options_json_file_string);

% Add in a tag if required
if (~isempty(p.tag))
    myosim_simulation.sim_output.tag = p.tag;
end

% Set output
sim_output = myosim_simulation.sim_output;

% Save simulation_output
if (~isempty(p.output_file_string))
    % Check directory exists
    output_dir = fileparts(p.output_file_string);
    if (~isdir(output_dir))
        disp(sprintf('Creating output directory: %s', output_dir));
        [status, msg, msgID] = mkdir(output_dir);
    end
    save(p.output_file_string,'sim_output');
end
