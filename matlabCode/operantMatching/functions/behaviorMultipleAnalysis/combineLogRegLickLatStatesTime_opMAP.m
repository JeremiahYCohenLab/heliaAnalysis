function [glm_rwdLickSafe, glm_rwdLickThreat, StayLickLat_safe, SwitchLickLat_safe, StayLickLat_threat, SwitchLickLat_threat,  binSize, timeMax, tMax] = combineLogRegLickLatStatesTime_opMAP(xlFile, animal, category,revForFlag, varargin)

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
tMax = length(timeBinEdges) - 1;
combinedLickLat_safe = [];
combinedLickLat_threat = [];
StayLickLat_safe = []; 
SwitchLickLat_safe = [];
rwdMatx_safe = [];
rwdMatx_threat = [];
StayLickLat_threat = [];
SwitchLickLat_threat = [];


for i = 1: length(dayList)
    sessionName = dayList{i};
    [animalName, date] = strtok(sessionName, 'd'); 
%     animalName = animalName(2:end);
    date = date(1:9);
    sessionFolder = ['m' animalName date];
    sessionName = sessionFolder;

    if isstrprop(sessionName(end), 'alpha')
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sep sessionName(end) sep sessionName '_sessionData.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sessionName '_sessionData.mat'];
    end

    if exist(sessionDataPath,'file')
        load(sessionDataPath)
        if p.Results.revForFlag
            behSessionData = sessionData;
        end
    else
        [behSessionData,blockSwitch, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
    end
    
    %%generate reward matrix for tMax trials
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
rwdTmpMatx = zeros(tMax, length(responseInds));  
   %initialize matrices for number of response trials x number of time bins
    for j = 2:length(responseInds)          
        k = 1;
        %find time between "current" choice and previous rewards, up to timeMax in the past 
        timeTmp = [];
        while j-k > 0 & behSessionData(responseInds(j)).rewardTime - behSessionData(responseInds(j-k)).rewardTime < timeMax
            if behSessionData(responseInds(j-k)).rewardL == 1 || behSessionData(responseInds(j-k)).rewardR == 1
                timeTmp = [timeTmp (behSessionData(responseInds(j)).rewardTime - behSessionData(responseInds(j-k)).rewardTime)]; %time from current choice to choice in earlier trial and next earlier trial and etc.
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
    while behSessionData(responseInds(j)).rewardTime - behSessionData(responseInds(1)).rewardTime < timeMax
        tmpDiff = behSessionData(responseInds(j)).rewardTime - behSessionData(responseInds(1)).rewardTime;
        binnedDiff = discretize(tmpDiff, timeBinEdges);
        rwdTmpMatx(binnedDiff:tMax,j) = NaN;
        j = j+1;
    end
    %concatenate temp matrix with combined matrix
            rwdMatx_safe_states =[]; 
            rwdMatx_threat_states =[];
     for currT = 1:length(stateChangeInds)-1
 %these go back to being empty for the next day
             if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
                if stateType(stateChangeInds(currT)) == 1
                    rwdTempMatx(stateChangeInds(currT)) = NaN;
                    rwdMatx_threat_states = [rwdMatx_threat_states NaN(length(timeBinEdges)-1,15) rwdTmpMatx(:,stateChangeInds(currT):stateChangeInds(currT+1)-1)]; %these are the matrices of each state
                else
                    rwdTempMatx(stateChangeInds(currT)) = NaN;
                    rwdMatx_safe_states = [rwdMatx_safe_states NaN(length(timeBinEdges)-1,15) rwdTmpMatx(:,stateChangeInds(currT):stateChangeInds(currT+1)-1)]; %these are the matrices of each state
                end
             end
     end
%     rwdTmpMatx(:,1) = NaN;
    
         rwdMatx_safe = [rwdMatx_safe NaN(length(timeBinEdges)-1, 100) rwdMatx_safe_states];   
         rwdMatx_threat = [rwdMatx_threat NaN(length(timeBinEdges)-1, 100) rwdMatx_threat_states];
    
    %% determine and plot lick latency distributions for each spout
    lickLat = [behSessionData(responseInds).rewardTime] - [behSessionData(responseInds).CSon];
    indsR = find(allChoices == 1);
    indsL = find(allChoices == -1);
    lickLat_R = zscore(lickLat(indsR));
    lickLat_L = zscore(lickLat(indsL));
    lickLat = NaN(1, length(allChoices));
    lickLat(indsR) = lickLat_R;
    lickLat(indsL) = lickLat_L;
    
  combinedLickLat_threat_state = [];    
  changeChoice_threat_state = [];
  StayLickLat_threat_state = []; 
  SwitchLickLat_threat_state = [];
  combinedLickLat_safe_state = [];
  changeChoice_safe_state = [];
  StayLickLat_safe_state = []; 
  SwitchLickLat_safe_state = [];
    %% determine lick latency for stay v switch trials
    changeChoice = [false abs(diff(allChoices)) > 0];
    for currT = 1:length(stateChangeInds)-1   %% determine lick latency for stay v switch trials for safe and threat sepearetaly
         if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
            if stateType(stateChangeInds(currT)) == 1 %plus 2 to not look at the first lick lat
                combinedLickLat_threat_state = [combinedLickLat_threat_state NaN(1,16) lickLat(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
%                 changeChoice_threat_state = [false abs(diff(allChoices(stateChangeInds(currT-1)+1:stateChangeInds(currT)-1))) > 0];
                StayLickLat_threat_state = [StayLickLat_threat_state  lickLat(~changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))]; 
                SwitchLickLat_threat_state = [SwitchLickLat_threat_state  lickLat(changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))];
            else
                combinedLickLat_safe_state = [combinedLickLat_safe_state NaN(1,16) lickLat(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
%                 changeChoice_safe_state = [false abs(diff(allChoices(stateChangeInds(currT-1)+1:stateChangeInds(currT)-1))) > 0];
                StayLickLat_safe_state = [StayLickLat_safe_state  lickLat(~changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))]; 
                SwitchLickLat_safe_state = [SwitchLickLat_safe_state   lickLat(changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))];
            end
         end
     end
        combinedLickLat_safe = [combinedLickLat_safe NaN(1,100) combinedLickLat_safe_state];
        combinedLickLat_threat = [combinedLickLat_threat NaN(1,100) combinedLickLat_threat_state];
%         changeChoice_safe = [changeChoice_safe changeChoice_safe_state];
        StayLickLat_safe = [StayLickLat_safe StayLickLat_safe_state]; 
        SwitchLickLat_safe = [SwitchLickLat_safe SwitchLickLat_safe_state];
%         changeChoice_threat = [changeChoice_threat changeChoice_threat_state];
        StayLickLat_threat = [StayLickLat_threat StayLickLat_threat_state]; 
        SwitchLickLat_threat = [SwitchLickLat_threat SwitchLickLat_threat_state];
end


%linear regression model
glm_rwdLickSafe = fitglm([rwdMatx_safe]', combinedLickLat_safe);
glm_rwdLickThreat = fitglm([rwdMatx_threat]', combinedLickLat_threat);
end% if p.Results.plotFlag
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