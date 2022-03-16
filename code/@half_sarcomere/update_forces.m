function update_forces(obj, time_step, delta_hsl)

[obj.m_force, obj.c_force] = return_distrib_force(obj, time_step, delta_hsl);

obj.int_passive_force = ...
    obj.return_intracellular_passive_force(obj.hs_length);

obj.ext_passive_force = ...
    obj.return_extracellular_passive_force(obj.hs_length);

obj.viscous_force = (1 - obj.parameters.prop_fibrosis) * ...
                        obj.parameters.prop_myofilaments * ...
                    obj.parameters.viscosity * delta_hsl / time_step;

obj.int_total_force = obj.m_force + obj.c_force + obj.int_passive_force;

obj.hs_force = obj.m_force + obj.c_force + obj.int_passive_force + ...
    obj.viscous_force + obj.ext_passive_force;