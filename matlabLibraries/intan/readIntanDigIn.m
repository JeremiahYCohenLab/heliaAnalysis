function [board_dig_in_data] = readIntanDigIn(path, file)

tic;
filename = [path,file];
fid = fopen(filename, 'r');

s = dir(filename);
filesize = s.bytes;

% Check 'magic number' at beginning of file to make sure this is an Intan
% Technologies RHD2000 data file.
magic_number = fread(fid, 1, 'uint32');
if magic_number ~= hex2dec('c6912702')
    error('Unrecognized file type.');
end

% Read version number.
data_file_main_version_number = fread(fid, 1, 'int16');
data_file_secondary_version_number = fread(fid, 1, 'int16');


if (data_file_main_version_number == 1)
    num_samples_per_data_block = 60;
else
    num_samples_per_data_block = 128;
end

% If data file is from GUI v1.3 or later, load eval board mode.
eval_board_mode = 0;
if ((data_file_main_version_number == 1 && data_file_secondary_version_number >= 3) ...
    || (data_file_main_version_number > 1))
    eval_board_mode = fread(fid, 1, 'int16');
end

% If data file is from v2.0 or later (Intan Recording Controller),
% load name of digital reference channel.
if (data_file_main_version_number > 1)
    reference_channel = fread_QString(fid);
end

% Define data structure for data channels.
channel_struct = struct( ...
    'native_channel_name', {}, ...
    'custom_channel_name', {}, ...
    'native_order', {}, ...
    'custom_order', {}, ...
    'board_stream', {}, ...
    'chip_channel', {}, ...
    'port_name', {}, ...
    'port_prefix', {}, ...
    'port_number', {}, ...
    'electrode_impedance_magnitude', {}, ...
    'electrode_impedance_phase', {} );

new_channel = struct(channel_struct);

% Create structure arrays for each type of data channel.
board_dig_in_channels = struct(channel_struct);
board_dig_in_index = 1;


% Read signal summary from data file header.

number_of_signal_groups = fread(fid, 1, 'int16');

for signal_group = 1:number_of_signal_groups
    signal_group_name = fread_QString(fid);
    signal_group_prefix = fread_QString(fid);
    signal_group_enabled = fread(fid, 1, 'int16');
    signal_group_num_channels = fread(fid, 1, 'int16');
    signal_group_num_amp_channels = fread(fid, 1, 'int16');

    if (signal_group_num_channels > 0 && signal_group_enabled > 0)
        new_channel(1).port_name = signal_group_name;
        new_channel(1).port_prefix = signal_group_prefix;
        new_channel(1).port_number = signal_group;
        for signal_channel = 1:signal_group_num_channels
            new_channel(1).native_channel_name = fread_QString(fid);
            new_channel(1).custom_channel_name = fread_QString(fid);
            new_channel(1).native_order = fread(fid, 1, 'int16');
            new_channel(1).custom_order = fread(fid, 1, 'int16');
            signal_type = fread(fid, 1, 'int16');
            channel_enabled = fread(fid, 1, 'int16');
            new_channel(1).chip_channel = fread(fid, 1, 'int16');
            new_channel(1).board_stream = fread(fid, 1, 'int16');
            new_trigger_channel(1).voltage_trigger_mode = fread(fid, 1, 'int16');
            new_trigger_channel(1).voltage_threshold = fread(fid, 1, 'int16');
            new_trigger_channel(1).digital_trigger_channel = fread(fid, 1, 'int16');
            new_trigger_channel(1).digital_edge_polarity = fread(fid, 1, 'int16');
            new_channel(1).electrode_impedance_magnitude = fread(fid, 1, 'single');
            new_channel(1).electrode_impedance_phase = fread(fid, 1, 'single');
            
            if (channel_enabled)
                switch (signal_type)
                    case 0
                        amplifier_channels(amplifier_index) = new_channel;
                        spike_triggers(amplifier_index) = new_trigger_channel;
                        amplifier_index = amplifier_index + 1;
                    case 1
                        aux_input_channels(aux_input_index) = new_channel;
                        aux_input_index = aux_input_index + 1;
                    case 2
                        supply_voltage_channels(supply_voltage_index) = new_channel;
                        supply_voltage_index = supply_voltage_index + 1;
                    case 3
                        board_adc_channels(board_adc_index) = new_channel;
                        board_adc_index = board_adc_index + 1;
                    case 4
                        board_dig_in_channels(board_dig_in_index) = new_channel;
                        board_dig_in_index = board_dig_in_index + 1;
                    case 5
                        board_dig_out_channels(board_dig_out_index) = new_channel;
                        board_dig_out_index = board_dig_out_index + 1;
                    otherwise
                        error('Unknown channel type');
                end
            end
            
        end
    end
