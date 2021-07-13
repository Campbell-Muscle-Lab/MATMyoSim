function implement_time_step(obj,time_step,delta_hsl,Ca_value,mode_value, kinetic_scheme)
% Function implements a time_step

obj.muscle_length = obj.muscle_length + obj.no_of_half_sarcomeres*delta_hsl;

if ((obj.series_k_linear > 0) || (obj.no_of_half_sarcomeres > 1) || ...
        (mode_value >= 0))
    % We have at least one of a series component, multiple half-sarcomeres
    % or tension control and consequently need to impose force-balance
    
    % Pull off the hs props
    for i=1:obj.no_of_half_sarcomeres
        m_props.hs_intracellular_passive_force(i) = ...
            obj.hs(i).intracellular_passive_force;
        m_props.hs_active_force(i) = obj.hs(i).cb_force;
        m_props.hs_total_force(i) = obj.hs(i).hs_force;
        m_props.hs_bound_cb(i) = obj.hs(i).f_bound;
        m_props.hs_length(i) = obj.hs(i).hs_length;
        
        if (startsWith(kinetic_scheme, '4state_with_SRX'))
            M4_indices = (2 + obj.hs(i).myofilaments.no_of_x_bins) + ...
                (1:obj.hs(i).myofilaments.no_of_x_bins);
            m_props.hs_force_generating_cb(i) = ...
                sum(obj.hs(i).myofilaments.y(M4_indices));
        end
    end
    
    % Cycle through the half-sarcomeres implementing cross-bridge cycling
    for hs_counter = 1:obj.no_of_half_sarcomeres
        obj.hs(hs_counter).implement_time_step(time_step,0,Ca_value, ...
                                                m_props);
    end

    [obj, delta_hsl] = impose_force_balance(obj, mode_value, time_step);

    for hs_counter = 1:obj.no_of_half_sarcomeres
        obj.hs(hs_counter).update_forces(time_step, delta_hsl(hs_counter));
    end
else
    % Single half-sarcomere - this is faster
    m_props.hs_intracellular_passive_force = ...
        obj.hs(1).intracellular_passive_force;
    obj.hs.implement_time_step(time_step,delta_hsl,Ca_value, m_props);
    obj.series_extension = 0;
    obj.muscle_length = obj.muscle_length + delta_hsl;
    obj.hs(1).hs_length = obj.hs(1).hs_length + delta_hsl;
    obj.muscle_force = obj.hs(1).hs_force;
   
end