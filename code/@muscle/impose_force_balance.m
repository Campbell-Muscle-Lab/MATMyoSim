function [obj, delta_hsl] = impose_force_balance(obj ,mode_value, time_step)
% Function updates the length of each half-sarcomere and
% the series component to maintain force balance

if ((obj.no_of_half_sarcomeres==1) && (obj.series_k_linear == 0))
    if (mode_value < 0)
        % Length control
        obj.series_extension=0;
        delta_hsl = obj.muscle_length - obj.hs(1).hs_length;
        obj.hs(1).move_cb_distribution(delta_hsl);
        obj.hs(1).hs_length = obj.muscle_length;
        check_new_force(obj.hs(1), obj.muscle_length, time_step);
        obj.muscle_force = obj.hs(1).check_force;
        return
    else
        % Force control
        obj.series_extension=0;
        opt = optimoptions('fsolve','Display','none');
        p = obj.hs(1).hs_length;
        new_p = fsolve(@tension_control_single_half_sarcomere, p, opt);
        obj.muscle_length = new_p;
        delta_hsl = obj.muscle_length - obj.hs(1).hs_length;
        obj.hs(1).move_cb_distribution(delta_hsl);
        obj.hs(1).hs_length = obj.muscle_length;
        check_new_force(obj.hs(1), obj.muscle_length, time_step);
        obj.muscle_force = obj.hs(1).check_force;
        return
    end
end

% Now try and impose force balance

% Work out whether we are in length or tension control
if (mode_value < 0)
    % Length control
    
    % Create a vector p which has the lengths of each half-sarcomere
    % followed by the muscle force
    for hs_counter = 1:obj.no_of_half_sarcomeres
        p(hs_counter) = obj.hs(hs_counter).hs_length;
    end
    p(obj.no_of_half_sarcomeres+1) = obj.muscle_force;

    % @length_control_muscle_system tries to find a p vector so that
    % the forces in each half-sarcomere and the force in the series
    % elastic element (the total muscle length - the sum of the half-
    % sarcomere lengths are all equal
    opt = optimoptions('fsolve','Display','none');
    new_p = fsolve(@length_control_muscle_system,p,opt);

    % Unpack the new_p array and implement
    for hs_counter = 1:obj.no_of_half_sarcomeres
        delta_hsl(hs_counter) = new_p(hs_counter) - obj.hs(hs_counter).hs_length;
        obj.hs(hs_counter).move_cb_distribution(delta_hsl(hs_counter));
        obj.hs(hs_counter).hs_length = new_p(hs_counter);
    end
    obj.series_extension = return_series_extension(obj,new_p(end));
    obj.muscle_force = new_p(end);
else
    % Tension control
    
    % Create a vector p which has the lengths of each half-sarcomere
    % followed by the length of the series component
    for hs_counter = 1:obj.no_of_half_sarcomeres
        p(hs_counter) = obj.hs(hs_counter).hs_length;
    end
    p(obj.no_of_half_sarcomeres+1) = obj.series_extension;

    % @tension_control_muscle_system tries to find a p vector so that
    % the forces in each half-sarcomere and the force in the series
    % elastic element are all equal to mode
    
    opt = optimoptions('fsolve','Display','none');
    new_p = fsolve(@tension_control_muscle_system,p,opt);
    
    % Unpack the new_p array and implement
    for hs_counter = 1:obj.no_of_half_sarcomeres
        delta_hsl(hs_counter) = new_p(hs_counter) - obj.hs(hs_counter).hs_length;
        obj.hs(hs_counter).move_cb_distribution(delta_hsl(hs_counter));
        obj.hs(hs_counter).hs_length = new_p(hs_counter);
    end
    obj.series_extension = new_p(end);
    obj.muscle_length = sum(new_p);
    obj.muscle_force = return_series_force(obj,new_p(end));
  
end

    % Nested functions
    function x = length_control_muscle_system(p)
        x=zeros(numel(p),1);
        for i=1:obj.no_of_half_sarcomeres
            check_new_force(obj.hs(i), p(i), time_step);
            x(i) = obj.hs(i).check_force - p(end);
        end
        new_series_extension = obj.muscle_length - ...
            sum(p(1:obj.no_of_half_sarcomeres));
        x(end) = return_series_force(obj,new_series_extension) - ...
            p(end);
    end

    function x = tension_control_muscle_system(p)
        x=zeros(numel(p),1);
        for i=1:obj.no_of_half_sarcomeres
            check_new_force(obj.hs(i), p(i), time_step);
            x(i) = obj.hs(i).check_force - mode_value;
        end
        x(end) = return_series_force(obj,p(end)) - mode_value;
    end

    function x = tension_control_single_half_sarcomere(p)
        check_new_force(obj.hs(1), p, time_step);
        x = obj.hs(1).check_force - mode_value;
    end
    
end
    
