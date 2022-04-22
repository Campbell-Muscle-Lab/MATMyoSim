function implement_time_step(obj,time_step,delta_hsl,Ca_value,mode_value, kinetic_scheme)
% Function implements a time_step

obj.command_length = obj.command_length + ...
        obj.no_of_half_sarcomeres*delta_hsl;

if ((obj.series_k_linear > 0) || ...
    (obj.no_of_half_sarcomeres > 1) || ...
    (mode_value >= 0))
    % We have at least one of a series component, multiple half-sarcomeres
    % or tension control and consequently need to impose force-balance
    
    m_props = [];
    
    % Cycle through the half-sarcomeres implementing cross-bridge cycling
    if (time_step > 0)
        for hs_counter = 1:obj.no_of_half_sarcomeres
            obj.hs(hs_counter).implement_time_step(time_step,0,Ca_value, ...
                                                    m_props);
        end
    end
    
    if (mode_value < 0)
        % We are under length control, and thus know the muscle length
        obj.muscle_length = ...
            obj.muscle_length + obj.no_of_half_sarcomeres * delta_hsl;

        dhsl_balance = return_delta_hsl_for_force_balance(obj, ...
            mode_value, time_step);

        % Apply length changes, updating hs properties
        for hs_counter = 1:obj.no_of_half_sarcomeres
            obj.hs(hs_counter).move_cb_distribution(dhsl_balance(hs_counter));
            obj.hs(hs_counter).hs_length = obj.hs(hs_counter).hs_length + ...
                dhsl_balance(hs_counter);
            obj.hs(hs_counter).update_forces(time_step, 0);
        end

        % Set muscle force and add series extension to muscle length
        obj.muscle_force = obj.hs(1).hs_force;
        if (obj.series_k_linear > 0)
            obj.series_extension = obj.return_series_extension(obj.muscle_force);
        else
            obj.series_extension = 0;
        end
    else
        % We are under force control and don't know the overall length
        dhsl_balance = return_delta_hsl_for_force_balance(obj, ...
            mode_value, time_step);

        % Apply length changes, updating hs properties, and summing up
        % muscle length
        obj.muscle_length = 0;
        for hs_counter = 1:obj.no_of_half_sarcomeres
            obj.hs(hs_counter).move_cb_distribution(dhsl_balance(hs_counter));
            obj.hs(hs_counter).hs_length = obj.hs(hs_counter).hs_length + ...
                dhsl_balance(hs_counter);
            obj.hs(hs_counter).update_forces(time_step, 0);
            obj.muscle_length = obj.muscle_length + ...
                obj.hs(hs_counter).hs_length;
        end

        % Set muscle force and add series extension to muscle length
        obj.muscle_force = obj.hs(1).hs_force;
        if (obj.series_k_linear > 0)
            obj.series_extension = obj.return_series_extension(obj.muscle_force);
        else
            obj.series_extension = 0;
        end
        obj.muscle_length = obj.muscle_length + obj.series_extension;
    end
else
    % Single half-sarcomere with rigid connection - this is faster
    m_props = [];
        obj.series_extension = 0;
    
    if (mode_value == -1)
        % Update kinetics
        if (time_step > 0)
            obj.hs(1).implement_time_step(time_step, 0, Ca_value, m_props);
        end
        
        % This checks for slack
        isotonic_force = 0;
        opt = optimoptions('fsolve', 'Display', 'none');
        obj.hs(1).slack_length = ...
            fsolve(@tension_control_single_half_sarcomere, 0, opt);
%         error('ken');
        
        % New hs length cannot be shorter than slack length
        new_length = max([obj.hs(1).slack_length obj.command_length]);
        
        % The adjustment might be smaller if we are catching up on slack
        adjustment = new_length - obj.hs(1).hs_length;
        
        % Implement
        obj.hs(1).move_cb_distribution(adjustment);
        obj.hs(1).hs_length = new_length;
    else
        if (time_step > 0)
            obj.hs(1).implement_time_step(time_step, delta_hsl, Ca_value, m_props);
        end
        obj.hs(1).hs_length = obj.hs(1).hs_length + delta_hsl;
    end
    obj.muscle_length = obj.hs(1).hs_length;
    obj.muscle_force = obj.hs(1).hs_force;
end

        
    function x = tension_control_single_half_sarcomere(p)
        check_new_force(obj.hs(1), p, time_step);
        x = obj.hs(1).check_force - isotonic_force;
    end
end