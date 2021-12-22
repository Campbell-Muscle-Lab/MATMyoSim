classdef muscle < handle
    
    properties
        % These are properties that can be accessed from outside the
        % muscle class
        
        no_of_half_sarcomeres;
        series_k_linear_per_hs;
        series_k_linear;
        muscle_length;
        command_length;
        series_extension = 0;
        muscle_force = 0;
        
        % A holder for an array of half_sarcomeres
        hs = half_sarcomere;
    end
    
    properties (SetAccess = private)
        % These are properties that can only be accessed from within the
        % muscle class
    end
    
    methods

        % Constructor
        function obj = muscle(model_file)
            % The muscle is defined by the model file
            
            % Start by unpacking the model
            model_struct = loadjson(model_file);
            myosim_model = model_struct.MyoSim_model;
           
            muscle_props = myosim_model.muscle_props;
            hs_props = myosim_model.hs_props;
            
            % Update the muscle variables
            muscle_field_names = fieldnames(muscle_props);
            for i=1:numel(muscle_field_names)
                obj.(muscle_field_names{i}) = ...
                    muscle_props.(muscle_field_names{i});
            end
            
            % Correct the series compliance for the number of
            % half-sarcomeres
            obj.series_k_linear = obj.series_k_linear_per_hs / ...
                obj.no_of_half_sarcomeres;
            
            % Now create half_sarcomeres, updating muscle length as we go
            obj.muscle_length = 0;
            for hs_counter = 1:obj.no_of_half_sarcomeres
                obj.hs(hs_counter) = half_sarcomere(hs_props, hs_counter);
                obj.muscle_length = obj.muscle_length + ...
                    obj.hs(hs_counter).hs_length;
            end
            obj.command_length = obj.muscle_length;
            
            % Impose heterogeneity if required
            if (isfield(myosim_model,'hs_heterogeneity'))
                heterogeneous_fields = fieldnames(myosim_model.hs_heterogeneity)
                for field_counter = 1:numel(heterogeneous_fields)
                    for hs_counter = 1:obj.no_of_half_sarcomeres
                        obj.hs(hs_counter).parameters.(heterogeneous_fields{field_counter}) = ...
                            myosim_model.hs_heterogeneity.(heterogeneous_fields{field_counter})(hs_counter);
                    end
                end
            end

            % Implement force balance in length control mode for the
            % initialisation step
            impose_force_balance(obj,-2,1);
        end
        
        % Other methods
        [obj, delta_hsl] = impose_force_balance(obj, mode_value, time_step);
        delta_hsl = return_delta_hsl_for_force_balance(obj, mode_value, time_step);
        series_extension = return_series_extension(obj,muscle_force);
        series_force = return_series_force(obj,series_extension);
        implement_time_step(obj,time_step,delta_hsl,Ca_value,Mode_value, kinetic_scheme);
    end
end
            
        