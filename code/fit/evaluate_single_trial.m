function [e, sim_output, target_data] = evaluate_single_trial(varargin);

p = inputParser;
p.addParamValue('model_json_file_string','defaults\default_model.json');
p.addParamValue('simulation_protocol_file_string','defaults\default_protocol.txt');
p.addParamValue('options_file_string','defaults\default_options.xml');
p.addParamValue('output_file_string',[]);
p.addParamValue('fit_mode','Nyquist_fit');
p.addParamValue('fit_variable','muscle_force');
p.addParamValue('target_data',[]);
parse(p,varargin{:});
p = p.Results;

sim_output = simulation_driver( ...
    'model_json_file_string',p.model_json_file_string, ...
    'simulation_protocol_file_string',p.simulation_protocol_file_string, ...
    'options_file_string',p.options_file_string, ...
    'output_file_string',p.output_file_string);

switch (p.fit_mode)
    case 'Nyquist_fit'
        e = evaluate_Nyquist_fit(sim_output,p.target_data, ...
                'model_json_file_string',p.model_json_file_string);
    case 'time_fit'
        e = evaluate_time_fit(sim_output,p.target_data, ...
                'fit_variable',p.fit_variable);
    otherwise
end

% Return data
target_data = p.target_data;

