function update_2state_with_poly(obj,time_step);
% Function updates kinetics for thick and thin filaments based on
% a simple two state model

% Pull out the myofilaments vector
y = obj.myofilaments.y;

% Get the overlap
N_overlap = return_f_overlap(obj);

% Pre-calculate rate
r1 = obj.parameters.k_1 * ...
            exp(-obj.parameters.k_cb * (obj.myofilaments.x).^2 / ...
                (2 * 1e18 * obj.parameters.k_boltzmann * ...
                    obj.parameters.temperature));
r1(r1>obj.parameters.max_rate)=obj.parameters.max_rate;

r2 = obj.parameters.k_2_0 + ...
                (obj.parameters.k_2_1 * ...
                    ((obj.myofilaments.x + obj.parameters.x_ps).^4));
r2(r2>obj.parameters.max_rate)=obj.parameters.max_rate;

% Evolve the system
[t,y_new] = ode23(@derivs,[0 time_step],y,[]);

% Update the system
obj.myofilaments.y = y_new(end,:)';
obj.f_overlap = N_overlap;
obj.f_on = obj.myofilaments.y(end);
obj.f_bound = sum(obj.myofilaments.y(1+(1:obj.myofilaments.no_of_x_bins))); 

% Store rate structure
obj.rate_structure.r1 = r1;
obj.rate_structure.r2 = r2;

    % Nested function
    function dy = derivs(time_step,y)
        
        % Set dy
        dy = zeros(numel(y),1);

        % Unpack
        M1 = y(1);
        M2 = y(1+(1:obj.myofilaments.no_of_x_bins));
        N_off = y(end-1);
        N_on = y(end);
        N_bound = sum(M2);
        
        % Calculate the fluxes
        J1 = r1 .* obj.myofilaments.bin_width * M1 * (N_on - N_bound);
        J2 = r2 .* M2';
        J_on = obj.parameters.k_on * obj.Ca * (N_overlap - N_on) * ...
                (1 + obj.parameters.k_coop * (N_on/N_overlap));
        J_off = obj.parameters.k_off * (N_on - N_bound) * ...
                (1 + obj.parameters.k_coop * ((N_overlap - N_on)/N_overlap));
            
        % Calculate the derivs
        dy(1) = sum(J2) - sum(J1);
        for i=1:obj.myofilaments.no_of_x_bins
            dy(1+i) = J1(i) - J2(i);
        end
        dy(end-1) = -J_on + J_off;
        dy(end) = J_on - J_off;
    end
end
