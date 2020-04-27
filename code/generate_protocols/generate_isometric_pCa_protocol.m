function generate_isometric_pCa_protocol(varargin)

p = inputParser;
addOptional(p,'time_step',0.001);
addOptional(p,'no_of_points',2000);
addOptional(p,'output_file_string','protocol\isometric_pCa.txt');
addOptional(p,'pCa',9.0);
parse(p,varargin{:});
p=p.Results;

% Code
output.dt = p.time_step * ones(p.no_of_points,1);
output.Mode = -2 * ones(p.no_of_points,1);
output.dhsl = zeros(p.no_of_points,1);
output.pCa = p.pCa * ones(p.no_of_points,1);

% Output
output_table = struct2table(output);
writetable(output_table,p.output_file_string,'delimiter','\t');
