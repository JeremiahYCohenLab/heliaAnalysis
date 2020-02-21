function [glm_AirpuffANDchoice, tMax] = combineStates_AirpuffLog(xlFile, animal, category, revForFlag)
%%Logit(GLM) of airpuff history and choice based on trials in thereatening state. 

if nargin < 4
    %plotFlag = 0;
    revForFlag = 0;
end

[root, sep] = currComputer();


rwdRateMatx = [];
combinedChoicesMatx = []; 
combinedRewardsMatx = [];
combinedNoRewardsMatx = [];
combinedTimesMatx = [];
combinedAllChoice_R = [];
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
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sessionName(end) sep sessionName '_sessionData_behav.mat'];
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
    stateChangeInds = [1 (find(abs(diff([behSessionData(responseInds).stateType])) == 1) + 1) length(responseInds)];
    allAirpuff = NaN(1,length(behSessionData(responseInds)));
    allAirpuffInd = [behSessionData(responseInds).AirpuffTimeOn];
    allAirpuff(~allAirpuffInd == 0) = 1;
    allAirpuff(isnan(allAirpuff)) = 0;
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

    choiceMatxTmp_threat = [];
    noRwdMatxTmp_threat = [];
    airpuffMatxTmp = [];
        for currT = 1:length(stateChangeInds)-1
         if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
            if stateType(stateChangeInds(currT)) == 1
                rwdMatxTmp_threat = []; %will make an upper triangle matrix
                for j = 1:tMax
                    rwdMatxTmp_threat(j,:) = [NaN(1,j) allRewards(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                    choiceMatxTmp_threat(j,:) = [NaN(1,j) allChoices(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                    noRwdMatxTmp_threat(j,:) = [NaN(1,j) allNoRewards(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                end
                combinedRewardsMatx_threat_state = [combinedRewardsMatx_threat_state NaN(tMax,15) rwdMatxTmp_threat(:,1:end-1)];
            end
         end
    for currT = 1:length(stateChangeInds)-1   %% determine lick latency for stay v switch trials for safe and threat sepearetaly
         if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
            if stateType(stateChangeInds(currT)) == 1 %plus 2 to not look at the first lick lat
                combinedAirpuff_state = [combinedAirpuff_state NaN(1,15) allAirpuff(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
            end
         end
    end
    
   allRewards(allRewards == -1) = 1;
 
    rwdsTmp = NaN(tMax,length(allRewards)); 
    for j = 1:tMax
        for k = 1:length(outcomeTimes_threat)-j
             rwdsTmp(j,k+j) = sum(allRewards(k:k+j-1));
        end
    end
    
    rwdRateMatx = [rwdRateMatx NaN(tMax, 100) (rwdsTmp ./ timeTmp)];
    combinedRewardsMatx = [combinedRewardsMatx NaN(tMax,100) rwdMatxTmp_threat];
    combinedNoRewardsMatx = [combinedNoRewardsMatx NaN(tMax,100) noRwdMatxTmp_threat];
    combinedChoicesMatx = [combinedChoicesMatx NaN(tMax,100) choiceMatxTmp_threat];
    combinedTimesMatx = [combinedTimesMatx NaN(tMax, 100) timeTmp];
    combinedAllChoice_R = [combinedAllChoice_R NaN(1,100) allChoice_R];
    combinedAirpuff = [combinedAirpuff NaN(tMax,100) combinedAirpuff_state];
end


%logistic regression models
% glm_rwd = fitglm([combinedRewardsMatx]', combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{1} = num2str(round(glm_rwd.Rsquared.Adjusted*100)/100);
% glm_choice = fitglm([combinedChoicesMatx]', combinedAllChoice_R, 'distribution','binomial','link','logit'); rsq{3} = num2str(round(glm_choice.Rsquared.Adjusted*100)/100);
% glm_rwdANDchoice = fitglm([combinedRewardsMatx' combinedChoicesMatx'], combinedAllChoice_R, 'distribution','binomial','link','logit'); rsq{2} = num2str(round(glm_rwdANDchoice.Rsquared.Adjusted*100)/100);
% glm_time = fitglm([combinedTimesMatx]', combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{4} = num2str(round(glm_time.Rsquared.Adjusted*100)/100);
% glm_rwdANDtime = fitglm([combinedRewardsMatx' combinedTimesMatx'], combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{5} = num2str(round(glm_rwdANDtime.Rsquared.Adjusted*100)/100);
% glm_rwdRate = fitglm([rwdRateMatx]', combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{6} = num2str(round(glm_rwd.Rsquared.Adjusted*100)/100);
% glm_rwdNoRwd = fitglm([combinedRewardsMatx' combinedNoRewardsMatx'], combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_rwdNoRwd.Rsquared.Adjusted*100)/100);
% glm_all = fitglm([combinedRewardsMatx' combinedNoRewardsMatx' combinedChoicesMatx'], combinedAllChoice_R, 'distribution','binomial','link','logit');
% hold on;
glm_rwd_threat = fitglm([combinedRewardsMatx]', combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{1} = num2str(round(glm_rwd_threat.Rsquared.Adjusted*100)/100);
glm_choice_threat = fitglm([combinedChoicesMatx]', combinedAllChoice_R, 'distribution','binomial','link','logit'); rsq{3} = num2str(round(glm_choice_threat.Rsquared.Adjusted*100)/100);
glm_rwdANDchoice_threat = fitglm([combinedRewardsMatx' combinedChoicesMatx'], combinedAllChoice_R, 'distribution','binomial','link','logit'); rsq{2} = num2str(round(glm_rwdANDchoice_threat.Rsquared.Adjusted*100)/100);
glm_time_threat = fitglm([combinedTimesMatx]', combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{4} = num2str(round(glm_time_threat.Rsquared.Adjusted*100)/100);
glm_rwdANDtime_threat = fitglm([combinedRewardsMatx' combinedTimesMatx'], combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{5} = num2str(round(glm_rwdANDtime_threat.Rsquared.Adjusted*100)/100);
glm_rwdRate_threat = fitglm([rwdRateMatx]', combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{6} = num2str(round(glm_rwd_threat.Rsquared.Adjusted*100)/100);
glm_rwdNoRwd_threat = fitglm([combinedRewardsMatx' combinedNoRewardsMatx'], combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_rwdNoRwd_threat.Rsquared.Adjusted*100)/100);
glm_all_threat = fitglm([combinedRewardsMatx' combinedNoRewardsMatx' combinedChoicesMatx'], combinedAllChoice_R, 'distribution','binomial','link','logit');
glm_AirpuffANDchoice =  fitglm([combinedAirpuff'], combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_AirpuffANDchoice.Rsquared.Adjusted*100)/100);

figure; hold on;
relevInds = 2:tMax+1;
coefVals = glm_AirpuffANDchoice.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_AirpuffANDchoice);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2);

relevInds = tMax+2:length(glm_AirpuffANDchoice.Coefficients.Estimate);
coefVals = glm_AirpuffANDchoice.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_AirpuffANDchoice);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', 'b' ,'linewidth',2)

xlabel('Airpuff n Trials Back')
ylabel('\beta Coefficient')
xlim([0.5 tMax+0.5])
legend('rwd', 'no rwd')
title([animal ' ' category])
% end

