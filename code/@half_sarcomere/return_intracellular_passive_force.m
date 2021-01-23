function pf = return_intracellular_passive_force(obj,hsl)
% Function returns passive force

switch (obj.parameters.passive_force_mode)
    case 'linear'
        pf = obj.parameters.passive_k_linear * ...
            (hsl - obj.parameters.passive_hsl_slack);
    case 'exponential'
        if (hsl> obj.parameters.passive_hsl_slack)
            pf = obj.parameters.passive_sigma * ...
                    (exp((hsl - obj.parameters.passive_hsl_slack)/ ...
                        obj.parameters.passive_L)-1);
        else
            pf = -obj.parameters.passive_sigma * ...
                    (exp(-(hsl - obj.parameters.passive_hsl_slack)/ ...
                        obj.parameters.passive_L)-1);
        end
    otherwise
        error('Passive force mode not defined');
end

% Adapt for intracellular proportion
pf = obj.parameters.intracellular_passive_proportion * pf;
        
        
