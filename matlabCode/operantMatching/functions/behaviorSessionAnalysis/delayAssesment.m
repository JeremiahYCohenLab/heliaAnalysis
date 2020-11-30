function delayAssesment(sessionName, revForFlag) 


[root, sep] = currComputer();
[animalName, date] = strtok(sessionName, 'd'); 
animalName = animalName(2:end);
date = date(1:9);
sessionFolder = ['m' animalName date];
blockProbs = {};
% if isstrprop(sessionName(end), 'alpha')
%     behavioralDataPath = [root animalName sep sessionFolder sep 'sortedTraining' sep 'session ' sessionName(end) sep sessionName '_behSessionData_behav.mat'];
% else
%     behavioralDataPath = [root animalName sep sessionFolder sep 'sortedTraining' sep 'session' sep sessionName '_sessionData_behav.mat'];
% end
% 
behavioralDataPath = [root animalName sep sessionFolder sep 'behavior' sep sessionName '.asc'];
sessionText = importData_operantMatching(behavioralDataPath);
% if revForFlag  
%     if exist(behavioralDataPath,'file')
%         load(behavioralDataPath);
%         behSessionData = sessionData;
%     else
%             [behSessionData, blockSwitch, blockProbs] = generateSessionData_behav_operantMatchingTraining(sessionName);
%     end
% else
%         if exist(behavioralDataPath,'file')
%             load(behavioralDataPath);
%         else
%             [behSessionData, blockSwitch, blockSwitchL, blockSwitchR] = generateSessionData_operantMatchingDecoupledTraining(sessionName);
%         end
% end
blockSwitch = 1;
blockSwitchL = 1;
blockSwitchR = 1;
lickCount = 0;
delayHappened = 0;
% delayTime = zeros(length(behSessionData),1);
% delayHappened = zeros(length(behSessionData),1);
delayTime = [];
delayMatx = [];
% allLick_R = find(~isnan([behSessionData.rewardTime]));
if revForFlag == 0
    for i = 1:length(sessionText)
        if ~isempty(strfind(sessionText{i}, 'Delayed'))
            lickCount = lickCount +1;
        end
    % determine beginning and end of trial
        if regexp(sessionText{i},'L Trial ') % trial begin 
            temp1 = regexp(sessionText{i},'('); temp2 = regexp(sessionText{i},')');
            currTrial = str2double(sessionText{i}(temp1(1)+1:temp2(1)-1)); % current trial is in between parentheses
            tBegin = i; % first index of trial is where the text says 'Trial '
            tEndFlag = false;        
            j = i + 1; % start looking for last index of trial
            while (~tEndFlag) 
                if regexp(sessionText{j},'L Trial ')
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
            for currTrialInd = tBegin+1:tEnd
                if strfind(sessionText{currTrialInd}, 'Contingency')
                    temp = regexp(sessionText{currTrialInd}, '). ', 'split');
                    temp2 = regexp(temp(1,2), '/', 'split');
                    behSessionData(currTrial).rewardProbL = str2double(temp2{1}{1});
                    temp3 = regexp(temp2{1}{2}, ':', 'split');
                    behSessionData(currTrial).rewardProbR = str2double(temp3(1,1));
                end
                if tEnd ~= length(sessionText)
                    temp = regexp(sessionText(tEnd+3), ': ', 'split');
                    behSessionData(currTrial).trialEnd = str2double(temp{1}{2});
                else
                    behSessionData(currTrial).trialEnd = NaN;
                end
                if regexp(sessionText{currTrialInd},'L Block Switch at Trial ')
                    if currTrial ~= 1
                        blockSwitch = [blockSwitch currTrial];
                        blockSwitchL = [blockSwitchL currTrial];
                    end
                end
                if regexp(sessionText{currTrialInd},'R Block Switch at Trial ')
                    if currTrial ~= 1
                        blockSwitch = [blockSwitch currTrial];
                        blockSwitchR = [blockSwitchR currTrial];
                    end
                end
                if regexp(sessionText{currTrialInd}, 'Delayed')
                     temp = regexp(sessionText{currTrialInd}, ': ', 'split');
                     delayTime = [delayTime str2double(temp(1,2))];
                     delayHappened =  delayHappened +1;   
                end   
                if delayHappened == 0 
                    delayMatx(currTrial) = 0;
                else
                    delayMatx(currTrial) = delayHappened;
                end
            end
            delayHappened = 0;
        end
    end
