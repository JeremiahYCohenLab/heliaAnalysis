 
function [glm_rwdNoRwd_threat, tMax] = combineStates_threat_opMAPP(xlFile, animal, category, revForFlag)

if nargin < 4
    %plotFlag = 0;
    revForFlag = 0;
end

[root, sep] = currComputer();


rwdRateMatx_threat = [];
combinedChoicesMatx_threat = []; 
combinedRewardsMatx_threat = [];
combinedNoRewardsMatx_threat = [];
combinedTimesMatx_threat = [];
combinedAllChoice_R_threat = [];
responseInds_threat = [];
responseInds = [];

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
    if exist(sessionDataPath,'file')
        load(sessionDataPath)
        behSessionData = sessionData;
        if revForFlag
            [behSessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
        end
    elseif revForFlag                                    %otherwise generate the struct
        [behsessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);

    else
        [sessionData, ~, ~, ~] = generateSessionData_operantMatchingDecoupled(sessionName);
    end
    
    responseInds = find(~isnan([behSessionData.rewardTime])); % find CS+ trials with a response in the lick window
    omitInds = isnan([behSessionData.rewardTime]); 
    responseInds_threat = find([behSessionData.stateType] == 1);
    allReward_R_threat = [behSessionData(responseInds_threat).rewardR];
    allReward_L_threat = [behSessionData(responseInds_threat).rewardL]; 
    allChoices_threat = NaN(1,length(behSessionData(responseInds_threat)));
    allChoices_threat(~isnan(allReward_R_threat)) = 1;
    allChoices_threat(~isnan(allReward_L_threat)) = -1;

    allReward_R_threat(isnan(allReward_R_threat)) = 0;
    allReward_L_threat(isnan(allReward_L_threat)) = 0;
    allChoice_R_threat = double(allChoices_threat == 1);
    allChoice_L_threat = double(allChoices_threat == -1);

    allRewards_threat = zeros(1,length(allChoices_threat));
    allRewards_threat(logical(allReward_R_threat)) = 1;
    allRewards_threat(logical(allReward_L_threat)) = -1;

    allNoRewards_threat = allChoices_threat;
    allNoRewards_threat(logical(allReward_R_threat)) = 0;
    allNoRewards_threat(logical(allReward_L_threat)) = 0;

    outcomeTimes_threat = [behSessionData(responseInds_threat).rewardTime] - behSessionData(responseInds(1)).rewardTime;
    outcomeTimes_threat = [diff(outcomeTimes_threat) NaN];

    rwdMatxTmp_threat = [];
    choiceMatxTmp_threat = [];
    noRwdMatxTmp_threat = [];
        
    for j = 1:tMax
        rwdMatxTmp_threat(j,:) = [NaN(1,j) allRewards_threat(1:end-j)];
        choiceMatxTmp_threat(j,:) = [NaN(1,j) allChoices_threat(1:end-j)];
        noRwdMatxTmp_threat(j,:) = [NaN(1,j) allNoRewards_threat(1:end-j)];
    end

    timeTmp_threat = NaN(tMax,length(allRewards_threat)); 
    for j = 1:tMax
        for k = 1:length(outcomeTimes_threat)-j
            timeTmp_threat(j,k+j) = sum(outcomeTimes_threat(k:k+j-1));
        end
            
    end
    
%    allRewards(allRewards == -1) = 1;
 
    rwdsTmp_threat = NaN(tMax,length(allRewards_threat)); 
    for j = 1:tMax
        for k = 1:length(outcomeTimes_threat)-j
             rwdsTmp_threat(j,k+j) = sum(allRewards_threat(k:k+j-1));
        end
    end
    
    rwdRateMatx_threat = [rwdRateMatx_threat NaN(tMax, 100) (rwdsTmp_threat ./ timeTmp_threat)];
    combinedRewardsMatx_threat = [combinedRewardsMatx_threat NaN(tMax,100) rwdMatxTmp_threat];
    combinedNoRewardsMatx_threat = [combinedNoRewardsMatx_threat NaN(tMax,100) noRwdMatxTmp_threat];
    combinedChoicesMatx_threat = [combinedChoicesMatx_threat NaN(tMax,100) choiceMatxTmp_threat];
    combinedTimesMatx_threat = [combinedTimesMatx_threat NaN(tMax, 100) timeTmp_threat];
    combinedAllChoice_R_threat = [combinedAllChoice_R_threat NaN(1,100) allChoice_R_threat];
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
glm_rwd_threat = fitglm([combinedRewardsMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{1} = num2str(round(glm_rwd_threat.Rsquared.Adjusted*100)/100);
glm_choice_threat = fitglm([combinedChoicesMatx_threat]', combinedAllChoice_R_threat, 'distribution','binomial','link','logit'); rsq{3} = num2str(round(glm_choice_threat.Rsquared.Adjusted*100)/100);
glm_rwdANDchoice_threat = fitglm([combinedRewardsMatx_threat' combinedChoicesMatx_threat'], combinedAllChoice_R_threat, 'distribution','binomial','link','logit'); rsq{2} = num2str(round(glm_rwdANDchoice_threat.Rsquared.Adjusted*100)/100);
glm_time_threat = fitglm([combinedTimesMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{4} = num2str(round(glm_time_threat.Rsquared.Adjusted*100)/100);
glm_rwdANDtime_threat = fitglm([combinedRewardsMatx_threat' combinedTimesMatx_threat'], combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{5} = num2str(round(glm_rwdANDtime_threat.Rsquared.Adjusted*100)/100);
glm_rwdRate_threat = fitglm([rwdRateMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{6} = num2str(round(glm_rwd_threat.Rsquared.Adjusted*100)/100);
glm_rwdNoRwd_threat = fitglm([combinedRewardsMatx_threat' combinedNoRewardsMatx_threat'], combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_rwdNoRwd_threat.Rsquared.Adjusted*100)/100);
glm_all_threat = fitglm([combinedRewardsMatx_threat' combinedNoRewardsMatx_threat' combinedChoicesMatx_threat'], combinedAllChoice_R_threat, 'distribution','binomial','link','logit');
figure; hold on;
relevInds = 2:tMax+1;
coefVals = glm_rwdNoRwd_threat.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_rwdNoRwd_threat);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));

% if plotFlag
     figure; hold on;
    relevInds = 2:tMax+1;
    coefVals = glm_rwdNoRwd_threat.Coefficients.Estimate(relevInds);
    CIbands = coefCI(glm_rwdNoRwd_threat);
    errorL = abs(coefVals - CIbands(relevInds,1));
    errorU = abs(coefVals - CIbands(relevInds,2));
    errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)

%     relevInds = tMax+2:length(glm_rwdNoRwd.Coefficients.Estimate);
%     coefVals = glm_rwdNoRwd.Coefficients.Estimate(relevInds);
%     CIbands = coefCI(glm_rwdNoRwd);
%     errorL = abs(coefVals - CIbands(relevInds,1));
%     errorU = abs(coefVals - CIbands(relevInds,2));
%     errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'b','linewidth',2)

%     xlabel('Reward n Trials Back')
%     ylabel('\beta Coefficient')
%     xlim([0.5 tMax+0.5])
%     legend('rwd', 'no rwd')
%     title([animal ' ' category]
%     errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)
% end
