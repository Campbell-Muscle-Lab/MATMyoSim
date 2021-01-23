classdef half_sarcomere < handle
    
    properties
        % These are properties that can be accessed from outside the
        % half-sarcomere class
        
        hs_id;  
        
        hs_length = 1050;   % the length of the half-sarcomere in nm
        hs_force = 0;       % the stress (in N m^(-2)) in the half-sarcomere

        f_overlap;
        f_on;
        f_bound;
        
        cb_force = 0;
        intracellular_passive_force = 0;
        viscous_force = 0;
        extracellular_passive_force = 0;
        
        state_pops;
        
        Ca;                  % Ca concentration (in M)
        
        kinetic_scheme;
        
        check_force;        % temp force used during force balance
        
        myofilaments = [];  % a structure that holds the data for
                            % half-sarcomere kinetics
                            % precise format depends on the kinetic scheme
                            
        parameters = [];    % a structure that holds the model parameters
                            % precise format depends on the kinetic scheme
                            
        rate_structure = [];
                            % a structure holding myofilament rates

    end
    
    properties (SetAccess = private)
        % These are properties that can only be accessed from within
        % the half-sarcomere class
                           
    end
    
    methods
        
        % Constructor
        function obj = half_sarcomere(varargin)
            
            if (isempty(varargin))
                hs = [];
                return;
            end
            
            hs_props = varargin{1};
            
            % Set id
            obj.hs_id = varargin{2};
            
            % Set kinetic_scheme
            obj.kinetic_scheme = hs_props.kinetic_scheme;
            
            % Set length
            obj.hs_length = hs_props.hs_length;
            
            % Set myofilament properties
            myofilament_props = hs_props.myofilaments;
            myofilament_field_names = fieldnames(myofilament_props);
            for i=1:numel(myofilament_field_names)
                obj.myofilaments.(myofilament_field_names{i}) = ...
                    myofilament_props.(myofilament_field_names{i});
            end
            
            % Do some calculations
            obj.myofilaments.x = obj.myofilaments.bin_min : ...
                            obj.myofilaments.bin_width : ...
                                obj.myofilaments.bin_max;
                            % array of x_bin values
            obj.myofilaments.no_of_x_bins = numel(obj.myofilaments.x);
                            % no of x_bins
                            
            % Set up the y_vector which is used for kinetics
            if (startsWith(obj.kinetic_scheme, '2state'))
                obj.myofilaments.y_length = ...
                    obj.myofilaments.no_of_x_bins + 3;
                obj.myofilaments.y = ...
                    zeros(obj.myofilaments.y_length, 1);
                
                % Start with all the cross-bridges in M1 and
                % all binding sites off
                obj.myofilaments.y(1) = 1.0;
                obj.myofilaments.y(end-1) = 1.0;
            end
            
            if (startsWith(obj.kinetic_scheme, '3state_with_SRX'))
                obj.myofilaments.y_length = ...
                    obj.myofilaments.no_of_x_bins + 4;
                obj.myofilaments.y = ...
                    zeros(obj.myofilaments.y_length,1);

                % Start with all the cross-bridges in M1 and all
                % binding sites off
                obj.myofilaments.y(1)=1.0;
                obj.myofilaments.y(end-1) = 1.0;
            end
            
            if (startsWith(obj.kinetic_scheme, '4state_with_SRX'))
                obj.myofilaments.y_length = ...
                    (2*obj.myofilaments.no_of_x_bins) + 4;
                obj.myofilaments.y = ...
                    zeros(obj.myofilaments.y_length,1);

                % Start with all cross-bridges in M1 and all
                % binding sites off
                obj.myofilaments.y(1) = 1.0;
                obj.myofilaments.y(end-1) = 1.0;
            end
                        
            % Handle other parameters
            parameter_props = hs_props.parameters;
            parameter_field_names = fieldnames(parameter_props);
            for i=1:numel(parameter_field_names)
                obj.parameters.(parameter_field_names{i}) = ...
                    parameter_props.(parameter_field_names{i});
                % Next bit checks for the case of x.a = linear
                % which is supposed to be x.a = 'linear' but creates
                % a linear function object if you have the system
                % identification toolbox installed
                if (isobject(obj.parameters.(parameter_field_names{i})))
                    obj.parameters.(parameter_field_names{i}) = ...
                        class(obj.parameters.(parameter_field_names{i}));
                end
            end
            
            % Set viscosity to 0 if missing from parameters
            if (~isfield(obj.parameters, 'viscosity'))
                obj.parameters.viscosity = 0;
            end
            
            % Set intracellular and extracellular passive proportions
            % if missing
            if (~isfield(obj.parameters, ...
                    'intracellular_passive_proportion'))
                obj.parameters.intracellular_passive_proportion = 1;
            end
            if (~isfield(obj.parameters, ...
                    'extracellular_passive_proportion'))
                obj.parameters.extracellular_passive_proportion = 0;
            end
            
            % Initialise forces
            obj.cb_force = 0;
            obj.intracellular_passive_force = ...
                return_intracellular_passive_force(obj, obj.hs_length);
            obj.extracellular_passive_force = ...
                return_extracellular_passive_force(obj, obj.hs_length);
            
            obj.hs_force = obj.cb_force + ...
                obj.intracellular_passive_force + ...
                obj.extracellular_passive_force;
                

            % Intialise_populations
            obj.f_on = 0;
            obj.f_bound = 0;
        end
        
        % Other methods
        f_overlap = return_f_overlap(obj);
        pf = return_passive_force(obj,hsl);
        
        evolve_kinetics(obj, time_step, m_props);
        
        update_2state_with_poly(obj, time_step);
        update_3state_with_SRX(obj, time_step);
        update_3state_with_SRX_and_k_thin_force(obj, time_step, m_props);
        update_3state_with_SRX_and_exp_k4(obj, time_step);
        update_3state_with_SRX_and_energy_barrier(obj, time_step, m_props);
        update_3state_with_SRX_sig_walls_and_inter_hs(obj, time_step, m_props);
        update_4state_with_SRX(obj, time_step, m_props);
        update_4state_with_SRX_and_exp_k7(obj, time_step);
        
        move_cb_distribution(obj, delta_hsl);
        update_forces(obj, time_step, delta_hsl);
        
        check_new_force(obj, new_length, time_step);

        implement_time_step(obj,time_step,delta_hsl, ...
            Ca_concentration, m_props);
        
    end
end
            
            
            
            
            
        
        