function delayAssesment(sessionName) 


[root, sep] = currComputer();
[animalName, date] = strtok(sessionName, 'd'); 
animalName = animalName(2:end);
date = date(1:9);
sessionFolder = ['m' animalName date];
behavioralDataPath = [root animalName sep sessionFolder sep 'behavior' sep sessionName '.asc'];
sessionText = importData_operantMatching(behavioralDataPath);
[behSessionData, blockSwitch, blockProbs] = generateSessionData_behav_operantMatching(sessionName);
countdelay = 0;
R = 0;
delayTime = zeros(length(behSessionData),1);
delayHappened = zeros(length(behSessionData),1);

for i = 1:length(sessionText)
    if ~isempty(strfind(sessionText{i}, 'Delayed'))
        countdelay = countdelay +1;
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
             delayTime(currTrial) = str2double(temp(1,2));
             delayHappened(currTrial) = R +1; 
             end
        end
    end
end

figure; hold on;
set(gcf, 'Position', get(0,'Screensize'))
suptitle(sessionName)
subplot(2,1,1); hold on;
normKern = normpdf(-15:15,0,4);
normKern = normKern / sum(normKern);
%%kernShift = (length(normKern) - 1)/2;
%%smoothRew = smoothRew(kernShift:(length(smoothRew)-kernShift));
%%smoothRewGaps = [];

xVals = (1:(length(normKern)+ length(delayHappened) - 1)) - round(length(normKern)/2);
plot(xVals, conv(delayHappened,normKern)/max(conv(delayHappened,normKern)),'k','linewidth',2);
for i = 1:length(blockSwitch)
        bs_loc = blockSwitch(i);
        plot([bs_loc bs_loc],[-1 1],'--','linewidth',1,'Color',[30 144 255]./255)
        text(bs_loc,1.04,num2str(blockProbs{i}));
        set(text,'FontSize',3);
end

%plot(xVals, conv(allRewards,normKern)/max(conv(allRewards,normKern)),'--','Color',[100 100 100]./255,'linewidth',2)
xlabel('Trials')
ylabel('delay')
%legend('Choices','Rewards')
for i = 1:length(behSessionData)
    currTime = (behSessionData(i).CSon - behSessionData(1).CSon);
    if ~isempty(delayTime(i))
    subplot(2,1,2); hold on;
        for j = 1: length(delayTime(i))
        plot([delayTime(j) delayTime(j)],[0 1],'m'); hold on;
        %%xlim([0 10000000]);
        xlabel('Time (min)');
        ylim([-1 1])
        end
    end
end

disp('number of licks in ITI is ');
disp(countdelay);
disp('average sparse of delay(sd)in sec');
delayRate2 = 1000/(mean(diff(delayTime)));
sd_delay = 1000/std(diff(delayTime));
disp(delayRate2); disp('('); disp(sd_delay); disp(' )')  %%*1000 to convert to s
delayRate = (delayTime(length(delayTime))-delayTime(1))/behSessionData(length(behSessionData)).trialEnd;
disp('delay ratio in time ');
disp((1/delayRate)); 
delayRate_trials = countdelay/blockSwitch(length(blockSwitch));
disp('delay ratio in trial');
disp(1/delayRate_trials); 
min_delay_time = 1000/(min(diff(delayTime)));
disp(min_delay_time);

%text(0.1,1.01,num2str(countdelay));
%%text(0,1.01,'delay');
%%text(0.35,1.01,num2str(delayRate2));
%%text(0.3,1.01,'sparse of delay');
%%smoothlick = conv(allRewards,normKern)/max(conv(allRewards,normKern));
%%end

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