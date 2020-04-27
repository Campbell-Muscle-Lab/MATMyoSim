function update_forces(obj)

switch (obj.kinetic_scheme)
    case '3state_with_SRX'
        bin_pops = obj.myofilaments.y(2+(1:obj.myofilaments.no_of_x_bins));
        obj.cb_force = ...
                obj.parameters.cb_number_density *  ...
                    obj.parameters.k_cb * 1e-9 * ...
                    sum((obj.myofilaments.x + obj.parameters.x_ps) .* ...
                        bin_pops');
                    
    case '4state_with_SRX'
        M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
        M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
            (1:obj.myofilaments.no_of_x_bins);
            
        M3 = obj.myofilaments.y(M3_indices);
        M4 = obj.myofilaments.y(M4_indices);
        
        obj.cb_force = ...
            obj.parameters.cb_number_density * ...
                obj.parameters.k_cb * 1e-9 * ...
                (sum(obj.myofilaments.x .* M3') + ...
                    sum((obj.myofilaments.x + obj.parameters.x_ps) .* M4'));
    otherwise
        error('Undefined kinetic scheme in update_forces');
end

obj.passive_force = obj.return_passive_force(obj.hs_length);

obj.hs_force = obj.cb_force + obj.passive_force;