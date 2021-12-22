function update_3state_with_SRX(obj,time_step);
% Function updates kinetics for thick and thin filaments based on 3 state
% SRX model descripbed by Campbell et al, 2018

% Pull out the myofilaments vector
y = obj.myofilaments.y;

% Get the overlap
N_overlap = return_f_overlap(obj);

% Pre-calculate rate
r1 = obj.parameters.k_1 * ...
        (1 + obj.parameters.k_force * max([0 obj.int_total_force]));
r1 = min([r1 obj.parameters.max_rate]);

r2 = min([obj.parameters.max_rate obj.parameters.k_2]);

r3 = obj.parameters.k_3 * ...
            exp(-obj.parameters.k_cb * (obj.myofilaments.x).^2 / ...
                (2 * 1e18 * obj.parameters.k_boltzmann * ...
                    obj.parameters.temperature));
r3(r3>obj.parameters.max_rate)=obj.parameters.max_rate;

r4 = obj.parameters.k_4_0 + ...
                (obj.parameters.k_4_1 * ...
                    ((obj.myofilaments.x + 0 * obj.parameters.x_ps).^4));
r4(r4>obj.parameters.max_rate)=obj.parameters.max_rate;

% Evolve the system
[t,y_new] = ode23(@derivs,[0 time_step],y,[]);

% Update the system
obj.myofilaments.y = y_new(end,:)';

% Catch non-zero elements
zi = find(obj.myofilaments.y < 0);
obj.myofilaments.y(zi) = 0;

% Keep cbs summed to 1
cb = sum(obj.myofilaments.y(1:(end-2)));
obj.myofilaments.y(1) = obj.myofilaments.y(1) + (1-cb);
if (abs(1-cb)>1e-5)
    error('ken');
end

% Keep actin summed to 1
ac = obj.myofilaments.y(end-1) + obj.myofilaments.y(end);
obj.myofilaments.y(end-1) = obj.myofilaments.y(1) + (1-ac);

obj.f_overlap = N_overlap;
obj.f_on = obj.myofilaments.y(end);
obj.f_bound = sum(obj.myofilaments.y(2+(1:obj.myofilaments.no_of_x_bins))); 

% Store rate structure
obj.rate_structure.r1 = r1;
obj.rate_structure.r2 = r2;
obj.rate_structure.r3 = r3;
obj.rate_structure.r4 = r4;

    % Nested function
    function dy = derivs(time_step,y)
        
        % Set dy
        dy = zeros(numel(y),1);

        % Unpack
        M1 = y(1);
        M2 = y(2);
        M3 = y(2+(1:obj.myofilaments.no_of_x_bins));
        N_off = y(end-1);
        N_on = y(end);
        N_bound = sum(M3);
        
        % Calculate the fluxes
        J1 = r1 * M1;
        J2 = r2 * M2;
        J3 = r3 .* obj.myofilaments.bin_width * M2 * (N_on - N_bound);
        J4 = r4 .* M3';
        if (N_overlap > 0)
            J_on = obj.parameters.k_on * obj.Ca * (N_overlap - N_on) * ...
                    (1 + obj.parameters.k_coop * (N_on/N_overlap));
            J_off = obj.parameters.k_off * (N_on - N_bound) * ...
                    (1 + obj.parameters.k_coop * ((N_overlap - N_on)/N_overlap));
        else
            J_on = 0;
            J_off = obj.parameters.k_off * (N_on - N_bound);
        end
            
        % Calculate the derivs
        dy(1) = -J1 + J2;
        dy(2) = (J1 + sum(J4)) - (J2 + sum(J3));
        for i=1:obj.myofilaments.no_of_x_bins
            dy(2+i) = J3(i) - J4(i);
        end
        dy(end-1) = -J_on + J_off;
        dy(end) = J_on - J_off;
    end
end
