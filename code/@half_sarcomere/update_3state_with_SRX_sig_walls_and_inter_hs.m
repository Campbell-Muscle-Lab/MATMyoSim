function update_3state_with_SRX_sig_walls_and_inter_hs(obj, time_step, m_props)
% Function updates kinetics for thick and thin filaments based on 3 state
% system with detachment similar to that in PMC4744171

if (~isfield(obj.parameters, 'k_4_1'))
    obj.parameters.k_4_1 = 0;
end

% Pull out the myofilaments vector
y = obj.myofilaments.y;

% Get the overlap
N_overlap = return_f_overlap(obj);

% % Pull out the interaction terms
% no_of_half_sarcomeres = numel(m_props.hs_passive_force);
% if (no_of_half_sarcomeres >= 3)
%     q_p = m_props.hs_passive_force;
%     q_a = m_props.hs_passive_force;
% 
%     switch (obj.hs_id)
%         case 1
%             b_p = (1 + obj.parameters.inter_z) * q_p(1);
%             b_a = q_a(1) + (obj.parameters.inter_thick * q_a(2));
%         case no_of_half_sarcomeres
%             if (mod(no_of_half_sarcomeres, 2) == 0)
%                 % Even
%                 b_p = (1 + obj.parameters.inter_z) * q_p(no_of_half_sarcomeres);
%                 b_a = (obj.parameters.inter_thick * q_a(no_of_half_sarcomeres-1)) + ...
%                     q_a(no_of_half_sarcomeres);
%             else
%                 b_p = q_p(no_of_half_sarcomeres) + ...
%                     obj.parameters.inter_z * q_p(no_of_half_sarcomeres-1);
%                 b_a = (1 + obj.parameters.inter_thick) * q_a(no_of_half_sarcomeres);
%             end
%         otherwise
%             if (mod(obj.hs_id, 2) == 0)
%                 % Even half-sarcomere
%                 b_p = q_p(obj.hs_id) + ...
%                         obj.parameters.inter_z * q_p(obj.hs_id+1);
%                 b_a = (obj.parameters.inter_thick * q_a(obj.hs_id-1)) + ...
%                         q_a(obj.hs_id);
%             else
%                 % Odd half-sarcomere
%                 b_p = obj.parameters.inter_z * q_p(obj.hs_id-1) + ...
%                         q_p(obj.hs_id);
%                 b_a = q_a(obj.hs_id) + ...
%                         (obj.parameters.inter_thick * q_a(obj.hs_id+1)); 
%             end
%     end
% else
%     b_p = obj.passive_force;
%     b_a = obj.passive_force;
% end

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

% k3
b_k3 = movmean(q_k3,3);
b_k3 = b_k3(obj.hs_id);
b_af = obj.cb_force;

% Pre-calculate rate
r1 = min([obj.parameters.max_rate ...
    obj.parameters.k_1 * (1 + obj.parameters.k_force * b_af)]);

r2 = min([obj.parameters.max_rate obj.parameters.k_2]);

r3 = obj.parameters.k_3 * ...
        b_k3 * ...
        exp(-obj.parameters.k_cb * (obj.myofilaments.x).^2 / ...
                (2 * 1e18 * obj.parameters.k_boltzmann * ...
                    obj.parameters.temperature));
r3(r3>obj.parameters.max_rate)=obj.parameters.max_rate;
r3(r3<0) = 0;

r4 = obj.parameters.k_3 * exp(obj.parameters.k_4_base_energy) * ...
            (1/b_k3) * ...
            exp(0.5 * obj.parameters.k_cb *...
                (obj.myofilaments.x + obj.parameters.k_4_1*obj.parameters.x_ps).^2 / ...
                (1e18 * obj.parameters.k_boltzmann * ...
                    obj.parameters.temperature));
r4(r4>obj.parameters.max_rate) =obj.parameters.max_rate;

r_on = obj.parameters.k_on * obj.Ca;

r_off = obj.parameters.k_off * (1 + obj.parameters.k_off_force * b_k3);
% r_off = obj.parameters.k_off * q_k3(obj.hs_id);


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
