function rewardStatsStates (xlFile, sheet, category, revForFlag)

[root, sep] = currComputer();

[weights, dayList, ~] = xlsread(xlFile, sheet);
[~,col] = find(strcmp(dayList, category));
dayList = dayList(2:end,col);
endInd = find(cellfun(@isempty,dayList),1);
if ~isempty(endInd)
    dayList = dayList(1:endInd-1,:);
end
rewardStats_safe = zeros(length(dayList), 3);
rewardstats_threat = zeros(length(dayList), 3);
% trials_safe = zeros(length(dayList), 1);
% trials_threat = 

for i = 1: length(dayList)
    sessionName = dayList{i};
    [animalName, date] = strtok(sessionName, 'd'); 
    animalName = animalName(2:end);
    sessionFolder = ['m' animalName date];

    if isstrprop(sessionName(end), 'alpha')
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sessionName(end) sep sessionName '_sessionData_behav.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sortedap' sep 'session' sep sessionName '_sessionData_behav.mat'];
    end

    if exist(sessionDataPath,'file')
        load(sessionDataPath);
        behSessionData = sessionData;
    else
        [behSessionData,blockSwitch, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
    end
    
    responseInds = find(~isnan([behSessionData.rewardTime])); % find CS+ trials with a response in the lick window    
    stateType = [behSessionData(responseInds).stateType];
    stateTypeSafeInd = find(stateType ==0);
    stateTypeThreatInd = find(stateType ==1);
    omitInds = isnan([behSessionData.rewardTime]); 
    allReward_R = [behSessionData(responseInds).rewardR]; 
    allReward_L = [behSessionData(responseInds).rewardL]; 
    allReward_RSafe = allReward_R(stateTypeSafeInd);
    allReward_RThreat = allReward_R(stateTypeThreatInd);
    allChoices = NaN(1,length(behSessionData(responseInds)));
    allChoices(~isnan(allReward_R)) = 1;
    allChoices(~isnan(allReward_L)) = -1;
    
    allReward_R(isnan(allReward_R)) = 0;
    allReward_L(isnan(allReward_L)) = 0;

    allRewards = zeros(1,length(allChoices));
    allRewards(logical(allReward_R)) = 1;
    allRewards(logical(allReward_L)) = 1;
    allReward_LSafe = allReward_L(stateTypeSafeInd);
    allReward_LThreat = allReward_L(stateTypeThreatInd);
    allChoicesSafe = NaN(1,length(stateTypeSafeInd));
    allChoicesThreat = NaN(1,length(stateTypeThreatInd));
    allChoicesSafe(~isnan(allReward_LSafe)) = -1;
    allChoicesSafe(~isnan(allReward_RSafe)) = 1;
    allChoicesThreat(~isnan(allReward_LThreat)) = -1;
    allChoicesThreat(~isnan(allReward_RThreat)) = 1;
    allChoice_RSafe = double(allChoicesSafe == 1);
    allChoice_LSafe = double(allChoicesSafe == -1);
    allChoice_RThreat = double(allChoicesThreat == 1);
    allChoice_LThreat = double(allChoicesThreat == -1);
    
    allReward_RSafe(isnan(allReward_RSafe)) = 0;
    allReward_LSafe(isnan(allReward_LSafe)) = 0;
    
    allReward_RThreat(isnan(allReward_RThreat)) = 0;
    allReward_LThreat(isnan(allReward_LThreat)) = 0;

    allRewardsSafe = zeros(1,length(allChoicesSafe));
    allRewardsSafe(logical(allReward_RSafe)) = 1;
    allRewardsSafe(logical(allReward_LSafe)) = 1;
    
    allRewardsThreat = zeros(1,length(allChoicesThreat));
    allRewardsThreat(logical(allReward_RThreat)) = 1;
    allRewardsThreat(logical(allReward_LThreat)) = 1;
    
    
    
    rewardStats_safe(i,1) = sum(allRewardsSafe);
    rewardstats_threat(i,1) = sum(allRewardsThreat);
    rewardStats_safe(i,2) = length(stateTypeSafeInd);
    rewardstats_threat(i,2) = length(stateTypeThreatInd);
    rewardStats_safe(i,3) = sum(allRewardsSafe)/length(stateTypeSafeInd);
    rewardstats_threat(i,3) = sum(allRewardsThreat)/length(stateTypeThreatInd);
end
figure();
sp_totalRew = subplot(1,2,1); hold on
sp_rewRate = subplot(1,2,2); hold on
subplot(sp_totalRew); title('total reward in each state');
scatter(rewardStats_safe(:,1), rewardstats_threat(:,1), 25, 'filled', 'MarkerFaceColor',[0 .7 .7]); xlabel('safe'); ylabel('threat');xlim([0 400])
ylim([0 400])
plot([0 400],[0 400],'k:')
axis square
set(sp_totalRew, 'tickdir', 'out')
subplot(sp_rewRate); hold on; title('reward rate (beased on trial)');
scatter(rewardStats_safe(:,3), rewardstats_threat(:,3), 25, 'filled', 'MarkerFaceColor',[0 .85 .85]); xlabel('safe'); ylabel('threat');
xlim([0 1])
ylim([0 1])
plot([0 1],[0 1],'k:')
axis square
set(sp_rewRate, 'tickdir', 'out');

end