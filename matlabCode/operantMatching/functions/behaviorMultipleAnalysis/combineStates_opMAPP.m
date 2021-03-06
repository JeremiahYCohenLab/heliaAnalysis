 
function [glm_rwdNoRwd_safe, glm_rwdNoRwd_threat, tMax] = combineStates_opMAPP(xlFile, animal, category, revForFlag)

if nargin < 4
    %plotFlag = 0;
    revForFlag = 0;
end

[root, sep] = currComputer();


rwdRateMatx_safe = [];
rwdRateMatx_threat = [];
combinedChoicesMatx_threat = []; 
combinedRewardsMatx_threat = [];
combinedNoRewardsMatx_threat = [];
combinedTimesMatx_threat = [];
combinedChoicesMatx_safe = [];
combinedRewardsMatx_safe = [];
combinedNoRewardsMatx_safe = [];
combinedAllChoice_R_safe = [];
combinedAllChoice_R_threat = [];
responseInds_threat = [];
responseInds = [];
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
    sessionName = dayList{i};
    [animalName, date] = strtok(sessionName, 'd'); 
    animalName = animalName(2:end);
    date = date(1:9);
    sessionFolder = ['m' animalName date];
    if isstrprop(sessionName(end), 'alpha')
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sep sessionFolder(end) sep sep sessionFolder '_sessionData_behav.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sep sessionName '_sessionData_behav.mat'];
    end
