function delayAssesment(sessionName) 


[root, sep] = currComputer();
[animalName, date] = strtok(sessionName, 'd'); 
animalName = animalName(2:end);
date = date(1:9);
sessionFolder = ['m' animalName date];
behavioralDataPath = [root animalName sep sessionFolder sep 'behavior' sep sessionName '.asc'];
sessionText = importData_operantMatching(behavioralDataPath);
countdelay = 0;

[behSessionData, blockSwitch, blockSwitchL, blockSwitchR] = generateSessionData_operantMatchingDecoupled(sessionName);
 delayTime = [];
for i= 1:length(sessionText) 
    if regexp(sessionText{i},'Delayed:') == 1
        countdelay = countdelay +1;
    end
    if ~isempty(strfind(sessionText{currTrialInd}, 'Delayed'))
                temp = regexp(sessionText{currTrialInd}, ': ', 'split');
                delayTime = [delayTime str2double(temp(1,2))];
     end
end
    
function dataOutput = importData_operantMatching(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as a matrix.
%   MBB039D20160712 = IMPORTFILE(FILENAME) Reads data from text file
%   FILENAME for the default selection.
%
%   MBB039D20160712 = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data
%   from rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   mBB039d20160712 = importfile('mBB039d20160712.asc', 1, 5986);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2016/07/12 16:31:53

%% Initialize variables.
delimiter = '';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'ReturnOnError', false);
    dataArray{1} = [dataArray{1};dataArrayBlock{1}];
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
dataOutput = [dataArray{1:end-1}];
end     
end