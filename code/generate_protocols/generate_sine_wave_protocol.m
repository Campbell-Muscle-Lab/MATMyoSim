function generate_sine_wave_protocol(varargin)

p = inputParser;
addOptional(p,'time_step',0.001);
addOptional(p,'output_file_string','protocol\sinusoidal.txt');
addOptional(p,'dhsl_nm',2);
addOptional(p,'frequencies',[3 10 30 100]);
addOptional(p,'no_of_cycles',3);
addOptional(p,'pre_sinusoid_s',1);
addOptional(p,'inter_sinusoid_s',0.1);
addOptional(p,'pre_Ca_s',0.1);
addOptional(p,'initial_pCa',9.0);
addOptional(p,'activating_pCa',4.5);
parse(p,varargin{:});
p=p.Results;

% Generate hsl
hsl = zeros(round(p.pre_sinusoid_s/p.time_step),1);
for i=1:numel(p.frequencies)
    temp_t = p.time_step * (1:round((p.no_of_cycles / p.frequencies(i)) / p.time_step));
    hsl = [hsl ; p.dhsl_nm * sin(2 * pi * p.frequencies(i) * temp_t)'];
    if (i<numel(p.frequencies))
        hsl = [hsl ; zeros(round(p.inter_sinusoid_s / p.time_step),1)];
    end
end
output.dhsl = diff(hsl);

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





