function rate_structure = update_4state_with_SRX(obj,time_step, m_props)
% Function updates kinetics for thick and thin filaments

% Pull out the myofilaments vector
y = obj.myofilaments.y;

% Deduce some indices
M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
    (1:obj.myofilaments.no_of_x_bins);

% Get the overlap
N_overlap = return_f_overlap(obj);

% Pull out the interaction terms
no_of_half_sarcomeres = numel(m_props.hs_passive_force);
if (no_of_half_sarcomeres >= 3)
    q_k3 = m_props.hs_length/1300;
    q_pf = m_props.hs_passive_force;
    q_af = m_props.hs_active_force;

    switch (obj.hs_id)
        case 1
            b_k3 = (1 + obj.parameters.k3_inter_z) * q_k3(1) + ...
                obj.parameters.k3_inter_thick * q_k3(2);
            b_pf = (1 + obj.parameters.pf_inter_z) * q_pf(1) + ...
                obj.parameters.pf_inter_thick * q_pf(2);
            b_af = (1 + obj.parameters.af_inter_z) * q_af(1) + ...
                obj.parameters.af_inter_thick * q_af(2);
        case no_of_half_sarcomeres
            if (mod(no_of_half_sarcomeres, 2) == 0)
                % Even
                b_k3 = obj.parameters.k3_inter_thick * q_k3(no_of_half_sarcomeres-1) + ...
                        (1 + obj.parameters.k3_inter_z) * q_k3(no_of_half_sarcomeres);
                b_pf = obj.parameters.pf_inter_thick * q_pf(no_of_half_sarcomeres-1) + ...
                        (1 + obj.parameters.pf_inter_z) * q_pf(no_of_half_sarcomeres);
                b_af = obj.parameters.af_inter_thick * q_af(no_of_half_sarcomeres-1) + ...
                        (1 + obj.parameters.af_inter_z) * q_af(no_of_half_sarcomeres);                    
            else
                b_k3 = obj.parameters.k3_inter_z * q_k3(no_of_half_sarcomeres-1) + ...
                        (1 + obj.parameters.k3_inter_thick) * q_k3(no_of_half_sarcomeres);
                b_pf = obj.parameters.pf_inter_z * q_pf(no_of_half_sarcomeres-1) + ...
                        (1 + obj.parameters.pf_inter_thick) * q_pf(no_of_half_sarcomeres);
                b_af = obj.parameters.af_inter_z * q_af(no_of_half_sarcomeres-1) + ...
                        (1 + obj.parameters.af_inter_thick) * q_af(no_of_half_sarcomeres);                    
            end
        otherwise
            if (mod(obj.hs_id, 2) == 0)
                % Even half-sarcomere
                b_k3 = obj.parameters.k3_inter_thick * q_k3(obj.hs_id-1) + ...
                        q_k3(obj.hs_id) + ....
                        obj.parameters.k3_inter_z * q_k3(obj.hs_id+1);
                b_pf = obj.parameters.pf_inter_thick * q_pf(obj.hs_id-1) + ...
                        q_pf(obj.hs_id) + ...
                        obj.parameters.pf_inter_z * q_pf(obj.hs_id+1);
                b_af = obj.parameters.af_inter_thick * q_af(obj.hs_id-1) + ...
                        q_af(obj.hs_id) + ...
                        obj.parameters.af_inter_z * q_af(obj.hs_id+1);                    
            else
                % Odd half-sarcomere
                b_k3 = obj.parameters.k3_inter_z * q_k3(obj.hs_id-1) + ...
                        q_k3(obj.hs_id) + ....
                        obj.parameters.k3_inter_thick * q_k3(obj.hs_id+1);
                b_pf = obj.parameters.pf_inter_z * q_pf(obj.hs_id-1) + ...
                        q_pf(obj.hs_id) + ...
                        obj.parameters.pf_inter_thick * q_pf(obj.hs_id+1);
                b_af = obj.parameters.af_inter_z * q_af(obj.hs_id-1) + ...
                        q_af(obj.hs_id) + ...
                        obj.parameters.af_inter_thick * q_af(obj.hs_id+1);                    
            end
    end
else
    b_k3 = 0;
end

% Normalize b_k3
if (obj.parameters.k_3_hsl~=0)
    b_k3 = obj.parameters.k_3_hsl * b_k3 / ...
            (1 + obj.parameters.k3_inter_z + obj.parameters.k3_inter_thick);
else
    b_k3 = 1;
end
b_af = obj.cb_force;

% Pre-calculate rates
r1 = obj.parameters.k_1 * (1 + obj.parameters.k_force * b_af);
if (r1<0)
    r1=0;
end

r2 = min([obj.parameters.max_rate obj.parameters.k_2]);            

r3 = obj.parameters.k_3 * (1 + obj.parameters.k_3_inter_hs * b_k3) * ...
        b_k3 * ...
        exp(-0.5 * obj.parameters.k_cb * (obj.myofilaments.x).^2 / ...
            (1e18 * obj.parameters.k_boltzmann * ...
                obj.parameters.temperature));
r3(r3>obj.parameters.max_rate)=obj.parameters.max_rate;            

r4 = obj.parameters.k_3 * exp(obj.parameters.k_4_base_energy) * ...
         exp(0.5 * obj.parameters.k_cb *(obj.myofilaments.x).^2 / ...
            (1e18 * obj.parameters.k_boltzmann * ...
                obj.parameters.temperature));
r4(r4>obj.parameters.max_rate)=obj.parameters.max_rate;

r5 = obj.parameters.k_5 * ...
        exp(-obj.parameters.k_cb * obj.myofilaments.x .* ...
            (obj.parameters.phi * obj.parameters.x_ps) ./ ...
            (1e18 * obj.parameters.k_boltzmann * ...
                obj.parameters.temperature));
r5(r5>obj.parameters.max_rate) = obj.parameters.max_rate;

r6 = obj.parameters.k_5 * exp(obj.parameters.k_6_base_energy) * ...
        exp(obj.parameters.k_cb * ...
            ((obj.myofilaments.x + obj.parameters.x_ps) .* ...
            (1 - obj.parameters.phi) .* obj.parameters.x_ps) ./ ...
            (1e18 * obj.parameters.k_boltzmann * ...
                obj.parameters.temperature));
r6(r6>obj.parameters.max_rate) = obj.parameters.max_rate;

r7 = obj.parameters.k_7 * ...
        exp(0.5 * obj.parameters.k_cb * ...
            (obj.myofilaments.x + 0 *obj.parameters.x_ps).^2 ./ ...
            (1e18 * obj.parameters.k_boltzmann * ...
                obj.parameters.temperature));
r7(r7>obj.parameters.max_rate) = obj.parameters.max_rate;
            
r8 = obj.parameters.k_8*ones(numel(obj.myofilaments.x),1);

r_on = obj.parameters.k_on * obj.Ca;

r_off = obj.parameters.k_off * ...
            (1 + obj.parameters.k_off_force * obj.passive_force);
if (r_off < 0)
    r_off = 0;
end

% Evolve the system
[t,y_new] = ode23(@derivs,[0 time_step],y,[]);

% Update the system
obj.myofilaments.y = y_new(end,:)';
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

obj.rate_structure.b_k3 = b_k3;
obj.rate_structure.b_pf = b_pf;
obj.rate_structure.b_af = b_af;


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
        
        J_on = r_on * (N_overlap - N_on) * ...
                (1 + obj.parameters.k_coop * (N_on/N_overlap));
            
        J_off = r_off * (N_on - N_bound) * ...
                (1 + obj.parameters.k_coop * ((N_overlap - N_on)/N_overlap));
            
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
