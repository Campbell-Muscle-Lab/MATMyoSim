function [intra_pf, extra_pf] = return_passive_forces(obj,hsl)
% Function returns intracellular and and extracellular passive force

% Intracellular first
switch (obj.parameters.intra_passive_force_mode)
    case 'linear'
        intra_pf = obj.parameters.intra_passive_k_linear * ...
            (hsl - obj.parameters.intra_passive_hsl_slack);
    case 'exponential'
        if (hsl> obj.parameters.intra_passive_hsl_slack)
            intra_pf = obj.parameters.intra_passive_sigma * ...
                    (exp((hsl - obj.parameters.intra_passive_hsl_slack)/ ...
                        obj.parameters.intra_passive_L)-1);
        else
            intra_pf = -obj.parameters.intra_passive_sigma * ...
                    (exp(-(hsl - obj.parameters.intra_passive_hsl_slack)/ ...
                        obj.parameters.intra_passive_L)-1);
        end
    otherwise
        error('Intracellular passive force mode not defined');
end

% Extracellular first
switch (obj.parameters.extra_passive_force_mode)
    case 'linear'
        extra_pf = obj.parameters.extra_passive_k_linear * ...
            (hsl - obj.parameters.extra_passive_hsl_slack);
    case 'exponential'
        if (hsl> obj.parameters.extra_passive_hsl_slack)
            extra_pf = obj.parameters.extra_passive_sigma * ...
                    (exp((hsl - obj.parameters.extra_passive_hsl_slack)/ ...
                        obj.parameters.extra_passive_L)-1);
        else
            extra_pf = -obj.parameters.extra_passive_sigma * ...
                    (exp(-(hsl - obj.parameters.extra_passive_hsl_slack)/ ...
                        obj.parameters.extra_passive_L)-1);
        end
    otherwise
        error('Extracellular passive force mode not defined');
end
        
        
