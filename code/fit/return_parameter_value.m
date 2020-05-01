function parameter_value = return_parameter_value(par_structure, p_value)
% Function returns parameter value for a given p_value

temp_value = mod(p_value,2);
if (temp_value<1)
    parameter_value = par_structure.min_value + ...
        temp_value * ...
            (par_structure.max_value - par_structure.min_value);
else
    parameter_value = par_structure.max_value - ...
        (temp_value-1) * ...
            (par_structure.max_value - par_structure.min_value);
end
if (strcmp(par_structure.p_mode,'log'))
    parameter_value = 10^parameter_value;
end