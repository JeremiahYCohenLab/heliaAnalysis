%%between pre and post sessions 3-same parameters have been calculaed in
% combine safe states only and does glm for rw and no rw history amd choice
 
 function [glm_rwdNoRwd_safe, tMax] = combineStates_opMAP(xlFile, animal, category, revForFlag)

% if nargin < 5
%     plotFlag = 0;
% end
if nargin <4
    revForFlag = 0;
end


[root, sep] = currComputer();

% rwdRateMatx = [];
% rwdRateMatx_safe = [];
combinedChoicesMatx = []; 
combinedChoicesMatx_safe = [];
combinedRewardsMatx = [];
combinedRewardsMatx_safe = [];
combinedNoRewardsMatx = [];
combinedNoRewardsMatx_safe = [];
combinedTimesMatx = [];
combinedTimesMatx_safe = [];
combinedAllChoice_R_safe = [];
responseInds_safe = [];
combinedAirpuff = [];

tMax = 12;


[weights, dayList, ~] = xlsread(xlFile, animal);
[~,col] = find(~cellfun(@isempty,strfind(dayList, category)) == 1);
dayList = dayList(2:end,col);
endInd = find(cellfun(@isempty,dayList),1);
if ~isempty(endInd)
    dayList = dayList(1:endInd-1,:);
end


for i = 1: length(dayList)
    rwdRateMatx_safe_state = [];
    combinedRewardsMatx_safe_state = [];
    combinedNoRewardsMatx_safe_state = [];
    combinedChoicesMatx_safe_state = [];
    combinedAllChoice_R_safe_state = [ ];
    combinedAirpuff_state = [];
    sessionName = dayList{i};
    [animalName, date] = strtok(sessionName, 'd'); 
    animalName = animalName(2:end);
    date = date(1:9);
    sessionFolder = ['m' animalName date];

    if isstrprop(sessionName(end), 'alpha')
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sessionName(end) sep sessionName '_sessionData_behav.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sep sessionName '_sessionData_behav.mat'];
    end
