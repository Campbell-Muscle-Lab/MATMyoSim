function draw_rates(obj, varargin)

if (obj.myosim_options.figure_rates>0)
    figure(obj.myosim_options.figure_rates);
    clf;
    
    if (startsWith(obj.myosim_model.hs_props.kinetic_scheme, ...
            '3state_with_SRX'))

        subplot(2,1,1);
        hold on;
        h(1) = plot(obj.m.hs(1).myofilaments.x, log10(obj.m.hs(1).rate_structure.r1 * ...
            ones(numel(obj.m.hs(1).myofilaments.x),1)), 'r-');
        h(2) = plot(obj.m.hs(1).myofilaments.x, log10(obj.m.hs(1).rate_structure.r2 * ...
            ones(numel(obj.m.hs(1).myofilaments.x),1)), 'b-');
        ylim([-1 4]);
        legend(h,{'k_1','k_2'});
        ylabel('log_{10} (Rates (s^{-1}))');

        subplot(2,1,2);
        hold on;
        h(1) = plot(obj.m.hs(1).myofilaments.x,log10(obj.m.hs(1).rate_structure.r3),'r-');
        h(2) = plot(obj.m.hs(1).myofilaments.x,log10(obj.m.hs(1).rate_structure.r4),'b-');
        ylim([-1 4]);
        legend(h,{'k_3','k_4'});
        ylabel('log_{10} (Rates (s^{-1}))');
        xlabel('Cross-bridge x (nm)');
    end
       
    if (startsWith(obj.myosim_model.hs_props.kinetic_scheme, ...
            '4state_with_SRX'))

        subplot(4,1,1);
        hold on;
        plot(obj.m.hs(1).myofilaments.x,log10(obj.m.hs(1).rate_structure.r1 * ...
            ones(numel(obj.m.hs(1).myofilaments.x),1)),'r-');
        plot(obj.m.hs(1).myofilaments.x,log10(obj.m.hs(1).rate_structure.r2 * ...
            ones(numel(obj.m.hs(1).myofilaments.x),1)),'b-');
        ylim([-1 4]);
        subplot(4,1,2);
        hold on;
        plot(obj.m.hs(1).myofilaments.x,log10(obj.m.hs(1).rate_structure.r3),'r-');
        plot(obj.m.hs(1).myofilaments.x,log10(obj.m.hs(1).rate_structure.r4),'b-');
        ylim([-1 4]);
        subplot(4,1,3);
        hold on;
        plot(obj.m.hs(1).myofilaments.x,log10(obj.m.hs(1).rate_structure.r5),'r-');
        plot(obj.m.hs(1).myofilaments.x,log10(obj.m.hs(1).rate_structure.r6),'b-');
        ylim([-1 4]);
        subplot(4,1,4);
        hold on;
        plot(obj.m.hs(1).myofilaments.x,log10(obj.m.hs(1).rate_structure.r7),'r-');
        plot(obj.m.hs(1).myofilaments.x,log10(obj.m.hs(1).rate_structure.r8),'b-');
        ylim([-1 4]);
    end
    
end