else
   m = 1;
    while isempty(regexp(sessionText{m},'Block Switch at Trial ', 'once'))
        m = m + 1;
    end
    blockProbs = [blockProbs {sessionText{m}(end-4:end)}];
    for i = 1:length(sessionText)
        if ~isempty(strfind(sessionText{i}, 'Delayed'))
            lickCount = lickCount +1;
        end
        % determine beginning and end of trial
        if regexp(sessionText{i},'Trial ') == 1 % trial begin 
            temp1 = regexp(sessionText{i},'('); temp2 = regexp(sessionText{i},')');
            currTrial = str2double(sessionText{i}(temp1(1)+1:temp2(1)-1)); % current trial is in between parentheses       
            tBegin = i; % first index of trial is where the text says 'Trial '
            tEndFlag = false;        
            j = i + 1; % start looking for last index of trial
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
            for currTrialInd = tBegin:tEnd
                 if ~isempty(strfind(sessionText{currTrialInd}, 'Delayed'))
                     temp = regexp(sessionText{currTrialInd}, ': ', 'split');
                     delayTime = [delayTime str2double(temp(1,2))];
                     delayHappened =  delayHappened +1;   
                 end
                 if regexp(sessionText{currTrialInd},'Block Switch at Trial ')
                    if currTrial ~= 1
                        blockSwitch = [blockSwitch currTrial];
                        blockProbs = [blockProbs {sessionText{currTrialInd}(end-4:end)}];
                    end
                 end
            end    
            if delayHappened == 0 
                delayMatx(currTrial) = 0;
            else
                delayMatx(currTrial) = delayHappened;
            end
            delayHappened = 0; 
        end
    end    
end
% allLicls_L(~isnan(behSessionData(1:end).licksL)) = size(behSessionData(1:end).licksL);


figure; hold on;
set(gcf, 'Position', get(0,'Screensize'))
title(sessionName);
subplot(2,1,1); hold on;
normKern = normpdf(-15:15,0,4);
normKern = normKern / sum(normKern);
xVals = (1:(length(normKern) + length(delayMatx) - 1)) - round(length(normKern)/2);
plot(xVals, conv(delayMatx,normKern)/max(abs(conv(delayMatx,normKern))),'k','linewidth',2);
plot(xVals, conv(delayMatx,normKern)/max(abs(conv(delayMatx,normKern))),'--','Color',[100 100 100]./255,'linewidth',2)



if revForFlag == 1  
    for i = 1:length(blockSwitch)
            bs_loc = blockSwitch(i);
            plot([bs_loc bs_loc],[0 1],'--','linewidth',1,'Color',[30 144 255]./255)
            text(bs_loc,1.04,num2str(blockProbs{i}));
            set(text,'FontSize',3);
    end
else
    allProbsL = [behSessionData.rewardProbL];
    allProbsR = [behSessionData.rewardProbR];
%     if blockSwitch(end) == length(allChoices)
%         blockSwitch = blockSwitch(1:end-1);
%     end
    for i = 1:length(blockSwitch)
        bs_loc = blockSwitch(i);
        plot([bs_loc bs_loc],[-1 1],'--','linewidth',1,'Color',[30 144 255]./255)
        if rem(i,2) == 0
            labelOffset = 1.12;
        else
            labelOffset = 1.04;
        end
        a = num2str(allProbsL(blockSwitch(i)+1));
        b = '/';
        c = num2str(allProbsR(blockSwitch(i)+1));
        label = strcat(a,b,c);
        text(bs_loc,labelOffset,label);
        set(text,'FontSize',3);
    end
end

text(0,1.12,'L/R');
xlabel('Trials')
ylabel('delay')
% subplot(2,1,2); hold on;
% for i = 1:length(behSessionData)
%     if ~isempty(delayTime(i))
%           currTime = (delayTime(i)- behSessionData(1).CSon)/1000/60;
%           for j = 1: length(delayTime(i))
%             plot([currTime(j) currTime(j)],[0 1],'m'); hold on;
% %             xlim([0 10000000]);
%             xlabel('Time (min)');
%             ylim([0 1])
%           end
%     end
% end
% xlim([0 currTime]);
disp('number of itis with licks in ITI is ');
disp(length(delayMatx(delayMatx>=1)));
disp('total iti licks ');
disp(length(delayTime));
disp('average rate of delay(1/sec)');
delayRate2 = 1000/(mean(diff(delayTime)));
sd_delay = 1000/std(diff(delayTime));
disp(delayRate2); disp('+/- ('); disp(sd_delay); disp(')') %%*1000 to convert to s
ratio_delayTrial = length(delayMatx(delayMatx>=1))/currTrial;
disp('delay ratio in trial');
disp(ratio_delayTrial); 
end

function dataOutput = importData_operantMatching(filename, startRow, endRow)
delimiter = '';
if nargin<=2
    startRow = 1;
    endRow = inf;
end
formatSpec = '%s%[^\n\r]';
%% Open the text file.
fileID = fopen(filename,'r');
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'ReturnOnError', false);
    dataArray{1} = [dataArray{1};dataArrayBlock{1}];
end
fclose(fileID);
%% Create output variable
dataOutput = [dataArray{1:end-1}];
end 