end

% Summarize contents of data file.
num_board_dig_in_channels = board_dig_in_index - 1;


% Determine how many samples the data file contains.

% Each data block contains num_samples_per_data_block amplifier samples.
% Board digital inputs are sampled at same rate as amplifiers
if (num_board_dig_in_channels > 0)
    bytes_per_block = bytes_per_block + num_samples_per_data_block * 2;
end

% How many data blocks remain in this file?
data_present = 0;
bytes_remaining = filesize - ftell(fid);
if (bytes_remaining > 0)
    data_present = 1;
end

num_data_blocks = bytes_remaining / bytes_per_block;
num_board_dig_in_samples = num_samples_per_data_block * num_data_blocks;

record_time = num_board_dig_in_samples / sample_rate;


if (data_present)
    
    % Pre-allocate memory for data.
    board_dig_in_data = zeros(num_board_dig_in_channels, num_board_dig_in_samples);

    % Read sampled data from file.
    board_dig_in_index = 1;

    print_increment = 10;
    percent_done = print_increment;
    for i=1:num_data_blocks
        % In version 1.2, we moved from saving timestamps as unsigned
        % integeters to signed integers to accomidate negative (adjusted)
        % timestamps for pretrigger data.
        if ((data_file_main_version_number == 1 && data_file_secondary_version_number >= 2) ...
        || (data_file_main_version_number > 1))
            t_amplifier(amplifier_index:(amplifier_index + num_samples_per_data_block - 1)) = fread(fid, num_samples_per_data_block, 'int32');
        else
            t_amplifier(amplifier_index:(amplifier_index + num_samples_per_data_block - 1)) = fread(fid, num_samples_per_data_block, 'uint32');
        end
        if (num_board_dig_in_channels > 0)
            board_dig_in_raw(board_dig_in_index:(board_dig_in_index + num_samples_per_data_block - 1)) = fread(fid, num_samples_per_data_block, 'uint16');
        end

        board_dig_in_index = board_dig_in_index + num_samples_per_data_block;
    end

    % Make sure we have read exactly the right amount of data.
    bytes_remaining = filesize - ftell(fid);
    if (bytes_remaining ~= 0)
        %error('Error: End of file not reached.');
    end

end

% Close data file.
fclose(fid);

if (data_present)
    
%     fprintf(1, 'Parsing data...\n');

    % Extract digital input channels to separate variables.
    for i=1:num_board_dig_in_channels
       mask = 2^(board_dig_in_channels(i).native_order) * ones(size(board_dig_in_raw));
       board_dig_in_data(i, :) = (bitand(board_dig_in_raw, mask) > 0);
    end



    % Check for gaps in timestamps.
    num_gaps = sum(diff(t_amplifier) ~= 1);
    if (num_gaps == 0)
 %       fprintf(1, 'No missing timestamps in data.\n');
    else
        fprintf(1, 'Warning: %d gaps in timestamp data found.  Time scale will not be uniform!\n', ...
            num_gaps);
    end

    % Scale time steps (units = seconds).
    t_amplifier = t_amplifier / sample_rate;
    t_dig = t_amplifier;

    % If the software notch filter was selected during the recording, apply the
    % same notch filter to amplifier data here.
    if (notch_filter_frequency > 0)
 %       fprintf(1, 'Applying notch filter...\n');

        print_increment = 10;
        percent_done = print_increment;
        for i=1:num_amplifier_channels
            amplifier_data(i,:) = ...
                notch_filter(amplifier_data(i,:), sample_rate, notch_filter_frequency, 10);

            fraction_done = 100 * (i / num_amplifier_channels);
            if (fraction_done >= percent_done)
 %               fprintf(1, '%d%% done...\n', percent_done);
                percent_done = percent_done + print_increment;
            end

        end
    end

end

% Move variables to base workspace.

% new for version 2.01: move filename info to base workspace
filename = file;
move_to_base_workspace(filename);
move_to_base_workspace(path);

move_to_base_workspace(notes);
move_to_base_workspace(frequency_parameters);
if (data_file_main_version_number > 1)
    move_to_base_workspace(reference_channel);
end

