function im_file_strings = animate_MyoSim_myofibril(varargin)
% Code animates a MyoSim model

p = inputParser;
addOptional(p,'model_output_file_string', []);
addOptional(p,'thin_length',1120);
addOptional(p,'thin_y_pos',10);
addOptional(p,'thin_color',[1 0 0]);
addOptional(p,'thin_width',3);
addOptional(p,'thick_length',815);
addOptional(p,'thick_y_pos',-10);
addOptional(p,'thick_color',[0 0 1]);
addOptional(p,'thick_width',7);
addOptional(p,'z_height',40);
addOptional(p,'z_width',12);
addOptional(p,'z_color',[1 0 1]);
addOptional(p,'m_height',30);
addOptional(p,'m_width',8);
addOptional(p,'m_color',[0 1 0]);
addOptional(p,'block_width',500);
addOptional(p,'block_height',20);
addOptional(p,'block_color',0.2*[1 1 1]);
addOptional(p,'series_width',10);
addOptional(p,'series_color',[0 0.3 0]);
addOptional(p,'cantilever_width', 5);
addOptional(p,'cantilever_color', [0 0 0]);
addOptional(p,'figure_number',[]);
addOptional(p,'skip_frame',1);
addOptional(p,'output_file_string', []);
addOptional(p,'output_type','png');

% Update
parse(p,varargin{:});
p = p.Results;

% Code
if (isempty(p.figure_number))
    p.figure_number == 1;
end

figure(p.figure_number);
sp = initialise_publication_quality_figure( ...
    'no_of_panels_wide',1, ...
    'no_of_panels_high',1, ...
    'right_margin',-5, ...
    'x_to_y_axes_ratio',20, ...
    'top_margin',0.5, ...
    'axes_padding_bottom',0.1, ...
    'bottom_margin',0);
subplot(sp(1));
hold on;

% Load up the simulation
sim = load(p.model_output_file_string, '-mat');
sim_output = sim.sim_output

% Pull out data
[no_of_time_points, no_of_half_sarcomeres] = size(sim_output.hs_length);

% Load in data
lhs = zeros(no_of_time_points, no_of_half_sarcomeres);
for i=1 : no_of_half_sarcomeres
    hs(:,i) = sim_output.hs_length(:, i);
end

muscle_length = sim_output.muscle_length;
series_extension = sim_output.series_extension;


rhs = cumsum(hs,2)+(0.5*repmat(series_extension,[1 no_of_half_sarcomeres]));
lhs = rhs - hs;

flag = 0;
im_counter = 0;

for i=1:p.skip_frame:no_of_time_points

    cla;
   
    % Draw
    for j=1 : no_of_half_sarcomeres
        draw_half_sarcomere(j,lhs(i,j),rhs(i,j));
    end
    
    % Draw cantilevers
    plot([0 lhs(i,1)], [-5 * p.block_height 0], '-', ...
        'LineWidth', p.cantilever_width, ...
        'Color', p.cantilever_color);
    
    plot([muscle_length(i) rhs(i,end)], [-5 * p.block_height 0], '-', ...
        'LineWidth', p.cantilever_width, ...
        'Color', p.cantilever_color);
%     
%     % Draw Block
%     patch([0 0 -p.block_width*[1 1]], ...
%         p.block_height*[-1 1 1 -1], ...
%         p.block_color);
%     
%     patch(muscle_length(i)+[0 0 p.block_width*[1 1]], ...
%         p.block_height*[-1 1 1 -1], ...
%         p.block_color);
%     
%     % Draw series spring
%     plot([0 0.5*series_extension(i)],[0 0],'-', ...
%         'Color',p.series_color, ...
%         'LineWidth',p.series_width);
%     
%     plot(muscle_length(i)+[0 -0.5*series_extension(i)],[0 0],'-', ...
%         'Color',p.series_color, ...
%         'LineWidth',p.series_width);
    
    text(0.5*muscle_length(i),4*p.block_height,sprintf('Time: %.3f s', sim_output.time_s(i)));
    
    ylim([-6*p.block_height 1.2*p.block_height]);
    xlim([-1000 muscle_length(i)+1500]);
    set(gca,'Visible','off');
  
    drawnow;

    im_counter = im_counter + 1;
    temp_file_string = sprintf('%s_%.0f', p.output_file_string, i);
    im_file_strings{im_counter} = sprintf('%s.%s', ...
        temp_file_string, p.output_type);
    
%     print(temp_file_string,'-dpng');
    figure_export( ...
        'output_file_string', temp_file_string, ...
        'output_type',p.output_type, ...
        'dpi',150);
end

    % Nested functions
    
    function draw_half_sarcomere(k,x_lhs,x_rhs)
        polarity = mod(k,2);
        if (polarity==1)
            
            plot(x_lhs + [0 0],p.z_height*[1 -1], ...
                'Color',p.z_color, ...
                'LineWidth',p.z_width);
           
            plot(x_lhs+[0 p.thin_length], ...
                p.thin_y_pos*[1 1],'-', ...
                'Color',p.thin_color, ...
                'LineWidth',p.thin_width);
            
            plot(x_rhs - [0 p.thick_length], ...
                p.thick_y_pos*[1 1],'-', ...
                'Color',p.thick_color, ...
                'LineWidth',p.thick_width);
            
            plot(x_rhs + [0 0],p.m_height*[1 -1], ...
                'Color',p.m_color, ...
                'LineWidth',p.m_width);
            
            text((x_lhs+x_rhs)/2, 2*p.block_height, sprintf('%.0f',k), ...
                'HorizontalAlignment','center');
        else
            plot(x_rhs + [0 0],p.z_height*[1 -1], ...
                'Color',p.z_color, ...
                'LineWidth',p.z_width);
            
            plot(x_rhs - [0 p.thin_length], ...
                p.thin_y_pos*[1 1],'-', ...
                'Color',p.thin_color, ...
                'LineWidth',p.thin_width);
            
            plot(x_lhs + [0 p.thick_length], ...
                p.thick_y_pos*[1 1],'-', ...
                'Color',p.thick_color, ...
                'LineWidth',p.thick_width);
            
            plot(x_lhs + [0 0],p.m_height*[1 -1], ...
                'Color',p.m_color, ...
                'LineWidth',p.m_width);
            
            text((x_lhs+x_rhs)/2, 2*p.block_height, sprintf('%.0f',k), ...
                'HorizontalAlignment','center');
        end
    end

end
            

