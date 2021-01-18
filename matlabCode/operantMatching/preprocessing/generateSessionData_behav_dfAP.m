function outputStruct = generateSessionData_behav_dfAP(behavioralDataPath, pathData, varargin)
% generateSessionData_behav_df    Generate data structure for individual session
%   INPUTS
%       behavioralDataPath: full data path to .asc file
%           e.g.: 'G:\BB041\mBB041d20161006\behavior\mBB041d20161006.asc'
%       pathData: path structure generated by loadBehavioralData_oM()
%       varargin
%           Root: default is Z:\;
%           Separator: default is \ (windows)
%   OUTPUTS
%       outputStruct
%           outputStruct.s: behavioral data structure
%           outputStruct.bs: vector of trials at block switch; each number is the first trial of each block
%           outputStruct.bp: cell array of block probabilities; format is left port / right port
%           outputStruct.settings: settings for particular session
%           outputStruct.pd: parsed session data

[root, sep] = currComputer();
p = inputParser;
% default parameters if none given

p.parse(varargin{:});

sessionText = importData_operantMatching(behavioralDataPath);

sessionData.trialType = [];
sessionData.stateType = [];
sessionData.trialEnd = [];
sessionData.CSon = [];
sessionData.licksL = [];
sessionData.licksR = [];
sessionData.rewardL = [];
sessionData.rewardR = [];
sessionData.rewardTime = [];
% baiting flags for Soltani and colleagues
sessionData.baitL = [];
sessionData.baitR = [];
sessionData.ManulWaterR = [];
sessionData.ManulWaterL = [];
sessionData.delayNlw = [];
sessionData.delaySideLick = [];
sessionData.AirpuffTimeOn = [];
sessionData.AirpuffTimeOff = [];
sessionData.lickAfterpuff = [];
states = {};
blockSwitch = 1;
blockProbs = {};
stateSwitch = 1;
sessionSettings = [];
beginSettings_flag = false;
i = 1;
while isempty(regexp(sessionText{i},'Block Switch at Trial ', 'once'))
    if contains(sessionText{i}, 'Random')
        beginSettings_flag = true;
    end
    if beginSettings_flag == true
        if contains(sessionText{i}, 'Random')
            tmp = regexp(sessionText{i}, ': ', 'split');
            sessionSettings.rnd = str2double(tmp{2});
        elseif contains(sessionText{i}, 'CS+')
            tmp = regexp(sessionText{i}, ': ', 'split');
            sessionSettings.CSplus = str2double(tmp{2});
        elseif contains(sessionText{i}, 'CS-')
            tmp = regexp(sessionText{i}, ': ', 'split');
            sessionSettings.CSminus = str2double(tmp{2});
%         else
%             tmp = regexp(sessionText{i}, ': ', 'split');
%             sessionSettings.(tmp{1}) = str2double(tmp{2});
        end
    end
    i = i + 1;
end
% blockProbs = [blockProbs {sessionText{i}(end-4:end)}];
tmp = regexp(sessionText(i), '= ', 'split');
blockProbs = [blockProbs tmp{1}{2}];
l = 1;
while isempty(regexp(sessionText{l},'stateType:', 'once'))
    l = l + 1;
end
tmp = regexp(sessionText(l), ': ', 'split');
states = [states tmp{1}{2}];
for i = 1:length(sessionText)
    % determine beginning and end of trial
    if regexp(sessionText{i},'Trial ') == 1 % trial begin 
        temp1 = regexp(sessionText{i},'('); temp2 = regexp(sessionText{i},')');
        currTrial = str2double(sessionText{i}(temp1(1)+1:temp2(1)-1)); % current trial is in between parentheses
        
        tBegin = i + 1; % first index of trial is where the text says 'CS '
%         while ~contains(sessionText{tBegin}, 'CS ') % while tBegin is NOT "CS " text
%             tBegin = tBegin + 1;
%         end
        
        tEndFlag = false;        
        j = tBegin + 1; % start looking for last index of trial
        while (~tEndFlag) 
            if regexp(sessionText{j},'Trial ') == 1
                tEnd = j - 1; 
                tEndFlag = true;
            else
                j = j + 1;
                if j == length(sessionText)
                    tEnd = length(sessionText);
                    tEndFlag = true;
                end
            end
        end
        if currTrial ~= 1
            if ~isempty(strfind(sessionText{i-2}, 'State Switch'))
                stateSwitch = [stateSwitch currTrial];
                temp5 = regexp(sessionText{i-2}, ': ', 'split');
                sessionData(currTrial).stateType = str2double(temp5{1,2});
            elseif ~isempty(strfind(sessionText{i-3}, 'State Switch'))
                stateSwitch = [stateSwitch currTrial];
                temp5 = regexp(sessionText{i-3}, ': ', 'split');
                sessionData(currTrial).stateType = str2double(temp5{1,2});
            else
                sessionData(currTrial).stateType = sessionData(currTrial-1).stateType ;
            end
        else
            sessionData(1).stateType = str2double(cell2mat(states(1)));
            %sessionData(1).stateType = 0; %starts with state 0/safe
        end  
        waterDeliverFlag = false;
        DoneManual = false;
        allL_licks = [];
        allR_licks = [];
