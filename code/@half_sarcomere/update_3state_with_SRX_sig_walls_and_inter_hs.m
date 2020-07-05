function update_3state_with_SRX_sig_walls_and_inter_hs(obj, time_step, m_props)
% Function updates kinetics for thick and thin filaments based on 3 state
% system with detachment similar to that in PMC4744171

% Pull out the myofilaments vector
y = obj.myofilaments.y;

% Get the overlap
N_overlap = return_f_overlap(obj);

% Pull out the interaction terms
no_of_half_sarcomeres = numel(m_props.hs_passive_force);
if (no_of_half_sarcomeres >= 3)
    
    m_pas_force = m_props.hs_passive_force;
    m_act_force = m_props.hs_active_force;
    switch (obj.hs_id)
        case 1
            pas = 2 * m_pas_force(obj.hs_id);
            act = m_act_force(obj.hs_id) + m_act_force(obj.hs_id + 1);
        case no_of_half_sarcomeres
            if (mod(no_of_half_sarcomeres, 2) == 0)
                % Even half-sarcomere
                pas = 2 * m_pas_force(obj.hs_id);
                act = m_act_force(obj.hs_id) + m_act_force(obj.hs_id - 1);
            else
                % Odd half-sarcomere
                pas = m_pas_force(obj.hs_id) + m_pas_force(obj.hs_id -1);
                act = 2 * m_act_force(obj.hs_id);
            end
        otherwise
            if (mod(no_of_half_sarcomeres, 2) == 0)
                % Even half-sarcomere
                pas = m_pas_force(obj.hs_id) + m_pas_force(obj.hs_id + 1);
                act = m_act_force(obj.hs_id) + m_act_force(obj.hs_id - 1);
            else
                % Odd half-sarcomere
                pas = m_pas_force(obj.hs_id) + m_pas_force(obj.hs_id - 1);
                act = m_act_force(obj.hs_id) + m_act_force(obj.hs_id + 1);
            end
    end
else
    pas = 0;
    act = 0;
end

% act = obj.hs_force;

% Pre-calculate rate
r1 = min([obj.parameters.max_rate ...
            obj.parameters.k_1 * ...
                (1+(obj.parameters.k_force * act))]);
r2 = min([obj.parameters.max_rate obj.parameters.k_2]);
r3 = obj.parameters.k_3 * ...
            exp(-obj.parameters.k_cb * (obj.myofilaments.x).^2 / ...
                (2 * 1e18 * obj.parameters.k_boltzmann * ...
                    obj.parameters.temperature));
r3(r3>obj.parameters.max_rate)=obj.parameters.max_rate;

r4 = obj.parameters.k_3 * exp(obj.parameters.k_4_base_energy) * ...
            exp(0.5 * obj.parameters.k_cb * ...
                (obj.myofilaments.x + obj.parameters.x_ps).^2 / ...
                (1e18 * obj.parameters.k_boltzmann * ...
                    obj.parameters.temperature));
r4(r4>obj.parameters.max_rate)=obj.parameters.max_rate;

r_on = obj.parameters.k_on * obj.Ca * ...
    (1 + obj.parameters.k_on_force * pas);
if (r_on < 0)
    r_on = 0;
end

if (obj.hs_id==3)
    sprintf('act force: %g  r_1: %g', act, r1)
end


r_off = obj.parameters.k_off;

% Evolve the system
[t,y_new] = ode23(@derivs,[0 time_step],y,[]);

% Update the system
obj.myofilaments.y = y_new(end,:)';
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
        J_on = r_on * (N_overlap - N_on) * ...
                (1 + obj.parameters.k_coop * (N_on/N_overlap));
        J_off = r_off * (N_on - N_bound) * ...
                (1 + obj.parameters.k_coop * ((N_overlap - N_on)/N_overlap));
            
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
