function delayAssesment(sessionName) 


[root, sep] = currComputer();
[animalName, date] = strtok(sessionName, 'd'); 
animalName = animalName(2:end);
date = date(1:9);
sessionFolder = ['m' animalName date];
behavioralDataPath = [root animalName sep sessionFolder sep 'behavior' sep sessionName '.asc'];
sessionText = importData_operantMatching(behavioralDataPath);
[behSessionData, blockSwitch, blockProbs] = generateSessionData_behav_operantMatching(sessionName);
lickCount = 0;
delayHappened = 0;
% delayTime = zeros(length(behSessionData),1);
% delayHappened = zeros(length(behSessionData),1);
delayTime = [];
delayMatx = [];
% allLick_R = find(~isnan([behSessionData.rewardTime]));

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
        end    
        if delayHappened == 0 
            delayMatx(currTrial) = 0;
        else
            delayMatx(currTrial) = delayHappened;
        end
        delayHappened = 0; 
    end
end
% allLicls_L(~isnan(behSessionData(1:end).licksL)) = size(behSessionData(1:end).licksL);


figure; hold on;
set(gcf, 'Position', get(0,'Screensize'))
suptitle(sessionName)
subplot(2,1,1); hold on;
normKern = normpdf(-15:15,0,4);
normKern = normKern / sum(normKern);
xVals = (1:(length(normKern) + length(delayMatx) - 1)) - round(length(normKern)/2);
plot(xVals, conv(delayMatx,normKern)/max(abs(conv(delayMatx,normKern))),'k','linewidth',2);
plot(xVals, conv(delayMatx,normKern)/max(abs(conv(delayMatx,normKern))),'--','Color',[100 100 100]./255,'linewidth',2)




for i = 1:length(blockSwitch)
        bs_loc = blockSwitch(i);
        plot([bs_loc bs_loc],[0 1],'--','linewidth',1,'Color',[30 144 255]./255)
        text(bs_loc,1.04,num2str(blockProbs{i}));
        set(text,'FontSize',3);
end


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
disp('number of licks in ITI is ');
disp(lickCount);
disp('average rate of delay(1/sec)');
delayRate2 = 1000/(mean(diff(delayTime)));
sd_delay = 1000/std(diff(delayTime));
disp(delayRate2); disp('+/- ('); disp(sd_delay); disp(')') %%*1000 to convert to s
ratio_delayTrial = length(delayMatx(delayMatx>=1))/length(behSessionData);
disp('delay ratio in trial');
disp(ratio_delayTrial); 


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
end