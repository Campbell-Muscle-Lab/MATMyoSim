function generate_length_control_pCa_protocol(varargin)

p = inputParser;
addOptional(p, 'time_step', 0.001);
addOptional(p, 'no_of_points', 2000);
addOptional(p, 't_start_s', 0.1);
addOptional(p, 't_stop_s', 1.5);
addOptional(p, 'pre_pCa', 9.0);
addOptional(p, 'during_pCa', 4.5);
addOptional(p, 'dhsl', []);
addOptional(p, 'mode_vector', []);
addOptional(p,'output_file_string','protocol\isometric_pCa.txt');
parse(p,varargin{:});
p=p.Results;

% Code
output.dt = p.time_step * ones(p.no_of_points,1);

if (isempty(p.mode_vector))
    output.Mode = -2 * ones(p.no_of_points,1);
else
    output.Mode = p.mode_vector;
end

if (isempty(p.dhsl))
    output.dhsl = zeros(p.no_of_points,1);
else
    output.dhsl = p.dhsl;
end

% Generate pCa profile
t = cumsum(output.dt);
output.pCa = p.pre_pCa * ones(p.no_of_points,1);
output.pCa(t > p.t_start_s) = p.during_pCa;
output.pCa(t > p.t_stop_s) = p.pre_pCa;

% Output
output_table = struct2table(output);
parent_dir = fileparts(p.output_file_string);
if (~isfolder(parent_dir))
    mkdir(parent_dir);
end
try
    delete(p.output_file_sring);
end
writetable(output_table,p.output_file_string,'delimiter','\t');
