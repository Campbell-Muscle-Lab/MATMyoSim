function move_cb_distribution(obj,delta_hsl)

% Adjust for filament compliance
delta_x = delta_hsl * obj.parameters.compliance_factor;

% Shift populations by interpolation
flag = 1;

if (startsWith(obj.kinetic_scheme, '2state'))
    flag = 0;
    interp_positions = obj.myofilaments.x - delta_x;
    bin_indices = 1+(1:obj.myofilaments.no_of_x_bins);
    cbs_bound_before = sum(obj.myofilaments.y(bin_indices));
    obj.myofilaments.y(bin_indices) = ...
        interp1(obj.myofilaments.x,obj.myofilaments.y(bin_indices), ...
            interp_positions, ...
            'linear',0)';
    % Try to manage cbs ripped off filaments
    cbs_lost = cbs_bound_before - sum(obj.myofilaments.y(bin_indices));
    if (cbs_lost > 0)
        obj.myofilaments.y(1) = obj.myofilaments.y(1) + cbs_lost;
    end
end

if (startsWith(obj.kinetic_scheme, '3state_with_SRX'))
    flag = 0;
    interp_positions = obj.myofilaments.x - delta_x;
    bin_indices = 2+(1:obj.myofilaments.no_of_x_bins);
    cbs_bound_before = sum(obj.myofilaments.y(bin_indices));
    obj.myofilaments.y(bin_indices) = ...
        interp1(obj.myofilaments.x,obj.myofilaments.y(bin_indices), ...
            interp_positions, ...
            'linear',0)';
    % Try to manage cbs ripped off filaments
    cbs_lost = cbs_bound_before - sum(obj.myofilaments.y(bin_indices));
    if (cbs_lost > 1e-5)
        disp('Warning - rapid cross-bridge movement');
        obj.myofilaments.y(2) = obj.myofilaments.y(2) + cbs_lost;
    end
end

if (startsWith(obj.kinetic_scheme, '4state_with_SRX'))
    flag = 0;
    interp_positions = obj.myofilaments.x - delta_x;

    M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
    M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
        (1:obj.myofilaments.no_of_x_bins);
    
    cbs_bound_before = sum(obj.myofilaments.y(M3_indices)) + ...
        sum(obj.myofilaments.y(M4_indices));

    obj.myofilaments.y(M3_indices) = ...
        interp1(obj.myofilaments.x,obj.myofilaments.y(M3_indices), ...
            interp_positions, ...
            'linear',0)';            
    obj.myofilaments.y(M4_indices) = ...
        interp1(obj.myofilaments.x,obj.myofilaments.y(M4_indices), ...
            interp_positions, ...
            'linear',0)';            

    % Try to manage cbs ripped off filaments
    cbs_lost = cbs_bound_before - sum(obj.myofilaments.y(M3_indices)) - ...
                    sum(obj.myofilaments.y(M4_indices));
    if (cbs_lost > 1e-5)
        disp('Warning - rapid cross-bridge movement');
        obj.myofilaments.y(2) = obj.myofilaments.y(2) + cbs_lost;
    end
end

if (flag==1)
    error(sprintf( ...
        '%s kinetics scheme not yet implemented in move_cb_distributions'));
end