%     if exist(sessionDataPath,'file')
%         load(sessionDataPath)
%         behSessionData = sessionData;
        if revForFlag
            [behSessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
        end
%     elseif revForFlag                                    %otherwise generate the struct
%         [behsessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
% 
%     else
%         [sessionData, ~, ~, ~] = generateSessionData_operantMatchingDecoupled(sessionName);
%     end
    
    responseInds = find(~isnan([behSessionData.rewardTime])); % find CS+ trials with a response in the lick window
    omitInds = isnan([behSessionData.rewardTime]); 
    responseInds_safe = find([behSessionData(responseInds).stateType] == 0);
%     responseInds_threatTmp = find([behSessionData(responseInds).stateType] == 1);
    
    stateInds = [behSessionData(responseInds).stateType];
    stateSwitchInd_safeTmp = NaN(1,length(responseInds)); 
    for h = 1: length(responseInds)-1
        if(isnan(stateSwitchInd_safeTmp(h)))
            if(behSessionData(responseInds(h)).stateType- behSessionData(responseInds(h+1)).stateType <= -1 )
                    stateSwitchInd_safeTmp(1,h) = h;
                    stateSwitchInd_safeTmp(1,h+1)=0;
            elseif(behSessionData(responseInds(h)).stateType- behSessionData(responseInds(h+1)).stateType >= 1 )
              stateSwitchInd_safeTmp(1,h+1) = h+1;
            end
        end
    end

    stateSwitchInd_safe = [];
    stateSwitchInd_safe = [stateSwitchInd_safe find(~isnan(stateSwitchInd_safeTmp))]; 
    stateSwitchInd_safe = [1  stateSwitchInd_safe];
    if(behSessionData(length(responseInds)).stateType == 0)
        stateSwitchInd_safe = [stateSwitchInd_safe length(responseInds)];
    end

    allReward_R = [behSessionData(responseInds).rewardR];
    allReward_L= [behSessionData(responseInds).rewardL]; 
    allChoices = NaN(1,length(behSessionData(responseInds)));
    allChoices(~isnan(allReward_R)) = 1;
    allChoices(~isnan(allReward_L)) = -1;
    allReward_R(isnan(allReward_R)) = 0;
    allReward_L(isnan(allReward_L)) = 0;

    allChoice_R = double(allChoices == 1);
    allChoice_L = double(allChoices == -1);

    allRewards = zeros(1,length(allChoices));
    allRewards(logical(allReward_R)) = 1;
    allRewards(logical(allReward_L)) = -1;

    allNoRewards = allChoices;
    allNoRewards(logical(allReward_R)) = 0;
    allNoRewards(logical(allReward_L)) = 0;

%     outcomeTimes_safe = [behSessionData(responseInds_safe(d:h))).rewardTime] - behSessionData(responseInds(1)).rewardTime;
%     outcomeTimes_safe = [diff(outcomeTimes_safe) NaN];

    rwdMatxTmp_safe = [];
    choiceMatxTmp_safe = [];
    noRwdMatxTmp_safe = [];
    airpuffMatxTmp = [];
    for l = 1: length(stateSwitchInd_safe)-1
        rwdMatxTmp_safe = [];
        choiceMatxTmp_safe = [];
        noRwdMatxTmp_safe = [];
        airpuffMatxTmp = [];
        choiceMatxTmp_threat = [];
        if(stateSwitchInd_safeTmp(stateSwitchInd_safe(l+1)) ~=0 && stateSwitchInd_safeTmp(stateSwitchInd_safe(l)) ~= 0)
            if (length(stateSwitchInd_safe(l):stateSwitchInd_safe(l+1))> tMax)
                for j = 1:tMax
                    rwdMatxTmp_safe(j,:) = [NaN(1,j) allRewards(stateSwitchInd_safe(l):stateSwitchInd_safe(l+1)-j)];
                    choiceMatxTmp_safe(j,:) = [NaN(1,j) allChoices(stateSwitchInd_safe(l):stateSwitchInd_safe(l+1)-j)];
                    noRwdMatxTmp_safe(j,:) = [NaN(1,j) allNoRewards(stateSwitchInd_safe(l):stateSwitchInd_safe(l+1)-j)];
                end         
                 combinedRewardsMatx_safe_state = [combinedRewardsMatx_safe_state NaN(tMax, 15) rwdMatxTmp_safe];
                 combinedNoRewardsMatx_safe_state = [combinedNoRewardsMatx_safe_state NaN(tMax,15) noRwdMatxTmp_safe];
                 combinedChoicesMatx_safe_state = [combinedChoicesMatx_safe_state NaN(tMax,15) choiceMatxTmp_safe];
                 combinedAllChoice_R_safe_state = [combinedAllChoice_R_safe_state NaN(1,15) allChoice_R(:,stateSwitchInd_safe(l):stateSwitchInd_safe(l+1))];
            end
        end
    end

    combinedRewardsMatx_safe = [combinedRewardsMatx_safe NaN(tMax,100) combinedRewardsMatx_safe_state];
    combinedNoRewardsMatx_safe = [combinedNoRewardsMatx_safe NaN(tMax,100) combinedNoRewardsMatx_safe_state];
    combinedAllChoice_R_safe = [combinedAllChoice_R_safe NaN(1,100) combinedAllChoice_R_safe_state];
    combinedChoicesMatx_safe = [combinedChoicesMatx_safe  NaN(tMax,100) combinedChoicesMatx_safe_state];
end



%logistic regression models
glm_rwd_safe = fitglm([combinedRewardsMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{1} = num2str(round(glm_rwd_safe.Rsquared.Adjusted*100)/100);
glm_choice_safe = fitglm([combinedChoicesMatx_safe]', combinedAllChoice_R_safe, 'distribution','binomial','link','logit'); rsq{3} = num2str(round(glm_choice_safe.Rsquared.Adjusted*100)/100);
glm_rwdANDchoice_safe = fitglm([combinedRewardsMatx_safe' combinedChoicesMatx_safe'], combinedAllChoice_R_safe, 'distribution','binomial','link','logit'); rsq{2} = num2str(round(glm_rwdANDchoice_safe.Rsquared.Adjusted*100)/100);
% glm_time_safe = fitglm([combinedTimesMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{4} = num2str(round(glm_time_safe.Rsquared.Adjusted*100)/100);
glm_rwdANDtime_safe = fitglm([combinedRewardsMatx_safe' combinedTimesMatx_safe'], combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{5} = num2str(round(glm_rwdANDtime_safe.Rsquared.Adjusted*100)/100);
% glm_rwdRate_safe = fitglm([rwdRateMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{6} = num2str(round(glm_rwd_safe.Rsquared.Adjusted*100)/100);
glm_rwdNoRwd_safe = fitglm([combinedRewardsMatx_safe' combinedNoRewardsMatx_safe'], combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_rwdNoRwd_safe.Rsquared.Adjusted*100)/100);
glm_all_safe = fitglm([combinedRewardsMatx_safe' combinedNoRewardsMatx_safe' combinedChoicesMatx_safe'], combinedAllChoice_R_safe, 'distribution','binomial','link','logit');
hold on;
figure; hold on;
relevInds = 2:tMax+1;
coefVals = glm_all_safe.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_rwdNoRwd_safe);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', [0.8784    0.6157    0.8627],'linewidth',2)
% 
% % if plotFlag
% 
% relevInds = tMax+2:length(glm_rwdNoRwd_safe.Coefficients.Estimate);
% coefVals = glm_rwdNoRwd_safe.Coefficients.Estimate(relevInds);
% CIbands = coefCI(glm_rwdNoRwd_safe);
% errorL = abs(coefVals - CIbands(relevInds,1));
% errorU = abs(coefVals - CIbands(relevInds,2));
% errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'b','linewidth',2)
% 
xlabel('all Trials Back')
ylabel('\beta Coefficient')
xlim([0.5 tMax+0.5])
legend('choice reward no reward')
title([animal ' ' category])
% % end