if (num_amplifier_channels > 0)
    move_to_base_workspace(amplifier_channels);
    if (data_present)
        move_to_base_workspace(amplifier_data);
        move_to_base_workspace(t_amplifier);
    end
    move_to_base_workspace(spike_triggers);
end
if (num_aux_input_channels > 0)
    move_to_base_workspace(aux_input_channels);
    if (data_present)
        move_to_base_workspace(aux_input_data);
        move_to_base_workspace(t_aux_input);
    end
end
if (num_supply_voltage_channels > 0)
    move_to_base_workspace(supply_voltage_channels);
    if (data_present)
        move_to_base_workspace(supply_voltage_data);
        move_to_base_workspace(t_supply_voltage);
    end
end
if (num_board_adc_channels > 0)
    move_to_base_workspace(board_adc_channels);
    if (data_present)
        move_to_base_workspace(board_adc_data);
        move_to_base_workspace(t_board_adc);
    end
end
if (num_board_dig_in_channels > 0)
    move_to_base_workspace(board_dig_in_channels);
    if (data_present)
        move_to_base_workspace(board_dig_in_data);
        move_to_base_workspace(t_dig);
    end
end
if (num_board_dig_out_channels > 0)
    move_to_base_workspace(board_dig_out_channels);
    if (data_present)
        move_to_base_workspace(board_dig_out_data);
        move_to_base_workspace(t_dig);
    end
end
if (num_temp_sensor_channels > 0)
    if (data_present)
        move_to_base_workspace(temp_sensor_data);
        move_to_base_workspace(t_temp_sensor);
    end
end

% fprintf(1, 'Done!  Elapsed time: %0.1f seconds\n', toc);
% if (data_present)
%     fprintf(1, 'Extracted data are now available in the MATLAB workspace.\n');
% else
%     fprintf(1, 'Extracted waveform information is now available in the MATLAB workspace.\n');
% end
% fprintf(1, 'Type ''whos'' to see variables.\n');
% fprintf(1, '\n');

return


function a = fread_QString(fid)

% a = read_QString(fid)
%
% Read Qt style QString.  The first 32-bit unsigned number indicates
% the length of the string (in bytes).  If this number equals 0xFFFFFFFF,
% the string is null.

a = '';
length = fread(fid, 1, 'uint32');
if length == hex2num('ffffffff')
    return;
end
% convert length from bytes to 16-bit Unicode words
length = length / 2;

for i=1:length
    a(i) = fread(fid, 1, 'uint16');
end

return


function s = plural(n)

% s = plural(n)
% 
% Utility function to optionally plurailze words based on the value
% of n.

if (n == 1)
    s = '';
else
    s = 's';
end

return


function out = notch_filter(in, fSample, fNotch, Bandwidth)

% out = notch_filter(in, fSample, fNotch, Bandwidth)
%
% Implements a notch filter (e.g., for 50 or 60 Hz) on vector 'in'.
% fSample = sample rate of data (in Hz or Samples/sec)
% fNotch = filter notch frequency (in Hz)
% Bandwidth = notch 3-dB bandwidth (in Hz).  A bandwidth of 10 Hz is
%   recommended for 50 or 60 Hz notch filters; narrower bandwidths lead to
%   poor time-domain properties with an extended ringing response to
%   transient disturbances.
%
% Example:  If neural data was sampled at 30 kSamples/sec
% and you wish to implement a 60 Hz notch filter:
%
% out = notch_filter(in, 30000, 60, 10);

tstep = 1/fSample;
Fc = fNotch*tstep;

L = length(in);

% Calculate IIR filter parameters
d = exp(-2*pi*(Bandwidth/2)*tstep);
b = (1 + d*d)*cos(2*pi*Fc);
a0 = 1;
a1 = -b;
a2 = d*d;
a = (1 + d*d)/2;
b0 = 1;
b1 = -2*cos(2*pi*Fc);
b2 = 1;

out = zeros(size(in));
out(1) = in(1);  
out(2) = in(2);
% (If filtering a continuous data stream, change out(1) and out(2) to the
%  previous final two values of out.)

% Run filter
for i=3:L
    out(i) = (a*b2*in(i-2) + a*b1*in(i-1) + a*b0*in(i) - a2*out(i-2) - a1*out(i-1))/a0;
end

return


function move_to_base_workspace(variable)

% move_to_base_workspace(variable)
%
% Move variable from function workspace to base MATLAB workspace so
% user will have access to it after the program ends.

variable_name = inputname(1);
assignin('base', variable_name, variable);

return;
