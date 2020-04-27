function update_xml_model_file(original_xml_model_file_string, ...
    new_xml_model_file_string,opt_structure,p_vector)
% Function creates a new model file based on opt structure and p vector

% Read in original file
in_file = fopen(original_xml_model_file_string,'r');
counter = 0;
while(~feof(in_file))
    counter = counter+1;
    xml_file{counter} = fgetl(in_file);
end
fclose(in_file);

op = opt_structure
pv = p_vector

% Scan through file for optimization structure
for i=1:numel(opt_structure)
    search_string = sprintf('<%s>',opt_structure(i).name);
    for j=1:numel(xml_file);
        vi = regexp(xml_file{j},search_string);
        if (~isempty(vi))
            [t,u] = regexp(xml_file{j},'>(\w+).*<','tokens','match');
            temp_value = mod(p_vector(i),2);
            if (temp_value<1)
                parameter_value = opt_structure(i).min_value + ...
                    temp_value * ...
                        (opt_structure(i).max_value - opt_structure(i).min_value);
            else
                parameter_value = opt_structure(i).max_value - ...
                    (temp_value-1) * ...
                        (opt_structure(i).max_value - opt_structure(i).min_value);
            end
            if (strcmp(opt_structure(i).p_mode,'log'))
                parameter_value = 10^parameter_value;
            end
            xml_file{j} = strrep(xml_file{j},u{1},sprintf('>%.6g<',parameter_value));
         end
    end
end

% Write it out
out_file = fopen(new_xml_model_file_string,'w');
for j=1:numel(xml_file)
    fprintf(out_file,'%s\n',xml_file{j});
end
fclose(out_file);
