function [glm_rwdLickSafe, safeStayLickLat, safeSwitchLickLat, binSize, timeMax] = combineLogRegLickLatSafeTime_opMAP(xlFile, animal, category, varargin)

p = inputParser;
% default parameters if none given
p.addParameter('revForFlag',0)
p.addParameter('plotFlag', 0)
p.parse(varargin{:});

[root, sep] = currComputer();

[weights, dayList, ~] = xlsread(xlFile, animal);
[~,col] = find(~cellfun(@isempty,strfind(dayList, category)) == 1);
dayList = dayList(2:end,col);
endInd = find(cellfun(@isempty,dayList),1);
if ~isempty(endInd)
    dayList = dayList(1:endInd-1,:);
end

timeMax = 121000;
binSize = 10000;
timeBinEdges = [1000:binSize:timeMax];  %no trials shorter than 1s between outcome and CS on
timeMax = length(timeBinEdges) - 1;
combinedRewardsMatx = [];
combinedLickLat = [];
safeStayLickLat = []; 
safeSwitchLickLat = [];
rwdMatx = [];



for i = 1: length(dayList)
    sessionName = dayList{i};
    [animalName, date] = strtok(sessionName, 'd'); 
    animalName = animalName(2:end);
    date = date(1:9);
    sessionFolder = ['m' animalName date];

    if isstrprop(sessionName(end), 'alpha')
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sep sessionName(end) sep sessionName '_sessionData.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sessionName '_sessionData.mat'];
    end

%     if exist(sessionDataPath,'file')
%         load(sessionDataPath)
%         if p.Results.revForFlag
%             behSessionData = sessionData;
%         end
%     else
        [behSessionData,blockSwitch, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
%     end
    
    %%generate reward matrix for tMax trials
    responseInds = find(~isnan([behSessionData.rewardTime]));
    responseInds_safe = find([behSessionData(responseInds).stateType] == 0);
%     allAirpuff = NaN(1,length(behSessionData(responseInds_threat)));
%     allAirpuffInd = [behSessionData(responseInds_threat).AirpuffTimeOn];
%     allAirpuff(~allAirpuffInd == 0) = 1;
%     allAirpuff(isnan(allAirpuff)) = 0;% find CS+ trials with a response in the lick window
    allReward_R = [behSessionData(responseInds_safe).rewardR]; 
    allReward_L = [behSessionData(responseInds_safe).rewardL]; 
    allChoices = NaN(1,length(behSessionData(responseInds_safe)));
    allChoices(~isnan(allReward_R)) = 1;
    allChoices(~isnan(allReward_L)) = -1;
    allReward_R(isnan(allReward_R)) = 0;
    allReward_L(isnan(allReward_L)) = 0;
    allRewards = zeros(1,length(allChoices));
    allRewards(logical(allReward_R)) = 1;
    allRewards(logical(allReward_L)) = 1;
rwdTmpMatx = zeros(timeMax, length(responseInds_safe));  
   %initialize matrices for number of response trials x number of time bins
    for j = 2:length(responseInds_safe)          
        k = 1;
        %find time between "current" choice and previous rewards, up to timeMax in the past 
        timeTmp = [];
        while j-k > 0 & behSessionData(responseInds_safe(j)).rewardTime - behSessionData(responseInds(j-k)).rewardTime < timeMax
            if behSessionData(responseInds_safe(j-k)).rewardL == 1 || behSessionData(responseInds_safe(j-k)).rewardR == 1
                timeTmp = [timeTmp (behSessionData(responseInds_safe(j)).rewardTime - behSessionData(responseInds_safe(j-k)).rewardTime)]; %time from current choice to choice in earlier trial and next earlier trial and etc.
            end
            k = k + 1;
        end
        %bin outcome times and use to fill matrices
        if ~isempty(timeTmp)
            binnedRwds = discretize(timeTmp,timeBinEdges);
            for k = 1:timeMax
                if ~isempty(find(binnedRwds == k))
                    rwdTmpMatx(k,j) = sum(binnedRwds == k);
                end
            end
        end
    end
    
  %fill in NaNs at beginning of session
    j = 2;
    while behSessionData(responseInds_safe(j)).rewardTime - behSessionData(responseInds(1)).rewardTime < timeMax
        tmpDiff = behSessionData(responseInds_safe(j)).rewardTime - behSessionData(responseInds_safe(1)).rewardTime;
        binnedDiff = discretize(tmpDiff, timeBinEdges);
        rwdTmpMatx(binnedDiff:timeMax,j) = NaN;
        j = j+1;
    end
    %concatenate temp matrix with combined matrix
    rwdTmpMatx(:,1) = NaN;
    rwdMatx = [rwdMatx NaN(length(timeBinEdges)-1, 100) rwdTmpMatx];

    
    
    %% determine and plot lick latency distributions for each spout
    lickLat = [behSessionData(responseInds_safe).rewardTime] - [behSessionData(responseInds_safe).CSon];
    indsR = find(allChoices == 1);
    indsL = find(allChoices == -1);
    lickLat_R = zscore(lickLat(indsR));
    lickLat_L = zscore(lickLat(indsL));
    lickLat = NaN(1, length(allChoices));
    lickLat(indsR) = lickLat_R;
    lickLat(indsL) = lickLat_L;
    
    combinedLickLat = [combinedLickLat NaN(1,100) lickLat];
    
    %% determine lick latency for stay v switch trials
    changeChoice = [false abs(diff(allChoices)) > 0];
    safeStayLickLat = [safeStayLickLat lickLat(~changeChoice)]; 
    safeSwitchLickLat = [safeSwitchLickLat lickLat(changeChoice)];

end

%linear regression model
glm_rwdLickSafe = fitglm([rwdMatx]', combinedLickLat);

% if p.Results.plotFlag
%     figure; hold on
%     relevInds = 2:timeMax+1;
%     coefVals = glm_rwdLickSafe.Coefficients.Estimate(relevInds);
%     CIbands = coefCI(glm_rwdLickSafe);
%     errorL = abs(coefVals - CIbands(relevInds,1));
%     errorU = abs(coefVals - CIbands(relevInds,2));
%     errorbar((1:timeMax)+0.2,coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)
% 
%     xlabel('Reward n Trials Back')
%     ylabel('\beta Coefficient')
%     xlim([0.5 timeMax+0.5])
% 
%     suptitle([animal ' ' category])
% end