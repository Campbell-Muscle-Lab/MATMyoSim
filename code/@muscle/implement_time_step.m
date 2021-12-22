function implement_time_step(obj,time_step,delta_hsl,Ca_value,mode_value, kinetic_scheme)
% Function implements a time_step

obj.command_length = obj.command_length + ...
        obj.no_of_half_sarcomeres*delta_hsl;

if ((obj.series_k_linear > 0) || (obj.no_of_half_sarcomeres > 1) || ...
        (mode_value >= 0))
    % We have at least one of a series component, multiple half-sarcomeres
    % or tension control and consequently need to impose force-balance
    
    m_props = [];
    
    % Cycle through the half-sarcomeres implementing cross-bridge cycling
    for hs_counter = 1:obj.no_of_half_sarcomeres
        obj.hs(hs_counter).implement_time_step(time_step,0,Ca_value, ...
                                                m_props);
    end
    
    delta_hsl = return_delta_hsl_for_force_balance(obj, mode_value, time_step);

    % Apply length changes, summing up muscle length
    obj.muscle_length = 0;
    for hs_counter = 1:obj.no_of_half_sarcomeres
        obj.hs(hs_counter).move_cb_distribution(delta_hsl(hs_counter));
        obj.hs(hs_counter).hs_length = obj.hs(hs_counter).hs_length + ...
            delta_hsl(hs_counter);
        obj.hs(hs_counter).update_forces(time_step, 0);
        obj.muscle_length = obj.muscle_length + obj.hs(hs_counter).hs_length;
    end
    
    % Set muscle force and add series extension to muscle length
    obj.muscle_force = obj.hs(1).hs_force;
    obj.series_extension = obj.return_series_extension(obj.muscle_force);
    obj.muscle_length = obj.muscle_length + obj.series_extension;
else
    % Single half-sarcomere with rigid connection - this is faster
    m_props = [];
        obj.series_extension = 0;
    
    if (mode_value == -1)
        % Update kinetics
        obj.hs(1).implement_time_step(time_step, 0, Ca_value, m_props);
        
        % This checks for slack
        opt = optimoptions('fsolve', 'Display', 'none');
        obj.hs(1).slack_length = ...
            fsolve(@tension_control_single_half_sarcomere, 0, opt);
        
        % New hs length cannot be shorter than slack length
        new_length = max([obj.hs(1).slack_length obj.command_length]);
        
        % The adjustment might be smaller if we are catching up on slack
        adjustment = new_length - obj.hs(1).hs_length;
        
        % Implement
        obj.hs(1).move_cb_distribution(adjustment);
        obj.hs(1).hs_length = new_length;
    else
        obj.hs(1).implement_time_step(time_step, delta_hsl, Ca_value, m_props);
        obj.hs(1).hs_length = obj.hs(1).hs_length + delta_hsl;
    end
    obj.muscle_length = obj.hs(1).hs_length;
    obj.muscle_force = obj.hs(1).hs_force;
   
end

        
    function x = tension_control_single_half_sarcomere(p)
        check_new_force(obj.hs(1), p, time_step);
        x = obj.hs(1).check_force - mode_value;
    end
end