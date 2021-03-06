function [glm_rwdLickSafe, glm_rwdLickThreat, glm_rwdLickSafeOrg, glm_rwdLickThreatOrg,StayLickLat_safe, SwitchLickLat_safe, StayLickLat_threat, SwitchLickLat_threat, StayLickLatOrg_safe, SwitchLickLatOrg_safe, StayLickLatOrg_threat, SwitchLickLatOrg_threat,  tMax] = combineLogRegLickLatStates_opMAP(xlFile, animal, category, varargin)

p = inputParser;
% default parameters if none given
p.addParameter('revForFlag',0)
p.addParameter('plotFlag', 0)
% p.parse(varargin{:});
combinedRewardsMatx_threat= [];
combinedRewardsMatx_safe = [];

[root, sep] = currComputer();

[weights, dayList, ~] = xlsread(xlFile, animal);
[~,col] = find(~cellfun(@isempty,strfind(dayList, category)) == 1);
dayList = dayList(2:end,col);
endInd = find(cellfun(@isempty,dayList),1);
if ~isempty(endInd)
    dayList = dayList(1:endInd-1,:);
end
combinedLickLat_safe = [];
combinedLickLat_threat = [];
StayLickLat_safe = []; 
SwitchLickLat_safe = [];
StayLickLat_threat = [];
SwitchLickLat_threat = [];
tMax = 12;
StayLickLatOrg_safe = []; 
SwitchLickLatOrg_safe = [];
combinedLickLatOrg_safe = [];
combinedLickLatOrg_threat = [];
StayLickLatOrg_threat = [];
SwitchLickLatOrg_threat = [];


