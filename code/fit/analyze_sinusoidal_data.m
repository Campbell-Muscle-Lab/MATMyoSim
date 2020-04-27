function [freq,elastic_mod,viscous_mod,r_squared] = ...
    analyze_sinusoidal_data(t,x,f,hsl,varargin);

p = inputParser;
p.addParamValue('no_of_frequencies',[]);
p.addParamValue('no_of_cycles',3);
p.addParamValue('first_analysis_cycle',2);
p.addParamValue('figure_raw',21);
p.addParamValue('figure_peaks',22);
p.addParamValue('figure_segment',23);
p.addParamValue('figure_fit',12);
p.addParamValue('figure_nyquist',0);
p.addParamValue('export_fit_images',0);
parse(p,varargin{:});
p = p.Results;

% Display raw figure if required
if (p.figure_raw>0)
    figure(p.figure_raw);
    clf;
    subplot(2,1,1);
    hold on;
    h(1)=plot(t,x,'b-');
    h(2)=plot(t,hsl,'b:');
    legend(h,{'ML','HSL'});    
    subplot(2,1,2);
    plot(t,f,'b-');
end

% Find peaks
vi = peakfinder(x,0.25*(max(x)-min(x)),mean(x)+0.25*(max(x)-min(x)), ...
    1,false,false);
vi = round(vi);

if (p.figure_peaks)
    figure(p.figure_peaks)
    clf;
    plot(t,x,'b-');
    hold on;
    plot(t(vi),x(vi),'go');
end

% Cycle through frequencies
for fc = 1:p.no_of_frequencies
    
    % Estimate the beginning and end of the burst using the peaks
    first_peak_i = vi((fc-1)*p.no_of_cycles+1);
    last_peak_i = vi(fc*p.no_of_cycles);
    inter_peak_i = (last_peak_i - first_peak_i)/(p.no_of_cycles-1);
    
    begin_i = round(first_peak_i - 0.25*inter_peak_i)+1;
    last_i = round(last_peak_i + 0.75*inter_peak_i);
    
    vi_segment = begin_i:last_i;
    
    % Find the first index when the strain value is close to 1
    ai = round(((p.first_analysis_cycle-1)*inter_peak_i) : ...
            numel(vi_segment));
    ds = abs(x(vi_segment)/x(1) - 1);
    
    analysis_i = ...
        round(((p.first_analysis_cycle-1)*inter_peak_i) : ...
            numel(vi_segment));
    
    t_segment = t(vi_segment);
    x_segment = x(vi_segment);
    hsl_segment = hsl(vi_segment);
    strain_segment = x_segment ./ x(1);
    f_segment = f(vi_segment);
    
    if (p.figure_segment>0)
        figure(p.figure_segment)
        set(gcf,'Name','Selecting data to analyze');
        clf;
        subplot(4,1,1);
        hold on;
        h(1)=plot(t_segment,x_segment,'b-');
        h(2)=plot(t_segment,hsl_segment,'b:');
        ylabel('Length (nm)');
        legend(h,{'ML','HSL'});
        subplot(4,1,2);
        hold on;
        plot(t_segment,strain_segment,'b-');
        plot(t_segment(analysis_i(1)),strain_segment(analysis_i(1)),'go');
        ylabel('Strain');
        subplot(4,1,3);
        hold on;
        plot(t_segment,f_segment,'b-');
        plot(t_segment(analysis_i(1)),f_segment(analysis_i(1)),'go');
        ylabel('Stress (kN m^{-2})');
        xlabel('Time (s)');
        subplot(4,1,4);
        hold on;
        plot(strain_segment,f_segment,'b-');
        plot(strain_segment(analysis_i),f_segment(analysis_i),'g-');
        ylabel('Stress (kN m^{-2})');
        xlabel('Strain');
    end
    
    % Analysis
    time_analysis = t_segment(analysis_i)-t_segment(analysis_i(1));
    strain = strain_segment(analysis_i);
    max_strain(fc) = max(strain);
    stress = f_segment(analysis_i);
    est_freq = 1/(time_analysis(round(inter_peak_i)))
    
    [sin_mag(fc),cos_mag(fc),freq(fc),r_squared(fc),x_fit{fc},y_fit{fc}] = ...
        fit_sin_plus_cos(time_analysis,stress,est_freq);
    
    if (p.figure_fit>0)
        figure(p.figure_fit);
        clf;
        subplot(3,1,1);
        plot(time_analysis,strain,'b-');
        subplot(3,1,2);
        hold on;
        plot(time_analysis,stress,'b-');
        plot(x_fit{fc},y_fit{fc},'r-');
        subplot(3,1,3);
        hold on;
        plot(strain,stress,'b-');
        plot(strain,y_fit{fc},'r-');
        
        drawnow;

        x_lim = xlim;
        y_lim = ylim;
        text(x_lim(1),y_lim(2),sprintf('r sq = %.3f',r_squared(fc)), ...
            'HorizontalAlignment','left', ...
            'VerticalAlignment','top');
        ofs = sprintf('c:\\temp\\test_fit_%.0f',fc);
        if (p.export_fit_images)
            figure_export('output_file_string',ofs, ...
                'output_type','png', ...
                'dpi',50);
        end
    end
end

% Correct for strains
elastic_mod = sin_mag ./ (max_strain-1);
viscous_mod = cos_mag ./ (max_strain-1);
    
if (p.figure_nyquist>0)
    figure(p.figure_nyquist);
    clf;
    
    subplot(3,1,1);
    plot(log10(freq),elastic_mod,'bo')
    xlabel('log_{10} ( Frequency (Hz) )');
    ylabel({'Elastic','Modulus','(N m^{-2})'});
    
    subplot(3,1,2);
    plot(log10(freq),viscous_mod,'bo');
    xlabel('log_{10} ( Frequency (Hz) )');
    ylabel({'Viscous','Modulus','(N m^{-2})'});
    
    subplot(3,1,3);
    hold on;
    plot(elastic_mod,viscous_mod,'bo');
    for i=1:numel(elastic_mod)
        text(elastic_mod(i),viscous_mod(i),sprintf('%.1f',freq(i)));
    end
    xlabel('Elastic modulus (N m^{-2})');
    ylabel('Viscous modulus (N m^{-2})');
end
