classdef simulation < handle
    
    properties
        % These are properties that can be accessed from outside the class
        
        % The model
        myosim_model = [];
        
        % The protocol
        myosim_protocol = [];
        
        % Model options
        myosim_options = [];
        
        % A structure for the output
        sim_output = [];
        
        % The muscle
        m = [];
        
    end
    
    properties (SetAccess = private)
        % These are propeties that can only be accessed from within the
        % class
        
    end
    
    methods
        
        % Constructor
        function obj = simulation(varargin)
            
            % Start by unpacking the inputs
            model_json_file_string = varargin{1};
            simulation_protocol_file_string = varargin{2};
            options_json_file_string = varargin{3};
            
            % Create the model
            json_struct = loadjson(model_json_file_string);
            obj.myosim_model = json_struct.MyoSim_model;
            
            % Create the muscle
            obj.m = muscle(obj.myosim_model);
            
            % Load in the protocol
            obj.myosim_protocol = readtable(simulation_protocol_file_string);
            
            % Prepare the output
            obj.sim_output = [];
            obj.sim_output.subplots = [];
            obj.sim_output.myosim_model = obj.myosim_model;
            obj.sim_output.time_s = cumsum(obj.myosim_protocol.dt);
            obj.sim_output.no_of_time_points = numel(obj.sim_output.time_s);
            NaN_array = NaN * ones(obj.sim_output.no_of_time_points,1);
            obj.sim_output.muscle_force = NaN_array;
            obj.sim_output.muscle_length = NaN_array;
            obj.sim_output.series_extension = NaN_array;
            NaN_matrix = NaN*ones(obj.sim_output.no_of_time_points, ...
                obj.m.no_of_half_sarcomeres);
            obj.sim_output.f_overlap = NaN_matrix;
            obj.sim_output.f_activated = NaN_matrix;
            obj.sim_output.f_bound = NaN_matrix;
            obj.sim_output.hs_force = NaN_matrix;
            obj.sim_output.cb_force = NaN_matrix;
            obj.sim_output.pas_force = NaN_matrix;
            obj.sim_output.visc_force = NaN_matrix;
            obj.sim_output.hs_length = NaN_matrix;
            obj.sim_output.Ca = NaN_matrix;

            if (startsWith(obj.myosim_model.hs_props.kinetic_scheme, ...
                    '2state'))

                obj.sim_output.M1 = NaN_matrix;
                obj.sim_output.M2 = NaN_matrix;
                obj.sim_output.cb_pops = NaN * ones( ...
                        obj.sim_output.no_of_time_points, ...
                        obj.m.no_of_half_sarcomeres, ...
                        obj.m.hs(1).myofilaments.no_of_x_bins);
            end                        

            if (startsWith(obj.myosim_model.hs_props.kinetic_scheme, ...
                    '3state_with_SRX'))

                obj.sim_output.M1 = NaN_matrix;
                obj.sim_output.M2 = NaN_matrix;
                obj.sim_output.M3 = NaN_matrix;
                obj.sim_output.cb_pops = NaN * ones( ...
                        obj.sim_output.no_of_time_points, ...
                        obj.m.no_of_half_sarcomeres, ...
                        obj.m.hs(1).myofilaments.no_of_x_bins);
            end                        

            if (startsWith(obj.myosim_model.hs_props.kinetic_scheme, ...
                '4state_with_SRX'))

                obj.sim_output.M1 = NaN_matrix;
                obj.sim_output.M2 = NaN_matrix;
                obj.sim_output.M3 = NaN_matrix;
                obj.sim_output.M4 = NaN_matrix;
                obj.sim_output.cb_pops = NaN * ones( ...
                        obj.sim_output.no_of_time_points, ...
                        obj.m.no_of_half_sarcomeres, ...
                        2, ...
                        obj.m.hs(1).myofilaments.no_of_x_bins);                        
            end
            
            % Load in the options
            json_struct = loadjson(options_json_file_string);
            obj.myosim_options = json_struct.MyoSim_options;
        end
        
        function obj = implement_protocol(obj)
            
            % Special initialize for 1 half-sarcomere without
            % series compliance
            if ((obj.m.series_k_linear == 0) && ...
                    (obj.m.no_of_half_sarcomeres == 1))
                obj.m.hs(1).hs_length = obj.m.muscle_length;
            end
            
            for t_counter = 1:obj.sim_output.no_of_time_points

                % Keep display active
                if (mod(t_counter,obj.myosim_options.drawing_skip)==0)
                    t_counter = t_counter
                end

                % Implement the time step
                obj.m.implement_time_step( ...
                    obj.myosim_protocol.dt(t_counter), ...
                    obj.myosim_protocol.dhsl(t_counter), ...
                    10^(-obj.myosim_protocol.pCa(t_counter)), ...
                    obj.myosim_protocol.Mode(t_counter), ...
                    obj.m.hs(1).kinetic_scheme);
                
                % Store results
                obj.sim_output.muscle_force(t_counter) = ...
                    obj.m.muscle_force;
                obj.sim_output.muscle_length(t_counter) = ...
                    obj.m.muscle_length;
                obj.sim_output.series_extension(t_counter) = ...
                    obj.m.series_extension;
                for i=1:obj.m.no_of_half_sarcomeres
                    obj.sim_output.f_overlap(t_counter,i) = ...
                        obj.m.hs(i).f_overlap;
                    obj.sim_output.f_activated(t_counter,i) = ...
                        obj.m.hs(i).f_on;
                    obj.sim_output.f_bound(t_counter,i) = ...
                        obj.m.hs(i).f_bound;
                    obj.sim_output.hs_force(t_counter,i) = ...
                        obj.m.hs(i).hs_force;
                    obj.sim_output.cb_force(t_counter,i) = ...
                        obj.m.hs(i).cb_force;
                    obj.sim_output.pas_force(t_counter,i) = ...
                        obj.m.hs(i).passive_force;
                    obj.sim_output.visc_force(t_counter,i) = ...
                        obj.m.hs(i).viscous_force;
                    obj.sim_output.hs_length(t_counter,i) = ...
                        obj.m.hs(i).hs_length;
                    obj.sim_output.Ca(t_counter,i) = ...
                        obj.m.hs(i).Ca;

                    if (startsWith(obj.myosim_model.hs_props.kinetic_scheme, ...
                        '2state'))

                        obj.sim_output.M1(t_counter,i) = ...
                            obj.m.hs(i).state_pops.M1;
                        obj.sim_output.M2(t_counter,i) = ...
                            obj.m.hs(i).state_pops.M2;
                        % Pull out the bin_distributions which need
                        % an extra dimension
                        M2_indices = 1+(1:obj.m.hs(i).myofilaments.no_of_x_bins);
                        obj.sim_output.cb_pops(t_counter,i,:) = ...
                            obj.m.hs(i).myofilaments.y(M2_indices);
                    end
                    
                    if (startsWith(obj.myosim_model.hs_props.kinetic_scheme, ...
                            '3state_with_SRX'))

                        obj.sim_output.M1(t_counter,i) = ...
                            obj.m.hs(i).state_pops.M1;
                        obj.sim_output.M2(t_counter,i) = ...
                            obj.m.hs(i).state_pops.M2;
                        obj.sim_output.M3(t_counter,i) = ...
                            obj.m.hs(i).state_pops.M3;
                        % Pull out the bin_distributions which need
                        % an extra dimension
                        M3_indices = 2+(1:obj.m.hs(i).myofilaments.no_of_x_bins);
                        obj.sim_output.cb_pops(t_counter,i,:) = ...
                            obj.m.hs(i).myofilaments.y(M3_indices);
                    end
                    
                    if (startsWith(obj.myosim_model.hs_props.kinetic_scheme, ...
                            '4state_with_SRX'))

                        obj.sim_output.M1(t_counter,i) = ...
                            obj.m.hs(i).state_pops.M1;
                        obj.sim_output.M2(t_counter,i) = ...
                            obj.m.hs(i).state_pops.M2;
                        obj.sim_output.M3(t_counter,i) = ...
                            obj.m.hs(i).state_pops.M3;
                        obj.sim_output.M4(t_counter,i) = ...
                            obj.m.hs(i).state_pops.M4;
                        % Pull out the bin_distributions which need
                        % an extra dimension
                        M3_indices = 2+(1:obj.m.hs(i).myofilaments.no_of_x_bins);
                        M4_indices = (2+obj.m.hs(i).myofilaments.no_of_x_bins) + ...
                            (1:obj.m.hs(i).myofilaments.no_of_x_bins);
                        obj.sim_output.cb_pops(t_counter,i,1,:) = ...
                            obj.m.hs(i).myofilaments.y(M3_indices);
                        obj.sim_output.cb_pops(t_counter,i,2,:) = ...
                            obj.m.hs(i).myofilaments.y(M4_indices);
                    end
                    
                    % Storing rates
                   if (1)
                        obj.sim_output.rate_structure.k_off(t_counter,i) = ...
                            obj.m.hs(i).rate_structure.r_off;
                   end
                   
                end
                
                % Draw rates if required on first time-step
                if (t_counter==1)
                    if (obj.myosim_options.figure_rates>0)
                        draw_rates(obj);
                        drawnow;
                    end
                end
                
                % Update display if required
                if (obj.myosim_options.figure_simulation_output)
                    if ((mod(t_counter,obj.myosim_options.drawing_skip)==0) || ...
                            (t_counter == obj.sim_output.no_of_time_points))
                        show_output(obj,'t_counter',t_counter);
                        drawnow;
                    end
                end
            end
        end
        
        % Other methods
        show_output(obj,varargin);
    end
end
        