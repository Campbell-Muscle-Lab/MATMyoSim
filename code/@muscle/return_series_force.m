function series_force = return_series_force(obj,series_extension)
% Function returns force in series element

series_force = obj.series_k_linear * series_extension;