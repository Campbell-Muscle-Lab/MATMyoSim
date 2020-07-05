function evolve_kinetics(obj, time_step, m_props)
% Function updates kinetics for thick and thin filaments

switch (obj.kinetic_scheme)
    
    case '2state_with_poly'
        update_2state_with_poly(obj, time_step);
    
    case '3state_with_SRX'
        update_3state_with_SRX(obj, time_step);
    
    case '3state_with_SRX_and_exp_k4'
        update_3state_with_SRX_and_exp_k4(obj, time_step);        
    
    case '3state_with_SRX_and_energy_barrier'
        update_3state_with_SRX_and_energy_barrier(obj, time_step, m_props);                
    
    case '3state_with_SRX_and_k_thin_force'
        update_3state_with_SRX_and_k_thin_force(obj, time_step, m_props);
        
    case '3state_with_SRX_sig_walls_and_inter_hs'
        update_3state_with_SRX_sig_walls_and_inter_hs(obj, time_step, m_props);
        
    case '4state_with_SRX'
        update_4state_with_SRX(obj, time_step, m_props); 
        
    case '4state_with_SRX_and_exp_k7'
        update_4state_with_SRX_and_exp_k7(obj, time_step);         
    
    otherwise
        error('Undefined kinetic scheme in half_sarcomere class');
end