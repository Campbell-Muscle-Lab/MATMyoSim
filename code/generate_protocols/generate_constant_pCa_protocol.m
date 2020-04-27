function generate_constant_pCa_protocol(varargin)

p = inputParser;
addOptional(p,'time_step',0.001);
addOptional(p,'output_file_string','protocol\constant_pCa.txt');
addOptional(p,'pCa',9.0);
parse(p,varargin{:});
p=p.Results;

% Generate hsl
output.dhsl = zeros(round(p.pre_first_triangle_s/p.time_step),1);
for i=1:p.no_of_triangles
    no_of_triangle_steps = (p.triangle_rise_time_s / p.time_step)
    dx = p.triangle_nm / no_of_triangle_steps
    output.dhsl = [output.dhsl ; dx * ones(no_of_triangle_steps,1)];
    output.dhsl = [output.dhsl ; -dx * ones(no_of_triangle_steps,1)];
    if (i<p.no_of_triangles)
        output.dhsl = [output.dhsl ; zeros(round(p.inter_triangle_s / p.time_step),1)];
    end
end

% Generate dt
output.dt = p.time_step * ones(numel(output.dhsl),1);

% Generate mode
output.Mode = -2 * ones(numel(output.dhsl),1);

% Generate pCa
output.pCa = p.initial_pCa * ones(numel(output.dhsl),1);
output.pCa(cumsum(output.dt)>p.pre_Ca_s) = p.activating_pCa;

% Output
output_table = struct2table(output);
writetable(output_table,p.output_file_string,'delimiter','\t');
