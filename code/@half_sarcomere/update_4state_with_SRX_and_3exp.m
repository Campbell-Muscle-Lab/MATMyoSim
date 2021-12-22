function rate_structure = update_4state_with_SRX_and_3exp(obj,time_step, m_props, delta_hsl)
% Function updates kinetics for thick and thin filaments

% Pull out the myofilaments vector
y = obj.myofilaments.y;

% Deduce some indices
M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
    (1:obj.myofilaments.no_of_x_bins);

% Get the overlap
N_overlap = return_f_overlap(obj);

% Pre-calculate rates
r1 = obj.parameters.k_1 * (1 + obj.parameters.k_force * ...
                            max([0 obj.hs_force]));

r2 = min([obj.parameters.max_rate obj.parameters.k_2]);            

r3 = obj.parameters.k_3 * ...
        exp(-0.5 * obj.parameters.k_cb * (obj.myofilaments.x).^2 / ...
            (1e18 * obj.parameters.k_boltzmann * ...
                obj.parameters.temperature));
r3(r3>obj.parameters.max_rate)=obj.parameters.max_rate;            

r4 = obj.parameters.k_4_0 * exp(-obj.parameters.k_cb * ...
                                 (obj.parameters.x_ps(1) + obj.myofilaments.x) ./ ...
                            (1e18 * obj.parameters.k_boltzmann * ...
                                obj.parameters.temperature));
r4(r4>obj.parameters.max_rate)=obj.parameters.max_rate;

r5 = obj.parameters.k_5_0;
r5(r5 < 0) = 0;
r5(r5 > obj.parameters.max_rate) = obj.parameters.max_rate;

r6 = min([obj.parameters.k_6 obj.parameters.max_rate]) * ...
        ones(1, obj.myofilaments.no_of_x_bins);
   
r7 = obj.parameters.k_7_0 * ones(size(obj.myofilaments.x));
                    
r7(r7>obj.parameters.max_rate)=obj.parameters.max_rate;

r8 = min([obj.parameters.k_8 obj.parameters.max_rate]) * ...
        ones(1, obj.myofilaments.no_of_x_bins);

r_on = obj.parameters.k_on * obj.Ca;

r_off = obj.parameters.k_off;
if (r_off < 0)
    r_off = 0;
end

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

% Keep actin summed to 1
ac = obj.myofilaments.y(end-1) + obj.myofilaments.y(end);
obj.myofilaments.y(end-1) = obj.myofilaments.y(1) + (1-ac);

obj.f_overlap = N_overlap;
obj.f_on = obj.myofilaments.y(end);
obj.f_bound = sum(obj.myofilaments.y(M3_indices)) + ...
    sum(obj.myofilaments.y(M4_indices)); 

% Store rates
obj.rate_structure.r1 = r1;
obj.rate_structure.r2 = r2;
obj.rate_structure.r3 = r3;
obj.rate_structure.r4 = r4;
obj.rate_structure.r5 = r5;
obj.rate_structure.r6 = r6;
obj.rate_structure.r7 = r7;
obj.rate_structure.r8 = r8;
obj.rate_structure.r_on = r_on;
obj.rate_structure.r_off = r_off;


    % Nested function
    function dy = derivs(time_step,y)
        
        % Set dy
        dy = zeros(numel(y),1);

        % Unpack
        M1 = y(1);
        M2 = y(2);
        M3 = y(M3_indices);
        M4 = y(M4_indices);
        
        N_off = y(end-1);
        N_on = y(end);
        N_bound = sum(M3)+sum(M4);
        
        % Calculate the fluxes
        J1 = r1 * M1;
        J2 = r2 * M2;
        J3 = r3 .* obj.myofilaments.bin_width * M2 * (N_on - N_bound);
        J4 = r4 .* M3';
        J5 = r5 .* M3';
        J6 = r6 .* M4';
        J7 = r7 .* M4';
        J8 = r8 * M2;
        
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
        dy(2) = (J1 + sum(J4)) - (J2 + sum(J3)) + sum(J7) - sum(J8);
        for i=1:obj.myofilaments.no_of_x_bins
            dy(M3_indices(i)) = J3(i) - J4(i) - J5(i) + J6(i);
            dy(M4_indices(i)) = J5(i) - J6(i) - J7(i) + J8(i);
        end
        dy(end-1) = -J_on + J_off;
        dy(end) = J_on - J_off;
    end
end
