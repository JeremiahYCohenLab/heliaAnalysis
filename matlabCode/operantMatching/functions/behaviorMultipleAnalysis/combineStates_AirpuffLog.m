function [glm_AirpuffANDchoice, tMax] = combineStates_AirpuffLog(xlFile, animal, category, revForFlag, trialFlag)
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
combinedAllChoice_R = [];
responseInds_threat = [];
responseInds = [];
combinedAirpuff = [];
combinedChoiceMatxTmp_threat = [];
combinedrwdMatxTmp_threat = [];
combinednoRwdMatxTmp =[];


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
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sessionFolder(end) sep sessionFolder '_sessionData_behav.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sep sessionName '_sessionData_behav.mat'];
    end
    if exist(sessionDataPath,'file')
        load(sessionDataPath)
        behSessionData = sessionData;
        if revForFlag
            [behSessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
        end
    elseif revForFlag                                    %otherwise generate the struct
        [behSessionData,~, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);

    else
        [sessionData, ~, ~, ~] = generateSessionData_operantMatchingDecoupled(sessionName);
    end
    
    responseInds = find(~isnan([behSessionData.rewardTime])); % find CS+ trials with a response in the lick window
    omitInds = isnan([behSessionData.rewardTime]); 
    stateType = [behSessionData(responseInds).stateType];
    stateChangeInds = [1 (find(abs(diff([behSessionData(responseInds).stateType])) == 1) + 1) length(responseInds)];
    allAirpuff = NaN(1,length(behSessionData(responseInds)));
    allAirpuffInd = [behSessionData(responseInds).AirpuffTimeOn];
    allAirpuff(allAirpuffInd ~= 0) = 1;
    allAirpuff(isnan(allAirpuff)) = 0;
    allReward_R = [behSessionData(responseInds).rewardR];
    allReward_L = [behSessionData(responseInds).rewardL]; 
    allChoices = NaN(1,length(behSessionData(responseInds)));
    allChoices(~isnan(allReward_R)) = 1;
    allChoices(~isnan(allReward_L)) = 0;

    allReward_R(isnan(allReward_R)) = 0;
    allReward_L(isnan(allReward_L)) = 0;
    allChoice_R = double(allChoices == 1);
    allChoice_L = double(allChoices == 0);

    allRewards = zeros(1,length(allChoices));
    allRewards(logical(allReward_R)) = 1;
    allRewards(logical(allReward_L)) = 0;

    allNoRewards = allChoices;
    allNoRewards(logical(allReward_R)) = 0;
    allNoRewards(logical(allReward_L)) = 0;

    
    ChoiceMatxTmp_threat_state = [];
    airpuffMatxTmp = [];
    combinedAirpuff_state = [];
    airpuffMatxTmp_threat_state = [];
    ChoiceMatxTmp_R_threat_state = [];
    rwdMatxTmp_threat = [];
    noRwdMatxTmp_threat =[];
        for currT = 1:length(stateChangeInds)-1
         if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
            if stateType(stateChangeInds(currT)) == 1
                 %will make an upper triangle matrix
                for j = 1:tMax
                    airpuffMatxTmp_threat(j,:) = [NaN(1,j) allAirpuff(stateChangeInds(currT):stateChangeInds(currT+1)-1-j)];
                end
                airpuffMatxTmp_threat_state = [airpuffMatxTmp_threat_state NaN(tMax,15) airpuffMatxTmp_threat];
                ChoiceMatxTmp_R_threat_state = [ChoiceMatxTmp_R_threat_state NaN(1,15) allChoice_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                ChoiceMatxTmp_threat_state = [ChoiceMatxTmp_threat_state NaN(1,15) allChoices(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                rwdMatxTmp_threat = [rwdMatxTmp_threat NaN(1,15) allRewards(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                noRwdMatxTmp_threat = [noRwdMatxTmp_threat NaN(1,15) allNoRewards(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                airpuffMatxTmp_threat = [];
            end
         end
        end 
%     for currT = 1:length(stateChangeInds)-1   %% determine lick latency for stay v switch trials for safe and threat sepearetaly
%          if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
%             if stateType(stateChangeInds(currT)) == 1 %plus 2 to not look at the first lick lat
%                 combinedAirpuff_state = [combinedAirpuff_state NaN(1,15) allAirpuff(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
%             end
%          end
%     end
    
%    allRewards(allRewards == -1) = 1;
 
%     rwdsTmp = NaN(tMax,length(allRewards)); 
%     for j = 1:tMax
%         for k = 1:length(outcomeTimes_threat)-j
%              rwdsTmp(j,k+j) = sum(allRewards(k:k+j-1));
%         end
%     end
    
    combinedAllChoice_R = [combinedAllChoice_R NaN(1,100) ChoiceMatxTmp_R_threat_state];
    combinedChoiceMatxTmp_threat = [combinedChoiceMatxTmp_threat NaN(1,100)  ChoiceMatxTmp_threat_state];
    combinedrwdMatxTmp_threat = [combinedrwdMatxTmp_threat NaN(1,100)  rwdMatxTmp_threat];
    combinednoRwdMatxTmp = [combinednoRwdMatxTmp NaN(1,100)  noRwdMatxTmp_threat];
    combinedAirpuff = [combinedAirpuff NaN(tMax,100) airpuffMatxTmp_threat_state];
end


%logistic regression models



glm_AirpuffANDchoiceR =  fitglm([combinedAirpuff'], combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_AirpuffANDchoiceR.Rsquared.Adjusted*100)/100);
glm_AirpuffANDchoice =  fitglm([combinedAirpuff'], combinedChoiceMatxTmp_threat,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_AirpuffANDchoice.Rsquared.Adjusted*100)/100);
glm_AirpuffANDRew = fitglm([combinedAirpuff'], combinedrwdMatxTmp_threat,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_AirpuffANDRew.Rsquared.Adjusted*100)/100);
glm_AirpuffANDnoRew = fitglm([combinedAirpuff'], combinednoRwdMatxTmp,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_AirpuffANDnoRew.Rsquared.Adjusted*100)/100);

subplot(2,2,1); hold on;
relevInds = 2:tMax+1;
coefVals = glm_AirpuffANDchoiceR.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_AirpuffANDchoiceR);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
if trialFlag
    errorbar([1:tMax],coefVals,errorL,errorU,'Color',[1.0000 0.5804 0.7216],'linewidth',2)
else
    errorbar(((1:s.tMax)*s.binSize/1000),coefVals,errorL,errorU,'Color', [1.0000 0.5804 0.7216],'linewidth',2)
     xlim([0 (s.tMax*s.binSize/1000 + s.binSize/1000)])
end
xlabel('Airpuff n Trials Back')
ylabel('\beta Coefficient choices R')
xlim([0.5 tMax+0.5])
title([animal ' ' category])

subplot(2,2,2); hold on;
coefVals = glm_AirpuffANDchoice.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_AirpuffANDchoice);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
if trialFlag
    errorbar([1:tMax],coefVals,errorL,errorU,'Color', [0.6863 0.7216 0.2314],'linewidth',2)
else
    errorbar(((1:s.tMax)*s.binSize/1000),coefVals,errorL,errorU,'Color', [0.6863 0.7216 0.2314],'linewidth',2)
    xlim([0 (s.tMax*s.binSize/1000 + s.binSize/1000)])
end
xlabel('Airpuff n Trials Back')
ylabel('\beta Coefficient all choices')
xlim([0.5 tMax+0.5])

subplot(2,2,3); hold on;
coefVals = glm_AirpuffANDRew.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_AirpuffANDRew);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
if trialFlag
    errorbar([1:tMax],coefVals,errorL,errorU,'Color', [0.6863 0.7216 0.2314],'linewidth',2)
else
    errorbar(((1:s.tMax)*s.binSize/1000),coefVals,errorL,errorU,'Color', [0.6863 0.7216 0.2314],'linewidth',2)
    xlim([0 (s.tMax*s.binSize/1000 + s.binSize/1000)]);
end

xlabel('Airpuff n Trials Back')
ylabel('\beta Coefficient rewards')
xlim([0.5 tMax+0.5])

subplot(2,2,4); hold on;
coefVals = glm_AirpuffANDnoRew.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_AirpuffANDnoRew);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
if trialFlag
    errorbar([1:tMax],coefVals,errorL,errorU,'Color', [0.6863 0.7216 0.2314],'linewidth',2)
else
    errorbar(((1:s.tMax)*s.binSize/1000),coefVals,errorL,errorU,'Color', [0.6863 0.7216 0.2314],'linewidth',2)
    xlim([0 (s.tMax*s.binSize/1000 + s.binSize/1000)])
end
xlabel('Airpuff n Trials Back')
ylabel('\beta Coefficient no rewards')
xlim([0.5 tMax+0.5])



% relevInds = tMax+2:tMax*2+1;
% coefVals = glm_AirpuffANDchoice.Coefficients.Estimate(relevInds);
% CIbands = coefCI(glm_AirpuffANDchoice);
% errorL = abs(coefVals - CIbands(relevInds,1));
% errorU = abs(coefVals - CIbands(relevInds,2));
% errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2);

% relevInds = tMax+2:length(glm_AirpuffANDchoice.Coefficients.Estimate);
% coefVals = glm_AirpuffANDchoice.Coefficients.Estimate(relevInds);
% CIbands = coefCI(glm_AirpuffANDchoice);
% errorL = abs(coefVals - CIbands(relevInds,1));
% errorU = abs(coefVals - CIbands(relevInds,2));
% errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', 'b' ,'linewidth',2)

title([animal ' ' category])
% end

end