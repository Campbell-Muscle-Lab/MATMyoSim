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
    obj.myofilaments.y(1) = obj.myofilaments.y(1) + cbs_lost;
    if (abs(cbs_lost) > 1e-5)
        disp(sprintf('Warning - %.5f cbs lost during movement', cbs_lost))
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
    obj.myofilaments.y(2) = obj.myofilaments.y(2) + cbs_lost;
%     if (abs(cbs_lost) > 1e-5)
%         disp(sprintf('Warning - %.5f cbs lost during movement', cbs_lost))
%     end
end

% Handle m_3state_with_SRX_mybpc_2state
if (strcmp(obj.kinetic_scheme, 'm_3state_with_SRX_mybpc_2state'))
    flag = 0;
    interp_positions = obj.myofilaments.x - delta_x;
    m_bin_indices = 2 + (1:obj.myofilaments.no_of_x_bins);
    c_bin_indices = 5 + obj.myofilaments.no_of_x_bins + ...
        (1:obj.myofilaments.no_of_x_bins);
    m_bound_before = sum(obj.myofilaments.y(m_bin_indices));
    c_bound_before = sum(obj.myofilaments.y(c_bin_indices));
    
    % Interpolate
    obj.myofilaments.y(m_bin_indices) = ...
        interp1(obj.myofilaments.x, obj.myofilaments.y(m_bin_indices), ...
                interp_positions, ...
                'linear', 0)';
    obj.myofilaments.y(c_bin_indices) = ...
        interp1(obj.myofilaments.x, obj.myofilaments.y(c_bin_indices), ...
                inter_positions, ...
                'linear', 0)';
            
    % Try to manage cbs and mybpc ripped off
    m_lost = m_bound_before - sum(obj.myofilaments.y(m_bin_indices));
    obj.myofilaments.y(2) = obj.myofilaments.y(2) + m_lost;
    
    c_lost = c_bound_before - sum(obj.myofilaments.y(c_bin_indices));
    obj.myofilaments.y(5 + obj.myofilaments.no_of_x_bins) = ...
        obj.myofilaments.y(5 + obj.myofilaments.no_of_x_bins) + c_lost;
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
    obj.myofilaments.y(2) = obj.myofilaments.y(2) + cbs_lost;                
%     if (abs(cbs_lost) > 1e-5)
%         disp(sprintf('Warning - %.5f cbs lost during movement', cbs_lost))
%     end
end

if (startsWith(obj.kinetic_scheme, '6state_with_SRX'))
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
    obj.myofilaments.y(2) = obj.myofilaments.y(2) + cbs_lost;                
%     if (abs(cbs_lost) > 1e-5)
%         disp(sprintf('Warning - %.5f cbs lost during movement', cbs_lost))
%     end
end

if (startsWith(obj.kinetic_scheme, '7state_with_SRX'))
    flag = 0;
    interp_positions = obj.myofilaments.x - delta_x;

    M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
    M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
        (1:obj.myofilaments.no_of_x_bins);
    M5_indices = (2+(2*obj.myofilaments.no_of_x_bins)) + ...
        (1:obj.myofilaments.no_of_x_bins);
    
    cbs_bound_before = sum(obj.myofilaments.y(M3_indices)) + ...
        sum(obj.myofilaments.y(M4_indices)) + ...
        sum(obj.myofilaments.y(M5_indices));

    obj.myofilaments.y(M3_indices) = ...
        interp1(obj.myofilaments.x,obj.myofilaments.y(M3_indices), ...
            interp_positions, ...
            'linear',0)';            
    obj.myofilaments.y(M4_indices) = ...
        interp1(obj.myofilaments.x,obj.myofilaments.y(M4_indices), ...
            interp_positions, ...
            'linear',0)';
    obj.myofilaments.y(M5_indices) = ...
        interp1(obj.myofilaments.x,obj.myofilaments.y(M5_indices), ...
            interp_positions, ...
            'linear',0)';                    

    % Try to manage cbs ripped off filaments
    cbs_lost = cbs_bound_before - sum(obj.myofilaments.y(M3_indices)) - ...
                    sum(obj.myofilaments.y(M4_indices)) - ...
                    sum(obj.myofilaments.y(M5_indices));
    obj.myofilaments.y(2) = obj.myofilaments.y(2) + cbs_lost;                
%     if (abs(cbs_lost) > 1e-5)
%         disp(sprintf('Warning - %.5f cbs lost during movement', cbs_lost))
%     end
end

if (flag==1)
    error(sprintf( ...
        '%s kinetics scheme not yet implemented in move_cb_distributions'));
end