%         % baiting flags for Soltani and colleagues
%         sessionData(currTrial).baitL = false;
%         sessionData(currTrial).baitR = false;
        for currTrialInd = tBegin:tEnd
            if ~isempty(strfind(sessionText{currTrialInd},'Number of Auto Pauses'))
              temp12 = regexp(sessionText{currTrialInd}, ': ', 'split');
              sessionData(currTrial).autopause = str2double(temp12(1,2));
            end
            if ~isempty(strfind(sessionText{currTrialInd},'Airpuff On'))
                if ~isempty(strfind(sessionText{currTrialInd},'Airpuff Off'))
                    temp6 = regexp(sessionText{currTrialInd}, ': ', 'split');
%                     temp7 = regexp(temp6{1,2}, ' ,', 'split');
                    temp7 = regexp(temp6{1,2}, ' ,', 'split');
                    sessionData(currTrial).AirpuffTimeOn = str2double(temp7{1,1});
%                     temp8 = regexp(temp6{1,2}, ' :', 'split');
%                     temp9 = temp8(1,2);
                     temp9 = temp6{1,3};
                    sessionData(currTrial).AirpuffTimeOff =str2double(temp9);
                else
                    if isempty(strfind(sessionText{currTrialInd+1},'Airpuff Off'))
                        temp10 = regexp(sessionText{currTrialInd+1}, ' :', 'split');
                        sessionData(currTrial).lickAfterpuff = 1;
                        temp11 = str2double(temp10(1,2));
                        sessionData(currTrial).AirpuffTimeOff = temp11;
                        sessionData(currTrial).AirpuffTimeOn =temp11+51;
                    end
                end
            end
            if strfind(sessionText{currTrialInd},'CS PLUS')
                sessionData(currTrial).trialType = 'CSplus';
                temp = regexp(sessionText(currTrialInd), ': ', 'split');
                sessionData(currTrial).CSon = str2double(temp{1}{2});
            elseif strfind(sessionText{currTrialInd},'CS MINUS')
                sessionData(currTrial).trialType = 'CSminus';
                temp = regexp(sessionText(currTrialInd), ': ', 'split');
                sessionData(currTrial).CSon = str2double(temp{1}{2});
            end
            if regexp(sessionText{currTrialInd},'L: ') == 1
                temp = regexp(sessionText(currTrialInd), ': ', 'split');
                allL_licks = [allL_licks str2double(temp{1}{2})];
            elseif regexp(sessionText{currTrialInd},'R: ') == 1
                temp = regexp(sessionText(currTrialInd), ': ', 'split');
                allR_licks = [allR_licks str2double(temp{1}{2})];
            end
            if (~waterDeliverFlag)
                if strfind(sessionText{currTrialInd},'WATER L DELIVERED')
                    temp = regexp(sessionText(currTrialInd), ': ', 'split');
                    sessionData(currTrial).rewardL = 1;
                    sessionData(currTrial).rewardR = NaN;
                    sessionData(currTrial).rewardTime = str2double(temp{1}{2});
                    waterDeliverFlag = true;
                elseif strfind(sessionText{currTrialInd},'WATER L NOT DELIVERED')
                    temp = regexp(sessionText(currTrialInd), ': ', 'split');
                    sessionData(currTrial).rewardL = 0;
                    sessionData(currTrial).rewardR = NaN;
                    sessionData(currTrial).rewardTime = str2double(temp{1}{2});
                    waterDeliverFlag = true;
                elseif strfind(sessionText{currTrialInd},'WATER R DELIVERED')
                    temp = regexp(sessionText(currTrialInd), ': ', 'split');
                    sessionData(currTrial).rewardR = 1;
                    sessionData(currTrial).rewardL = NaN;
                    sessionData(currTrial).rewardTime = str2double(temp{1}{2});
                    waterDeliverFlag = true;
                elseif strfind(sessionText{currTrialInd},'WATER R NOT DELIVERED')
                    temp = regexp(sessionText(currTrialInd), ': ', 'split');
                    sessionData(currTrial).rewardR = 0;
                    sessionData(currTrial).rewardL = NaN;
                    sessionData(currTrial).rewardTime = str2double(temp{1}{2});
                    waterDeliverFlag = true;
                end
            end
            if (~DoneManual)
                if strfind(sessionText{currTrialInd},'L port - Manual Water Delivered') 
                       temp = regexp(sessionText(currTrialInd), ': ', 'split');
                       sessionData(currTrial).ManulWaterL = str2double(temp{1}{2});
                       DoneManual = true;
                end
                if strfind(sessionText{currTrialInd},'R port - Manual Water Delivered')
                        temp = regexp(sessionText(currTrialInd), ': ', 'split');
                        sessionData(currTrial).ManulWaterR = str2double(temp{1}{2});
                        DoneManual = true;
                end
            end
