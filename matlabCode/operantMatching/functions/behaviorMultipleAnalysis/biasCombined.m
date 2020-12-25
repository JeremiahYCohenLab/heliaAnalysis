function biasCombined(xlFile, animal, category, varargin)

p = inputParser;
% default parameters if none given
p.addParameter('revForFlag',0)
p.addParameter('plotFlag', 0)
% p.parse(varargin{:});

[root, sep] = currComputer();

[weights, dayList, ~] = xlsread(xlFile, animal);
[~,col] = find(~cellfun(@isempty,strfind(dayList, category)) == 1);
dayList = dayList(2:end,col);
endInd = find(cellfun(@isempty,dayList),1);
if ~isempty(endInd)
    dayList = dayList(1:endInd-1,:);
end
% combinedRrewardsMatx_threat_state = [];
% combinedRewardsMatx_safe_state = [];
% combinedLrewardsMatx_threat_state = [];
% combinedLrewardsMatx_safe_state = [];
% combinedChoiceMatx_threat_state = [];
% combinedChoiceMatx_safe_state = [];
combinedBlockSwitch = [];
combinedStateSwitch = [];
combinedReward = [];
combinedAllChoices = [];

for i = 1: length(dayList)
    sessionName = dayList{i};
    [animalName, date] = strtok(sessionName, 'd'); 
    date = date(1:9);
    sessionFolder = ['m' animalName date];
    sessionName = ['m' sessionName];
    if isstrprop(sessionName(end), 'alpha')
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sep sessionName(end) sep sessionName '_sessionData.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sortedap' sep 'session' sep sessionName '_sessionData.mat'];
    end

    if exist(sessionDataPath,'file')
        load(sessionDataPath)
        if p.Results.revForFlag
            behSessionData = sessionData;
        end
    else
        [behSessionData,blockSwitch, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
    end
    
    combinedBlockSwitch = [combinedBlockSwitch blockSwitch];
    combinedStateSwitch = [combinedStateSwitch stateSwitch];
    responseInds = find(~isnan([behSessionData.rewardTime]));
    stateType = [behSessionData(responseInds).stateType];
     stateChangeInds = [1 (find(abs(diff([behSessionData(responseInds).stateType])) == 1) + 1) length(responseInds)];
    %     allAirpuff = NaN(1,length(behSessionData(responseInds_threat)));
    %     allAirpuffInd = [behSessionData(responseInds_threat).AirpuffTimeOn];
    %     allAirpuff(~allAirpuffInd == 0) = 1;
    %     allAirpuff(isnan(allAirpuff)) = 0;% find CS+ trials with a response in the lick window
    allReward_R = [behSessionData(responseInds).rewardR]; 
    allReward_L = [behSessionData(responseInds).rewardL]; 
    allChoices = NaN(1,length(behSessionData(responseInds)));
    allChoices(~isnan(allReward_R)) = 1;
    allChoices(~isnan(allReward_L)) = -1;
    allReward_R(isnan(allReward_R)) = 0;
    allReward_L(isnan(allReward_L)) = 0;
    allRewards = zeros(1,length(allChoices));
    allRewards(logical(allReward_R)) = 1;
    allRewards(logical(allReward_L)) = 1;
    Rchoices = allChoices(allChoices == 1);
    

    ChoiceMatxTmp_threat_state = [];
    rewMatxTmpR_threat_state = [];
    ChoiceMatxTmp_safe_state = [];
    rewMatxTmpR_safe_state = [];
    
%     for currT = 1:length(stateChangeInds)-1
%             if stateType(stateChangeInds(currT)) == 1
%                 ChoiceMatxTmp_threat_state = [ChoiceMatxTmp_threat_state allChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 rewMatxTmpR_threat_state =  [rewMatxTmpR_threat_state allReward_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 rewMatxTmpL_threat_state =  [rewMatxTmpL_threat_state allReward_L(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%             
%             else
%                 ChoiceMatxTmp_safe_state = [ChoiceMatxTmp_safe_state allChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 rewMatxTmpR_safe_state =  [rewMatxTmpR_safe_state allReward_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 rewMatxTmpL_safe_state =  [rewMatxTmpL_safe_state allReward_L(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%             end
%     end
      combinedAllChoices = [combinedAllChoices allChoices];
%     combinedRreward = [combinedRreward allReward_R];
%     combinedLreward = [combinedLreward allReward_L];
      combinedReward = [combinedReward  allRewards];
%     combinedRrewardsMatx_threat_state = [combinedRrewardsMatx_threat_state  rewMatxTmpR_threat_state];
%     combinedRewardsMatx_safe_state = [combinedRrewardsMatx_safe_state rewMatxTmpR_safe_state];
%     combinedLrewardsMatx_threat_state = [combinedLrewardsMatx_threat_state rewMatxTmpL_threat_state];
%     combinedLrewardsMatx_safe_state = [combinedLrewardsMatx_safe_state rewMatxTmpL_safe_state];
%     combinedChoiceMatx_threat_state = [combinedChoiceMatx_threat_state ChoiceMatxTmp_threat_state];
%     combinedChoiceMatx_safe_state = [combinedChoiceMatx_safe_state ChoiceMatxTmp_safe_state];

normKern = normpdf(-15:15,0,4);
normKern = normKern / sum(normKern);
cumsum_allRchoice = cumsum(combinedAllChoices == 1);
cumsum_allLchoice = cumsum(combinedAllChoices == -1);
cumsum_allRreward = cumsum(combinedReward == 1);
cumsum_allLreward = cumsum(combinedReward == -1);
cumsum_blockSwitch = cumsum_allLchoice(combinedBlockSwitch);
cumsum_stateSwitch = cumsum_allLchoice(combinedStateSwitch);
if cumsum_blockSwitch(1) == 0
    cumsum_blockSwitch(1) = 1;
end

if cumsum_stateSwitchh(1) == 0
    cumsum_stateSwitch(1) = 1;
end

halfKern = normKern(round(length(normKern)/2):end);
choiceSlope = atand(diff(conv(cumsum_allRchoice,halfKern))./diff(conv(cumsum_allLchoice,halfKern)));
rwdSlope = atand(diff(conv(cumsum_allRreward,halfKern))./diff(conv(cumsum_allLreward,halfKern)));
subplot(2,2,1); hold on;
plot(cumsum_allLchoice, cumsum_allRchoice,'linewidth',2,'Color',[30,144,255]/255);

avgRwdSlope = [];
tempMax = 0;
for i = 1:length(cumsum_blockSwitch)
    if i ~= length(cumsum_blockSwitch)
        avgRwdSlope(i) = tand(nanmean(rwdSlope(combinedBlockSwitch(i):combinedBlockSwitch(i+1))));
        xval = [cumsum_blockSwitch(i) cumsum_blockSwitch(i+1)];
        yval = [cumsum_blockSwitch(i) cumsum_blockSwitch(i+1)]*avgRwdSlope(i) - cumsum_blockSwitch(i)*avgRwdSlope(i) + cumsum_allRchoice(combinedBlockSwitch(i));
        tempMax = yval(2);
        plot(xval, yval, 'k','linewidth',2);
    else
        avgRwdSlope(i) = tand(mean(rwdSlope(blockSwitch(i):end)));
        xval = [cumsum_blockSwitch(i) cumsum_allLchoice(end)];
        yval = [cumsum_blockSwitch(i) cumsum_allLchoice(end)]*avgRwdSlope(i) - cumsum_blockSwitch(i)*avgRwdSlope(i) + cumsum_allRchoice(combinedBlockSwitch(i));
        tempMax = yval(2);
        plot(xval, yval, 'k','linewidth',2);
    end
end
limMax = max([max(cumsum_allLchoice) max(cumsum_allRchoice)]);
xlim([0 limMax])
ylim([0 limMax])
legend('Choice','Income','location','best')
xlabel('Cumulative Left Choices'); ylabel('Cumulative Right Choices')
subplot(2,2,2); hold on;
for i = 1:length(cumsum_stateSwitch)
    if i ~= length(cumsum_stateSwitch)
        avgRwdSlope(i) = tand(nanmean(rwdSlope(combinedStateSwitch(i):combinedStateSwitch(i+1))));
        xval = [cumsum_stateSwitch(i) cumsum_stateSwitch(i+1)];
        yval = [cumsum_stateSwitch(i) cumsum_stateSwitch(i+1)]*avgRwdSlope(i) - cumsum_stateSwitch(i)*avgRwdSlope(i) + cumsum_allRchoice(combinedtStateSwitch(i));
        tempMax = yval(2);
        plot(xval, yval, 'k','linewidth',2);
    else
        avgRwdSlope(i) = tand(mean(rwdSlope(combinedBlockSwitch(i):end)));
        xval = [cumsum_stateSwitch(i) cumsum_allLchoice(end)];
        yval = [cumsum_stateSwitch(i) cumsum_allLchoice(end)]*avgRwdSlope(i) - cumsum_stateSwitch(i)*avgRwdSlope(i) + cumsum_allRchoice(combinedtStateSwitch(i));
        tempMax = yval(2);
        plot(xval, yval, 'k','linewidth',2);
    end
end
limMax = max([max(cumsum_allLchoice) max(cumsum_allRchoice)]);
xlim([0 limMax])
ylim([0 limMax])
legend('Choice','Income','location','best')
xlabel('Cumulative Left Choices'); ylabel('Cumulative Right Choices')
end