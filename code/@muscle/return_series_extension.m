function series_extension = return_series_extension(obj,muscle_force)
% Function returns force in series element

series_extension = muscle_force / obj.series_k_linear;