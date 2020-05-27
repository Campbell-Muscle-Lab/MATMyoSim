function demo_twitch_1
% Function illustrates how to run a simulation of a single-half-sarcomere
% held isometric and activated by a transient pulse of Ca2+

% Variables
protocol_file_string = 'protocol.txt';
model_parameters_json_file_string = 'myofibril_1_model.json';
options_file_string = 'myofibril_1_options.json';
model_output_file_string = '..\..\temp\myofibril_1_output.myo';
movie_file_string = '..\..\temp\myofibril_1_movie.avi';

protocol_file_string = 'protocol.txt';
model_parameters_json_file_string = 'myofibril_4_model.json';
options_file_string = 'myofibril_1_options.json';
model_output_file_string = '..\..\temp\myofibril_4_output.myo';
movie_file_string = '..\..\temp\myofibril_4_movie.avi';


% base of temp image file for movie_frames
base_temp_image_file_string = '..\..\temp\frame';

% Make sure the path allows us to find the right files
addpath(genpath('..\..\..\..\code'));

if (1)

% Generate a protocol
generate_isometric_pCa_protocol( ...
    'time_step', 0.001, ...
    'no_of_points', 2000, ...
    't_start_s', 0.1, ...
    't_stop_s', 1.5, ...
    'during_pCa', 4.5, ...
    'output_file_string', protocol_file_string);

% Run a simulation
sim_output = simulation_driver( ...
    'simulation_protocol_file_string', protocol_file_string, ...
    'model_json_file_string', model_parameters_json_file_string, ...
    'options_json_file_string', options_file_string, ...
    'output_file_string', model_output_file_string);

end

% Animate the myofibril
image_file_strings = animate_MyoSim_myofibril( ...
    'model_output_file_string', model_output_file_string, ...
    'output_file_string', base_temp_image_file_string, ...
    'skip_frame',10);

% c =0;
% for i=1:10:1991
%     c = c+1;
%     image_file_strings{c} = sprintf('..\\..\\temp\\frame_%.0f.png',i);
% end
% 
% ifs = image_file_strings'
% 

write_image_files_to_movie(image_file_strings, ...
    movie_file_string, ...
    'brand_string','');

% Delete the still frames
try
    for i=1:numel(image_file_strings)
        delete(image_file_strings{i})
    end
end
