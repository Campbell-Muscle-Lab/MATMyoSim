function implement_time_step(obj,time_step,delta_hsl,Ca_value,mode_value)
% Function implements a time_step

obj.muscle_length = obj.muscle_length + obj.no_of_half_sarcomeres*delta_hsl;

if ((obj.series_k_linear > 0) || (obj.no_of_half_sarcomeres > 1))
    % We have a series component and/or multiple half-sarcomeres and
    % consequently need to impose force-balance
    
    % Pull off the hs_forces
    for i=1:obj.no_of_half_sarcomeres
        m_props.hs_passive_force(i) = obj.hs(i).passive_force;
    end
    
    % Cycle through the half-sarcomeres implementing cross-bridge cycling
    for hs_counter = 1:obj.no_of_half_sarcomeres
        obj.hs(hs_counter).implement_time_step(time_step,0,Ca_value, ...
                                                m_props);
    end

    obj = impose_force_balance(obj,mode_value);

    for hs_counter = 1:obj.no_of_half_sarcomeres
        obj.hs(hs_counter).update_forces;
    end
else
    % Single half-sarcomere - this is faster
    m_props.hs_passive_force = obj.hs.passive_force;
    obj.hs(1).implement_time_step(time_step,delta_hsl,Ca_value, m_props);
    obj.series_extension = 0;
    obj.muscle_length = obj.muscle_length + delta_hsl;
    obj.hs(1).hs_length = obj.hs(1).hs_length + delta_hsl;
    obj.muscle_force = obj.hs(1).hs_force;
   
end