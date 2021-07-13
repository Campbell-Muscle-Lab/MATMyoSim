classdef simulation < handle
    
    properties
        % These are properties that can be accessed from outside the class
        
        % The muscle
        myosim_muscle = [];
        
        % The protocol
        myosim_protocol = [];
        
        % Model options
        myosim_options = [];
        
        % A structure for the output
        sim_output = [];
       
    end
    
    properties (SetAccess = private)
        % These are propeties that can only be accessed from within the
        % class
        
    end
    
    methods
        
        % Constructor
        function obj = simulation(varargin)
            % Creates a new simulation with a muscle
            model_json_file_string = varargin{1};
            obj.myosim_muscle = muscle(model_json_file_string);
        end
        
        function obj = implement_protocol(obj, ...
                protocol_file_string, options_file_string)

            % Load in the protocol
            obj.myosim_protocol = readtable(protocol_file_string);
            
            % Initialize the data
            obj.initialize_myosim_data(numel(obj.myosim_protocol.dt));
            
            % Load in the options
            json_struct = loadjson(options_file_string);
            obj.myosim_options = json_struct.MyoSim_options;
            
            % Run protocol
            for t_counter = 1 : numel(obj.myosim_protocol.dt)
                obj.implement_time_step( ...
                        obj.myosim_protocol.dt(t_counter), ...
                        obj.myosim_protocol.dhsl(t_counter), ...
                        10^(-obj.myosim_protocol.pCa(t_counter)), ...
                        obj.myosim_protocol.Mode(t_counter), ...
                        obj.myosim_muscle.hs(1).kinetic_scheme, ...
                        t_counter, numel(obj.myosim_protocol.dt));
            end
        end
        
        function obj = implement_pendulum_protocol(obj, varargin)
            % Implements a pendulum test using the protocol file to
            % set the Ca transient at each time-point

            % Handle inputs
            p = inputParser;
            addOptional(p, 'protocol_file_string', []);
            addOptional(p, 'pendulum_file_string', []);
            addOptional(p, 'options_file_string', []);
            addOptional(p, 'dt', []);
            addOptional(p, 'pCa', []);
            parse(p, varargin{:});
            p = p.Results
            
            % Read in the protocol file if available
            if (~isempty(p.protocol_file_string))
                obj.myosim_protocol = readtable(protocol_file_string);
            else
                % Create a protocol from the dt and pCa arrays
                obj.myosim_protocol.dt = p.dt;
                obj.myosim_protocol.pCa = p.pCa;
            end
            
            % Initialize the data
            obj.initialize_myosim_data(numel(obj.myosim_protocol.dt));
            % add in the protocol position
            obj.sim_output.pendulum_position = ...
                NaN * ones(numel(obj.myosim_protocol.dt),1);
            
            % Load in the options
            json_struct = loadjson(p.options_file_string);
            obj.myosim_options = json_struct.MyoSim_options;

            % Open pendulum file and store pendulum properties
            json_struct = loadjson(p.pendulum_file_string);
            pend = json_struct.pendulum
            
            % Initialize
            y = pend.initial_conditions;
            
            % Integrate over solution
            for t_counter = 1 : numel(obj.myosim_protocol.dt)
                % Integrate the pendulum to work out the length change
                [~, y_calc] = ode45(...
                    @(t,y) pend_derivs(t, y, pend, ...
                        obj.myosim_muscle.muscle_force), ...
                        [0 obj.myosim_protocol.dt(t_counter)], y);
                y = y_calc(end,:);
                dhsl = y(2) * pend.hsl_scaling_factor * ...
                    obj.myosim_protocol.dt(t_counter);
                
                % Update the model
                obj.implement_time_step( ...
                            obj.myosim_protocol.dt(t_counter), dhsl, ...
                            10^(-obj.myosim_protocol.pCa(t_counter)), -2, ...
                            obj.myosim_muscle.hs(1).kinetic_scheme, ...
                            t_counter, numel(obj.myosim_protocol.dt));
                
                % Hold the pendulum position
                obj.sim_output.pendulum_position(t_counter) = y(1);
            end
        end
        
        function obj = initialize_myosim_data(obj, no_of_points)
            % Prepare the output
            
            obj.sim_output = [];
            obj.sim_output.subplots = [];
            obj.sim_output.myosim_muscle = obj.myosim_muscle;
            obj.sim_output.no_of_time_points = no_of_points;
            NaN_array = NaN * ones(obj.sim_output.no_of_time_points,1);
            obj.sim_output.time_s = NaN_array;
            obj.sim_output.muscle_force = NaN_array;
            obj.sim_output.muscle_length = NaN_array;
            obj.sim_output.series_extension = NaN_array;
            NaN_matrix = NaN*ones(obj.sim_output.no_of_time_points, ...
                obj.myosim_muscle.no_of_half_sarcomeres);
            obj.sim_output.f_overlap = NaN_matrix;
            obj.sim_output.f_activated = NaN_matrix;
            obj.sim_output.f_bound = NaN_matrix;
            obj.sim_output.hs_force = NaN_matrix;
            obj.sim_output.cb_force = NaN_matrix;
            obj.sim_output.pas_force = NaN_matrix;
            obj.sim_output.visc_force = NaN_matrix;
            obj.sim_output.hs_length = NaN_matrix;
            obj.sim_output.Ca = NaN_matrix;

            if (startsWith(obj.myosim_muscle.hs.kinetic_scheme, ...
                    '2state'))
                obj.sim_output.M1 = NaN_matrix;
                obj.sim_output.M2 = NaN_matrix;
                obj.sim_output.cb_pops = NaN * ones( ...
                        obj.sim_output.no_of_time_points, ...
                        obj.myosim_muscle.no_of_half_sarcomeres, ...
                        obj.myosim_muscle.hs(1).myofilaments.no_of_x_bins);
            end                        

            if (startsWith(obj.myosim_muscle.hs.kinetic_scheme, ...
                    '3state_with_SRX'))

                obj.sim_output.M1 = NaN_matrix;
                obj.sim_output.M2 = NaN_matrix;
                obj.sim_output.M3 = NaN_matrix;
                obj.sim_output.cb_pops = NaN * ones( ...
                        obj.sim_output.no_of_time_points, ...
                        obj.myosim_muscle.no_of_half_sarcomeres, ...
                        obj.myosim_muscle.hs(1).myofilaments.no_of_x_bins);
            end                        

            if (startsWith(obj.myosim_muscle.hs.kinetic_scheme, ...
                '4state_with_SRX'))

                obj.sim_output.M1 = NaN_matrix;
                obj.sim_output.M2 = NaN_matrix;
                obj.sim_output.M3 = NaN_matrix;
                obj.sim_output.M4 = NaN_matrix;
                obj.sim_output.cb_pops = NaN * ones( ...
                        obj.sim_output.no_of_time_points, ...
                        obj.myosim_muscle.no_of_half_sarcomeres, ...
                        2, ...
                        obj.myosim_muscle.hs(1).myofilaments.no_of_x_bins);                        
            end
        end
        
        function obj = implement_time_step(obj, ...
                            dt, dhsl, pCa, sim_mode, kinetic_scheme, ...
                            t_counter, no_of_time_points)
            % Implements a time-step
            
            % Keep display active
            if (mod(t_counter,obj.myosim_options.drawing_skip)==0)
                t_counter = t_counter
            end

            % Implement the time step
            obj.myosim_muscle.implement_time_step( ...
                dt, dhsl, pCa, sim_mode, kinetic_scheme);

            % Store results
            if (t_counter==1)
                obj.sim_output.time_s(t_counter) = ...
                    dt;
            else
                obj.sim_output.time_s(t_counter) = ...
                    obj.sim_output.time_s(t_counter-1) + dt;
            end
                
            obj.sim_output.muscle_force(t_counter) = ...
                obj.myosim_muscle.muscle_force;
            obj.sim_output.muscle_length(t_counter) = ...
                obj.myosim_muscle.muscle_length;
            obj.sim_output.series_extension(t_counter) = ...
                obj.myosim_muscle.series_extension;
            for i=1:obj.myosim_muscle.no_of_half_sarcomeres
                obj.sim_output.f_overlap(t_counter,i) = ...
                    obj.myosim_muscle.hs(i).f_overlap;
                obj.sim_output.f_activated(t_counter,i) = ...
                    obj.myosim_muscle.hs(i).f_on;
                obj.sim_output.f_bound(t_counter,i) = ...
                    obj.myosim_muscle.hs(i).f_bound;
                obj.sim_output.hs_force(t_counter,i) = ...
                    obj.myosim_muscle.hs(i).hs_force;
                obj.sim_output.cb_force(t_counter,i) = ...
                    obj.myosim_muscle.hs(i).cb_force;
                obj.sim_output.intracellular_pas_force(t_counter,i) = ...
                    obj.myosim_muscle.hs(i).intracellular_passive_force;
                obj.sim_output.extracellular_pas_force(t_counter,i) = ...
                    obj.myosim_muscle.hs(i).extracellular_passive_force;
                obj.sim_output.visc_force(t_counter,i) = ...
                    obj.myosim_muscle.hs(i).viscous_force;
                obj.sim_output.hs_length(t_counter,i) = ...
                    obj.myosim_muscle.hs(i).hs_length;
                obj.sim_output.Ca(t_counter,i) = ...
                    obj.myosim_muscle.hs(i).Ca;
                
                if (startsWith(obj.myosim_muscle.hs(1).kinetic_scheme, ...
                    '2state'))

                    obj.sim_output.M1(t_counter,i) = ...
                        obj.myosim_muscle.hs(i).state_pops.M1;
                    obj.sim_output.M2(t_counter,i) = ...
                        obj.myosim_muscle.hs(i).state_pops.M2;
                    % Pull out the bin_distributions which need
                    % an extra dimension
                    M2_indices = 1+(1:obj.myosim_muscle.hs(i).myofilaments.no_of_x_bins);
                    obj.sim_output.cb_pops(t_counter,i,:) = ...
                        obj.myosim_muscle.hs(i).myofilaments.y(M2_indices);
                end

                if (startsWith(obj.myosim_muscle.hs(1).kinetic_scheme, ...
                        '3state_with_SRX'))

                    obj.sim_output.M1(t_counter,i) = ...
                        obj.myosim_muscle.hs(i).state_pops.M1;
                    obj.sim_output.M2(t_counter,i) = ...
                        obj.myosim_muscle.hs(i).state_pops.M2;
                    obj.sim_output.M3(t_counter,i) = ...
                        obj.myosim_muscle.hs(i).state_pops.M3;
                    % Pull out the bin_distributions which need
                    % an extra dimension
                    M3_indices = 2+(1:obj.myosim_muscle.hs(i).myofilaments.no_of_x_bins);
                    obj.sim_output.cb_pops(t_counter,i,:) = ...
                        obj.myosim_muscle.hs(i).myofilaments.y(M3_indices);
                end

                if (startsWith(obj.myosim_muscle.hs(1).kinetic_scheme, ...
                        '4state_with_SRX'))

                    obj.sim_output.M1(t_counter,i) = ...
                        obj.myosim_muscle.hs(i).state_pops.M1;
                    obj.sim_output.M2(t_counter,i) = ...
                        obj.myosim_muscle.hs(i).state_pops.M2;
                    obj.sim_output.M3(t_counter,i) = ...
                        obj.myosim_muscle.hs(i).state_pops.M3;
                    obj.sim_output.M4(t_counter,i) = ...
                        obj.myosim_muscle.hs(i).state_pops.M4;
                    % Pull out the bin_distributions which need
                    % an extra dimension
                    M3_indices = 2+(1:obj.myosim_muscle.hs(i).myofilaments.no_of_x_bins);
                    M4_indices = (2+obj.myosim_muscle.hs(i).myofilaments.no_of_x_bins) + ...
                        (1:obj.myosim_muscle.hs(i).myofilaments.no_of_x_bins);
                    obj.sim_output.cb_pops(t_counter,i,1,:) = ...
                        obj.myosim_muscle.hs(i).myofilaments.y(M3_indices);
                    obj.sim_output.cb_pops(t_counter,i,2,:) = ...
                        obj.myosim_muscle.hs(i).myofilaments.y(M4_indices);
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
                        (t_counter == no_of_time_points))
                    show_output(obj,'t_counter',t_counter);
                    drawnow;
                end
            end
        end
        
        % Other methods
        show_output(obj,varargin);
    end
end

function dy = pend_derivs(t, yy, pend, f)
    dy = NaN*ones(2,1);
    dy(1)= yy(2);
    dy(2) = (-pend.force_scaling_factor * f / pend.m) - (pend.eta*yy(2) / pend.m) - ...
                (pend.g * yy(1) / pend.L);
end