for i = 1: length(dayList)
    sessionName = dayList{i};
    [animalName, date] = strtok(sessionName, 'd'); 
    animalName = animalName(2:end);
    date = date(1:9);
    sessionFolder = ['m' animalName date];
    

    if isstrprop(sessionName(end), 'alpha')
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sep sessionName(end) sep sessionName '_sessionData.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sortedAP' sep 'session' sessionName '_sessionData.mat'];
    end

    if exist(sessionDataPath,'file')
        load(sessionDataPath);
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
     stateChangeInd = [1 (find(abs(diff(stateType)) == 1) + 1) length(responseInds)];
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
    
    combinedRewardsMatx_threat_state = [];
    combinedRewardsMatx_safe_state = [];
    
    for currT = 1:length(stateChangeInds)-1
         if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
            if stateType(stateChangeInds(currT)) == 1
                rwdMatxTmp_threat = []; %will make an upper triangle matrix
                for j = 1:tMax
                    rwdMatxTmp_threat(j,:) = [NaN(1,j) allRewards(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                end
                combinedRewardsMatx_threat_state = [combinedRewardsMatx_threat_state NaN(tMax,15) rwdMatxTmp_threat(:,1:end-1)];
            else
                rwdMatxTmp_safe = [];
                for j = 1:tMax
                    rwdMatxTmp_safe(j,:) = [NaN(1,j) allRewards(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];  
                end
                combinedRewardsMatx_safe_state = [combinedRewardsMatx_safe_state NaN(tMax,15) rwdMatxTmp_safe(:,1:end-1)];
            end
         end
    end
    combinedRewardsMatx_threat = [combinedRewardsMatx_threat NaN(tMax,100) combinedRewardsMatx_threat_state];
    combinedRewardsMatx_safe = [combinedRewardsMatx_safe NaN(tMax,100) combinedRewardsMatx_safe_state];
            %% determine and plot lick latency distributions for each spout
                lickLat = [behSessionData(responseInds).rewardTime] - [behSessionData(responseInds).CSon];
                indsR = find(allChoices == 1);
                indsL = find(allChoices == -1);
                lickLat_R = zscore(lickLat(indsR));
                lickLat_L = zscore(lickLat(indsL));
                
                 lickLat_ROrg = lickLat(indsR);
                 lickLat_LOrg = lickLat(indsL);
                 
                 
                lickLat = NaN(1, length(allChoices));
                lickLat(indsR) = lickLat_R;
                lickLat(indsL) = lickLat_L;
                
                
                lickLatOrg = NaN(1, length(allChoices));
                lickLatOrg(indsR) = lickLat_ROrg;
                lickLatOrg(indsL) = lickLat_LOrg;
                
  combinedLickLatOrg_threat_state = [];    
%   changeChoice_threat_state = [];
  StayLickLatOrg_threat_state = []; 
  SwitchLickLatOrg_threat_state = [];
  combinedLickLatOrg_safe_state = [];
%   changeChoice_safe_state = [];
  StayLickLatOrg_safe_state = []; 
  SwitchLickLatOrg_safe_state = [];                           
  combinedLickLat_threat_state = [];    
  changeChoice_threat_state = [];
  StayLickLat_threat_state = []; 
  SwitchLickLat_threat_state = [];
  combinedLickLat_safe_state = [];
  changeChoice_safe_state = [];
  StayLickLat_safe_state = []; 
  SwitchLickLat_safe_state = [];
 changeChoice = [false abs(diff(allChoices)) > 0];
  for currT = 1:length(stateChangeInds)-1   %% determine lick latency for stay v switch trials for safe and threat sepearetaly
         if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
            if stateType(stateChangeInds(currT)) == 1 %plus 2 to not look at the first lick lat
                combinedLickLat_threat_state = [combinedLickLat_threat_state NaN(1,15) lickLat(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
%                 changeChoice_threat_state = [false abs(diff(allChoices(stateChangeInds(currT-1)+1:stateChangeInds(currT)-1))) > 0];
                StayLickLat_threat_state = [StayLickLat_threat_state  lickLat(~changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))]; 
                SwitchLickLat_threat_state = [SwitchLickLat_threat_state lickLat(changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))];
            else
                combinedLickLat_safe_state = [combinedLickLat_safe_state NaN(1,15) lickLat(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
%                 changeChoice_safe_state = [false abs(diff(allChoices(stateChangeInds(currT-1)+1:stateChangeInds(currT)-1))) > 0];
                StayLickLat_safe_state = [StayLickLat_safe_state  lickLat(~changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))]; 
                SwitchLickLat_safe_state = [SwitchLickLat_safe_state  lickLat(changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))];
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
        for currT = 1:length(stateChangeInds)-1   %% determine lick latency for stay v switch trials for safe and threat sepearetaly
         if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
            if stateType(stateChangeInds(currT)) == 1 %plus 2 to not look at the first lick lat
                combinedLickLatOrg_threat_state = [combinedLickLatOrg_threat_state NaN(1,15) lickLatOrg(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
%                 changeChoice_threat_state = [false abs(diff(allChoices(stateChangeInds(currT-1)+1:stateChangeInds(currT)-1))) > 0];
                StayLickLatOrg_threat_state = [StayLickLatOrg_threat_state  lickLatOrg(~changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))]; 
                SwitchLickLatOrg_threat_state = [SwitchLickLatOrg_threat_state  lickLatOrg(changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))];
            else
                combinedLickLatOrg_safe_state = [combinedLickLatOrg_safe_state NaN(1,15) lickLatOrg(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
%                 changeChoice_safe_state = [false abs(diff(allChoices(stateChangeInds(currT-1)+1:stateChangeInds(currT)-1))) > 0];
                StayLickLatOrg_safe_state = [StayLickLatOrg_safe_state  lickLatOrg(~changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))]; 
                SwitchLickLatOrg_safe_state = [SwitchLickLatOrg_safe_state   lickLatOrg(changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))];
            end
         end
       end
        combinedLickLatOrg_safe = [combinedLickLatOrg_safe NaN(1,100) combinedLickLatOrg_safe_state];
        combinedLickLatOrg_threat = [combinedLickLatOrg_threat NaN(1,100) combinedLickLatOrg_threat_state];
%         changeChoice_safe = [changeChoice_safe changeChoice_safe_state];
        StayLickLatOrg_safe = [StayLickLatOrg_safe StayLickLatOrg_safe_state]; 
        SwitchLickLatOrg_safe = [SwitchLickLatOrg_safe SwitchLickLatOrg_safe_state];
%         changeChoice_threat = [changeChoice_threat changeChoice_threat_state];
        StayLickLatOrg_threat = [StayLickLatOrg_threat StayLickLatOrg_threat_state]; 
        SwitchLickLatOrg_threat = [SwitchLickLatOrg_threat SwitchLickLatOrg_threat_state];

end

glm_rwdLickSafe = fitglm([combinedRewardsMatx_safe]', combinedLickLat_safe);
glm_rwdLickThreat = fitglm([combinedRewardsMatx_threat]', combinedLickLat_threat);
glm_rwdLickSafeOrg = fitglm([combinedRewardsMatx_safe]', combinedLickLatOrg_safe);
glm_rwdLickThreatOrg = fitglm([combinedRewardsMatx_threat]', combinedLickLatOrg_threat);
%linear regression model

% glm_rwdLickSafe = fitglm([combinedRewardsMatx]', combinedLickLat);

% if p.Results.plotFlag
%     figure; hold on
%     relevInds = 2:tMax+1;
%     coefVals = glm_rwdLickSafe.Coefficients.Estimate(relevInds);
%     CIbands = coefCI(glm_rwdLickSafe);
%     errorL = abs(coefVals - CIbands(relevInds,1));
%     errorU = abs(coefVals - CIbands(relevInds,2));
%     errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)
% 
%     xlabel('Reward n Trials Back')
%     ylabel('\beta Coefficient')
%     xlim([0.5 tMax+0.5])
% 
%     suptitle([animal ' ' category])
% end