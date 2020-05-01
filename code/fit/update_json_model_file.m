function update_json_model_file(original_json_model_file_string, ...
    new_json_model_file_string,par_structure,p_vector)
% Function creates a new model file based on opt structure and p vector

% Read in original file
in_file = fopen(original_json_model_file_string,'r');
counter = 0;
while(~feof(in_file))
    counter = counter+1;
    json_file{counter} = fgetl(in_file);
end
fclose(in_file);

% Scan through file for optimization structure
for i=1:numel(par_structure)
    search_string = sprintf('%s',par_structure{i}.name);
    for j=1:numel(json_file);
        vi = regexp(json_file{j},search_string);
        if (~isempty(vi))
            t = regexp(json_file{j},':');
            if (json_file{j}(end)==',')
                last_comma = 1;
            else
                last_comma = 0;
            end
            
            parameter_value = return_parameter_value( ...
                par_structure{i}, p_vector(i));

            json_file{j} = sprintf('%s %g', ...
                json_file{j}(1:t),parameter_value);
            if (last_comma)
                json_file{j} = sprintf('%s,',json_file{j});
            end
         end
    end
end

% Write it out
out_file = fopen(new_json_model_file_string,'w');
for j=1:numel(json_file)
    fprintf(out_file,'%s\n',json_file{j});
end
fclose(out_file);