%             % baiting flags for Soltani and colleagues
%             if regexp(sessionText{currTrialInd},'L port baited')
%                 sessionData(currTrial).baitL = true;
%             end
%             if regexp(sessionText{currTrialInd},'R port baited')
%                 sessionData(currTrial).baitR = true;
%             end
            
            if currTrialInd == tEnd % run this at the last index || currTrialInd == length(sessionText)-1
                sessionData(currTrial).licksL = allL_licks;
                sessionData(currTrial).licksR = allR_licks;
                if isempty(sessionData(currTrial).AirpuffTimeOn)
                    sessionData(currTrial).AirpuffTimeOn = 0;
                end
                if ~waterDeliverFlag
                    sessionData(currTrial).rewardL = NaN;
                    sessionData(currTrial).rewardR = NaN;
                    sessionData(currTrial).rewardTime = NaN;
                end
                 if ~DoneManual 
                    sessionData(currTrial).ManulWaterL = NaN;
                    sessionData(currTrial).ManulWaterR = NaN;
                end
                if tEnd ~= length(sessionText)
                    temp = regexp(sessionText(currTrialInd + 1), ': ', 'split');
                    sessionData(currTrial).trialEnd = str2double(temp{1}{2});
                else
                    sessionData(currTrial).trialEnd = NaN;
                end
            end
            if regexp(sessionText{currTrialInd},'Block Switch at Trial ') == 1
                if currTrial ~= 1
                    blockSwitch = [blockSwitch currTrial+1];
%                     blockProbs = [blockProbs {sessionText{currTrialInd}(end-4:end)}];
                    tmp = regexp(sessionText(currTrialInd), '= ', 'split');
                    blockProbs = [blockProbs tmp{1}{2}];
                end
            end
            if ~isempty(strfind(sessionText{currTrialInd},'Delayed'))
                 temp = regexp(sessionText(currTrialInd), ': ', 'split');
                 sessionData(currTrial).delayNlw = str2double(temp{1}{2});
                 ld = 0;
                 if ~isempty(strfind(sessionText{currTrialInd},'L:'))
                 ld  = ld +1;
                 end
                 rd = 0;
                 if ~isempty(strfind(sessionText{currTrialInd},'R:'))
                     rd =rd +1;
                 end
                 if ld >= rd
                 sessionData(currTrial).delaySideLick = ['L', ld, rd];
                 elseif rd >= ld
                 sessionData(currTrial).delaySideLick = ['R', ld, rd];
                 end
            end
        end
    end
end

% correct block switch when it repeatedly chooses blocks until it finds a good one
% this is for the multipleProbabilities version of the task
blockSwitch_no_repeat_ind = find([diff(blockSwitch) NaN] ~= 0); % NaN at end ensures last block will always be included
blockSwitch = blockSwitch(blockSwitch_no_repeat_ind);
blockProbs = blockProbs(blockSwitch_no_repeat_ind);

outputStruct.s = sessionData;
outputStruct.settings = sessionSettings;
outputStruct.bp = blockProbs;
outputStruct.bs = blockSwitch;
outputStruct.stateSwitch = stateSwitch;
% append parsed, easily-analyzable data structure
outputStruct =  parseBehavioralDataAP(outputStruct, blockSwitch, blockProbs, stateSwitch);
% append pathData
outputStruct.pathData = pathData;

savepath = [behavioralDataPath(1:strfind(behavioralDataPath,'behavior')-1) 'sorted' sep];
if isempty(dir(savepath))
    mkdir(savepath)
end

f_IndA = find(behavioralDataPath==sep,1,'last');
f_IndB = strfind(behavioralDataPath,'.asc');
filename = behavioralDataPath(f_IndA+1:f_IndB-1);

save([savepath filename '_sessionData_fullStruct.mat'], 'outputStruct');
end

function dataOutput = importData_operantMatching(filename, startRow, endRow)


% Initialize variables.
delimiter = '';
if nargin<=2
    startRow = 1;
    endRow = inf;
end

% Format string for each line of text:
%   column1: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%[^\n\r]';

% Open the text file.
fileID = fopen(filename,'r');

% Read columns of data according to format string.
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

% Close the text file.
fclose(fileID);

% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

% Create output variable
dataOutput = [dataArray{1:end-1}];
end