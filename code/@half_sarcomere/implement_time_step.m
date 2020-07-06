function implement_time_step(obj,time_step,delta_hsl,Ca_concentration, ...
                                m_props)

% Update Ca
obj.Ca = Ca_concentration;

% Update kinetics
obj.evolve_kinetics(time_step, m_props);

% Move distributions
obj.move_cb_distribution(delta_hsl);

% Update forces
obj.update_forces(time_step, delta_hsl);

% Store pops
flag = 1;

if startsWith(obj.kinetic_scheme, '2state')
    flag = 0;
    obj.state_pops.M1 = obj.myofilaments.y(1);
    obj.state_pops.M2 = ...
        sum(obj.myofilaments.y(1+(1:obj.myofilaments.no_of_x_bins)));
end

if startsWith(obj.kinetic_scheme, '3state_with_SRX')
    flag = 0;
    obj.state_pops.M1 = obj.myofilaments.y(1);
    obj.state_pops.M2 = obj.myofilaments.y(2);
    obj.state_pops.M3 = ...
        sum(obj.myofilaments.y(2+(1:obj.myofilaments.no_of_x_bins)));
end

if startsWith(obj.kinetic_scheme, '4state_with_SRX')
    flag = 0;
    obj.state_pops.M1 = obj.myofilaments.y(1);
    obj.state_pops.M2 = obj.myofilaments.y(2);

    M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
    M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
        (1:obj.myofilaments.no_of_x_bins);

    obj.state_pops.M3 = ...
        sum(obj.myofilaments.y(M3_indices));        
    obj.state_pops.M4 = ...
        sum(obj.myofilaments.y(M4_indices));        
end

% Check
if (flag)
    error('half_sarcomere::implement_time_step, kinetic scheme undefined');
end

end
