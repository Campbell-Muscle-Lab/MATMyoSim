function [m_force, c_force] = return_cb_force(obj, time_step, delta_hsl)
% Function return cb force

% Set default value for c_force
c_force = 0;
m_force = 0;

switch obj.kinetic_scheme
    case '2state'
        bin_pops = obj.myofilaments.y(1+(1:obj.myofilaments.no_of_x_bins));
        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density *  ...
                    obj.parameters.k_cb * 1e-9 * ...
                    sum((obj.myofilaments.x + obj.parameters.x_ps) .* ...
                        bin_pops');
    
    case '3state_with_SRX'
        bin_pops = obj.myofilaments.y(2+(1:obj.myofilaments.no_of_x_bins));
        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                  obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density *  ...
                    obj.parameters.k_cb * 1e-9 * ...
                    sum((obj.myofilaments.x + obj.parameters.x_ps) .* ...
                        bin_pops');
    
    case 'm_3state_with_SRX_mybpc_2state'
        m_indices = 2 + (1:obj.myofilaments.no_of_x_bins);
        c_indices = 5 + obj.myofilaments.no_of_x_bins + ...
                            (1:obj.myofilaments.no_of_x_bins);
        
        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                  obj.parameters.cb_number_density * ...
                    obj.parameters.k_cb * 1e-9 * ...
                    sum((obj.myofilaments.x + obj.parameters.x_ps) .* ...
                        obj.myofilaments.y(m_indices)');

        c_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                  obj.parameters.cb_number_density * ...
                    obj.parameters.k_mybpc * 1e-9 * ...
                    sum((obj.myofilaments.x + obj.parameters.x_ps) .* ...
                        obj.myofilaments.y(c_indices)');
                    
                    
                    
    case '3state_with_SRX_and_exp_k4'
        bin_pops = obj.myofilaments.y(2+(1:obj.myofilaments.no_of_x_bins));
        
        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                  obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density *  ...
                    obj.parameters.k_cb * 1e-9 * ...
                    sum((obj.myofilaments.x + obj.parameters.x_ps) .* ...
                        bin_pops');                    

    case '4state_with_SRX'
        M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
        M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
            (1:obj.myofilaments.no_of_x_bins);

        M3 = obj.myofilaments.y(M3_indices);
        M4 = obj.myofilaments.y(M4_indices);

        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density * ...
                    obj.parameters.k_cb * 1e-9 * ...
                    (sum(obj.myofilaments.x .* M3') + ...
                        sum((obj.myofilaments.x + obj.parameters.x_ps) .* M4'));

    case '4state_with_SRX_and_3exp'
        M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
        M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
            (1:obj.myofilaments.no_of_x_bins);

        M3 = obj.myofilaments.y(M3_indices);
        M4 = obj.myofilaments.y(M4_indices);

        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density * ...
                    obj.parameters.k_cb * 1e-9 * ...
                    (sum((obj.myofilaments.x + obj.parameters.x_ps) .* M3') + ...
                        sum((obj.myofilaments.x + obj.parameters.x_ps + obj.parameters.x2_ps) .* M4'));

    case '4state_with_SRX_and_4exp'
        M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
        M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
            (1:obj.myofilaments.no_of_x_bins);

        M3 = obj.myofilaments.y(M3_indices);
        M4 = obj.myofilaments.y(M4_indices);

        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density * ...
                    obj.parameters.k_cb * 1e-9 * ...
                    (sum((obj.myofilaments.x + obj.parameters.x_ps) .* M3') + ...
                        sum((obj.myofilaments.x + obj.parameters.x_ps + obj.parameters.x2_ps) .* M4'));
 
    case '4state_with_SRX_and_exp_k5'
        M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
        M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
            (1:obj.myofilaments.no_of_x_bins);

        M3 = obj.myofilaments.y(M3_indices);
        M4 = obj.myofilaments.y(M4_indices);

        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density * ...
                    obj.parameters.k_cb * 1e-9 * ...
                    (sum((obj.myofilaments.x + obj.parameters.x_ps) .* M3') + ...
                        sum((obj.myofilaments.x + obj.parameters.x_ps + obj.parameters.x2_ps) .* M4'));
                    
    case '6state_with_SRX'
        M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
        M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
            (1:obj.myofilaments.no_of_x_bins);

        M3 = obj.myofilaments.y(M3_indices);
        M4 = obj.myofilaments.y(M4_indices);

        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density * ...
                    obj.parameters.k_cb * 1e-9 * ...
                    (sum((obj.myofilaments.x + obj.parameters.x_ps) .* M3') + ...
                        sum((obj.myofilaments.x + obj.parameters.x_ps + obj.parameters.x2_ps) .* M4'));                                        
                    
    case '7state_with_SRX'
        M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
        M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
            (1:obj.myofilaments.no_of_x_bins);
        M5_indices = (2+(2*obj.myofilaments.no_of_x_bins)) + ...
            (1:obj.myofilaments.no_of_x_bins);

        M3 = obj.myofilaments.y(M3_indices);
        M4 = obj.myofilaments.y(M4_indices);
        M5 = obj.myofilaments.y(M5_indices);

        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density * ...
                    obj.parameters.k_cb * 1e-9 * ...
                    (sum((obj.myofilaments.x + obj.parameters.x1_ps) .* M3') + ...
                        sum((obj.myofilaments.x + obj.parameters.x1_ps + ...
                                obj.parameters.x2_ps) .* M4') + ...
                        sum((obj.myofilaments.x + obj.parameters.x1_ps + ...
                                obj.parameters.x2_ps + obj.parameters.x3_ps) .* M5'));
                            
    case 'beard_atp'
        M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
        M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
            (1:obj.myofilaments.no_of_x_bins);
        M5_indices = (2+(2*obj.myofilaments.no_of_x_bins)) + ...
            (1:obj.myofilaments.no_of_x_bins);
        M6_indices = (2+(3*obj.myofilaments.no_of_x_bins)) + ...
            (1:obj.myofilaments.no_of_x_bins);

        M3 = obj.myofilaments.y(M3_indices);
        M4 = obj.myofilaments.y(M4_indices);
        M5 = obj.myofilaments.y(M5_indices);
        M6 = obj.myofilaments.y(M6_indices);

        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density * ...
                    obj.parameters.k_cb * 1e-9 * ...
                    (sum((obj.myofilaments.x + obj.parameters.x1_ps) .* M3') + ...
                        sum((obj.myofilaments.x + obj.parameters.x1_ps + ...
                                obj.parameters.x2_ps) .* M4') + ...
                        sum((obj.myofilaments.x + obj.parameters.x1_ps + ...
                                obj.parameters.x2_ps + obj.parameters.x3_ps) .* M5') + ...
                        sum((obj.myofilaments.x + obj.parameters.x1_ps + ...
                                obj.parameters.x2_ps + obj.parameters.x3_ps + ...
                                obj.parameters.x4_ps) .* M6'));
                            
    case '3D_1A'
        M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);

        M3 = obj.myofilaments.y(M3_indices);

        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density * ...
                    obj.parameters.k_cb * 1e-9 * ...
                    sum((obj.myofilaments.x + obj.parameters.x_ps) .* M3');
    
    case '3D_3A'
        M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
        M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
            (1:obj.myofilaments.no_of_x_bins);
        M5_indices = (2+(2*obj.myofilaments.no_of_x_bins)) + ...
            (1:obj.myofilaments.no_of_x_bins);

        M3 = obj.myofilaments.y(M3_indices);
        M4 = obj.myofilaments.y(M4_indices);
        M5 = obj.myofilaments.y(M5_indices);

        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density * ...
                    obj.parameters.k_cb * 1e-9 * ...
                    (sum((obj.myofilaments.x + obj.parameters.x1_ps) .* M3') + ...
                        sum((obj.myofilaments.x + obj.parameters.x1_ps + ...
                                obj.parameters.x2_ps) .* M4') + ...
                        sum((obj.myofilaments.x + obj.parameters.x1_ps + ...
                                obj.parameters.x2_ps + obj.parameters.x3_ps) .* M5'));
                            
    case '4D_3A'
        M3_indices = 2+(1:obj.myofilaments.no_of_x_bins);
        M4_indices = (2+obj.myofilaments.no_of_x_bins) + ...
            (1:obj.myofilaments.no_of_x_bins);
        M5_indices = (2+(2*obj.myofilaments.no_of_x_bins)) + ...
            (1:obj.myofilaments.no_of_x_bins);

        M3 = obj.myofilaments.y(M3_indices);
        M4 = obj.myofilaments.y(M4_indices);
        M5 = obj.myofilaments.y(M5_indices);

        m_force = (1 - obj.parameters.prop_fibrosis) * ...
                    obj.parameters.prop_myofilaments * ...
                obj.parameters.cb_number_density * ...
                    obj.parameters.k_cb * 1e-9 * ...
                    (sum((obj.myofilaments.x + obj.parameters.x1_ps) .* M3') + ...
                        sum((obj.myofilaments.x + obj.parameters.x1_ps + ...
                                obj.parameters.x2_ps) .* M4') + ...
                        sum((obj.myofilaments.x + obj.parameters.x1_ps + ...
                                obj.parameters.x2_ps + obj.parameters.x3_ps) .* M5'));   
end