%     if exist(sessionDataPath,'file')
%         load(sessionDataPath)
%         behSessionData = sessionData;
%         if revForFlag
%             [behSessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
%         end
%     elseif revForFlag                                    %otherwise generate the struct
        [behSessionData,blockSwitch, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
% 
%     else
%         [sessionData, ~, ~, ~] = generateSessionData_operantMatchingDecoupled(sessionName);
%     end
    responseInds = find(~isnan([behSessionData.rewardTime])); % find CS+ trials with a response in the lick window
    omitInds = isnan([behSessionData.rewardTime]); 
    stateType = [behSessionData(responseInds).stateType];
%     stateChangeInds_StT = find(diff([behSessionData(responseInds).stateType]) == -1) + 1;
%     stateChangeInds_TtS = find(diff([behSessionData(responseInds).stateType]) == 1) + 1;
    stateChangeInds = [1 (find(abs(diff([behSessionData(responseInds).stateType])) == 1) + 1)  length(responseInds)];

    allAirpuff = [behSessionData(responseInds).AirpuffTimeOn];
    allAirpuff(allAirpuff ~= 0) = 1;
    allReward_R = [behSessionData(responseInds).rewardR];
    allReward_L = [behSessionData(responseInds).rewardL]; 
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

%         outcomeTimes_threat = [behSessionData(h).rewardTime] - behSessionData(responseInds(1)).rewardTime;
%         outcomeTimes_threat = [diff(ht) NaN];
    rwdMatxTmp_threat_state = [];
    choiceMatxTmp_threat_state = [];
    noRwdMatxTmp_threat_state = [];
    airpuffMatxTmp_threat_state = [];
    ChoiceMatxTmp_R_threat_state = [];
    rwdMatxTmp_safe_state = [];
    choiceMatxTmp_safe_state = [];
    noRwdMatxTmp_safe_state = [];
    ChoiceMatxTmp_R_safe_state = [];
    rwdMatxTmp_threat = [];
    choiceMatxTmp_threat = [];
    noRwdMatxTmp_threat = [];
    airpuffMatxTmp_threat = [];
    ChoiceMatxTmp_R_threat = [];
    rwdMatxTmp_safe = [];
    choiceMatxTmp_safe = [];
    noRwdMatxTmp_safe = [];
        for currT = 1:length(stateChangeInds)-1
            if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
                if stateType(stateChangeInds(currT)) == 1
                    %add to threat choice and reward arrays between stateChangeInds(currT-1):stateChangeInds(currT)-1
                    for j = 1:tMax
                        rwdMatxTmp_threat(j,:) = [NaN(1,j) allRewards(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                        choiceMatxTmp_threat(j,:) = [NaN(1,j) allChoices(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                        noRwdMatxTmp_threat(j,:) = [NaN(1,j) allNoRewards(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                        airpuffMatxTmp_threat(j,:) = [NaN(1,j) allAirpuff(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                    end
                    rwdMatxTmp_threat_state = [rwdMatxTmp_threat_state NaN(tMax,15) rwdMatxTmp_threat];
                    choiceMatxTmp_threat_state = [choiceMatxTmp_threat_state NaN(tMax,15) choiceMatxTmp_threat];
                    noRwdMatxTmp_threat_state = [noRwdMatxTmp_threat_state NaN(tMax,15) noRwdMatxTmp_threat];
                    airpuffMatxTmp_threat_state = [airpuffMatxTmp_threat_state NaN(tMax,15) airpuffMatxTmp_threat];
                    ChoiceMatxTmp_R_threat_state = [ChoiceMatxTmp_R_threat_state NaN(1,15) allChoice_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                    choiceMatxTmp_threat = [];
                    noRwdMatxTmp_threat = [];
                    airpuffMatxTmp_threat = [];
                    ChoiceMatxTmp_R_threat = [];
                    rwdMatxTmp_threat = [];
                else
                     for j = 1:tMax
                        rwdMatxTmp_safe(j,:) = [NaN(1,j) allRewards(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                        choiceMatxTmp_safe(j,:) = [NaN(1,j) allChoices(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                        noRwdMatxTmp_safe(j,:) = [NaN(1,j) allNoRewards(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                     end
                    rwdMatxTmp_safe_state = [rwdMatxTmp_safe_state NaN(tMax,15) rwdMatxTmp_safe];
                    choiceMatxTmp_safe_state = [choiceMatxTmp_safe_state NaN(tMax,15) choiceMatxTmp_safe];
                    noRwdMatxTmp_safe_state = [noRwdMatxTmp_safe_state NaN(tMax,15) noRwdMatxTmp_safe];
                    ChoiceMatxTmp_R_safe_state = [ChoiceMatxTmp_R_safe_state NaN(1,15) allChoice_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                    rwdMatxTmp_safe = [];
                    choiceMatxTmp_safe = [];
                    noRwdMatxTmp_safe = [];
                    ChoiceMatxTmp_R_safe = [];
                end
            end
        end
    combinedRewardsMatx_threat = [combinedRewardsMatx_threat NaN(tMax,100) rwdMatxTmp_threat_state];
    combinedNoRewardsMatx_threat = [combinedNoRewardsMatx_threat NaN(tMax,100) noRwdMatxTmp_threat_state];
    combinedAllChoice_R_threat = [combinedAllChoice_R_threat NaN(1,100) ChoiceMatxTmp_R_threat_state];
    combinedAirpuff  = [combinedAirpuff NaN(tMax,100) airpuffMatxTmp_threat_state];
    combinedChoicesMatx_threat = [combinedChoicesMatx_threat NaN(tMax,100)  choiceMatxTmp_threat_state];
    combinedChoicesMatx_safe = [combinedChoicesMatx_safe NaN(tMax,100) choiceMatxTmp_safe_state];
    combinedRewardsMatx_safe = [combinedRewardsMatx_safe NaN(tMax,100) rwdMatxTmp_safe_state];
    combinedNoRewardsMatx_safe = [combinedNoRewardsMatx_safe NaN(tMax,100) noRwdMatxTmp_safe_state];
    combinedAllChoice_R_safe = [combinedAllChoice_R_safe NaN(1,100) ChoiceMatxTmp_R_safe_state];
end

%logistic regression models
glm_rwd_threat = fitglm([combinedRewardsMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{1} = num2str(round(glm_rwd_threat.Rsquared.Adjusted*100)/100);
glm_choice_threat = fitglm([combinedChoicesMatx_threat]', combinedAllChoice_R_threat, 'distribution','binomial','link','logit'); rsq{3} = num2str(round(glm_choice_threat.Rsquared.Adjusted*100)/100);
glm_rwdANDchoice_threat = fitglm([combinedRewardsMatx_threat' combinedChoicesMatx_threat'], combinedAllChoice_R_threat, 'distribution','binomial','link','logit'); rsq{2} = num2str(round(glm_rwdANDchoice_threat.Rsquared.Adjusted*100)/100);
% % glm_time_threat = fitglm([combinedTimesMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{4} = num2str(round(glm_time_threat.Rsquared.Adjusted*100)/100);
% % glm_rwdANDtime_threat = fitglm([combinedRewardsMatx_threat' combinedTimesMatx_threat'], combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{5} = num2str(round(glm_rwdANDtime_threat.Rsquared.Adjusted*100)/100);
glm_rwdRate_threat = fitglm([rwdRateMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{6} = num2str(round(glm_rwd_threat.Rsquared.Adjusted*100)/100);
glm_rwdNoRwd_threat = fitglm([combinedRewardsMatx_threat' combinedNoRewardsMatx_threat'], combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_rwdNoRwd_threat.Rsquared.Adjusted*100)/100);
glm_all_threat = fitglm([combinedRewardsMatx_threat' combinedNoRewardsMatx_threat' combinedChoicesMatx_threat'], combinedAllChoice_R_threat, 'distribution','binomial','link','logit');
glm_AirpuffANDchoice =  fitglm([combinedAirpuff'], combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_AirpuffANDchoice.Rsquared.Adjusted*100)/100);
glm_rwd_safe = fitglm([combinedRewardsMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{1} = num2str(round(glm_rwd_safe.Rsquared.Adjusted*100)/100);
glm_choice_safe = fitglm([combinedChoicesMatx_safe]', combinedAllChoice_R_safe, 'distribution','binomial','link','logit'); rsq{3} = num2str(round(glm_choice_safe.Rsquared.Adjusted*100)/100);
glm_rwdANDchoice_safe = fitglm([combinedRewardsMatx_safe' combinedChoicesMatx_safe'], combinedAllChoice_R_safe, 'distribution','binomial','link','logit'); rsq{2} = num2str(round(glm_rwdANDchoice_safe.Rsquared.Adjusted*100)/100);
% glm_time_safe = fitglm([combinedTimesMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{4} = num2str(round(glm_time_safe.Rsquared.Adjusted*100)/100);
% glm_rwdANDtime_safe = fitglm([combinedRewardsMatx_safe' combinedTimesMatx_safe'], combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{5} = num2str(round(glm_rwdANDtime_safe.Rsquared.Adjusted*100)/100);
glm_rwdRate_safe = fitglm([rwdRateMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{6} = num2str(round(glm_rwd_safe.Rsquared.Adjusted*100)/100);
glm_rwdNoRwd_safe = fitglm([combinedRewardsMatx_safe' combinedNoRewardsMatx_safe'], combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_rwdNoRwd_safe.Rsquared.Adjusted*100)/100);
glm_all_safe = fitglm([combinedRewardsMatx_safe' combinedNoRewardsMatx_safe' combinedChoicesMatx_safe'], combinedAllChoice_R_safe, 'distribution','binomial','link','logit');
% figure; hold on;
% relevInds = 2:tMax+1;
% coefVals = glm_all_threat.Coefficients.Estimate(relevInds);
% CIbands = coefCI(glm_rwdNoRwd_threat);
% errorL = abs(coefVals - CIbands(relevInds,1));
% errorU = abs(coefVals - CIbands(relevInds,2));
% errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', [0.8,1,0],'linewidth',2);
% % 
% % relevInds = tMax+2:length(glm_rwdNoRwd_threat.Coefficients.Estimate);
% % coefVals = glm_rwdNoRwd_threat.Coefficients.Estimate(relevInds);
% % CIbands = coefCI(glm_rwdNoRwd_threat);
% % errorL = abs(coefVals - CIbands(relevInds,1));
% % errorU = abs(coefVals - CIbands(relevInds,2));
% % errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', 'b' ,'linewidth',2)
% % 
% xlabel('choice and reward no reward under threat')
% ylabel('\beta Coefficient')
% xlim([0.5 tMax+0.5])
% legend('choice and reward no reward history')
% title([animal ' ' category])
% % end
% 