function out_struct = ezread2(filename,varargin)
% Ezread modified by Ken to cope with header lines
params.delimiter='\t';
params.header_lines=0;

params=parse_pv_pairs(params,varargin);

% Unpack
fname=filename;
file_delim = params.delimiter;
header_lines=params.header_lines;

% Original code
out_struct = [];

% Open the file
fid = fopen(fname,'r');

if fid == -1
    % could not find the file
    error('File not found')
end

% Read header line
for i=1:header_lines
    temp=fgetl(fid);
end
header_str = fgetl(fid);

% Parse the header string into separate headers
header_cell = textscan(header_str,'%s','delimiter',file_delim);
header_cell = header_cell{1};

% Read the first line of data to determine the column data types
data = textscan(fid,'%s',length(header_cell),'delimiter',file_delim);
data = data{1};

% Check the contents of each column and contruct a column format specifier
% string
format_str = [];
for i = 1:length(data)
    % If str2num returns a numeric value, then the column in numeric,
    % otherwise if str2num returns empty, then the column is text
    if ~isempty(str2num(data{i}))
        col_format = '%f ';
    else
        col_format = '%s ';
    end
    format_str = [format_str col_format];
end

% Move back to the start of the file
frewind(fid)

% Read the entire file using the new column format specifier string
data = textscan(fid,format_str,'delimiter',file_delim, ...
    'headerlines',1+header_lines);

% Loop through each column of data and create a field in a structure for
% each column of data.  The fieldnames are based on the headers in the file
for i = 1:length(data)
    % Get the current header
    cur_hdr = header_cell{i};
    
    % Remove/replace standard non-compatibile parts of headers
    cur_hdr = strrep(cur_hdr,'"','');
    cur_hdr = strrep(cur_hdr,'#','_no');
    
    % Use the "genvarname" function to modify the header to handles any 
    % other parts of the header that would make the header an invalid
    % variable name
    cur_hdr = genvarname(cur_hdr);
    out_struct.(cur_hdr) = data{i};
end

fclose(fid);
