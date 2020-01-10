%%functions from paper robinsons et al human study: 1-timeline of rewards and punishments : see if there is correlation : SHOULD be random
%%2- fit the 7 models they fit using hBayesDM models : this is sutaible
%%between pre and post sessions 3-same parameters have been calculaed in
%%behrens paper: do those too

%%also look at The influence of emotions on cognitive control : feelings and beliefs-where do they meet?
 %analysis

 %% separate data into safe and unsafe states and do reglog analysis indiivdualy for each. maybe comparing betas. 
 
 
function combineStates_opMAP(xlFile, animal, category, revForFlag, plotFlag)

if nargin < 3
    saveFigFlag = 1;
end

if nargin < 2
    coupledFlag = 0;
end

[root, sep] = currComputer();

rwdRateMatx = [];
rwdRateMatx_safe = [];
rwdRateMatx_threat = [];
combinedChoicesMatx = []; 
combinedChoicesMatx_safe = [];
combinedChoicesMatx_threat = []; 
combinedRewardsMatx = [];
combinedRewardsMatx_safe = [];
combinedRewardsMatx_threat = [];
combinedNoRewardsMatx = [];
combinedNoRewardsMatx_safe = [];
combinedNoRewardsMatx_threat = [];
combinedTimesMatx = [];
combinedTimesMatx_safe = [];
combinedTimesMatx_threat = [];
combinedAllChoice_R_safe = [];
combinedAllChoice_R_threat = [];
responseInds_threat = [];
responseInds_safe = [];

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
    m = 1;
    w = 1;
    for k= 1:length(responseInds)
        if behSessionData(responseInds(k)).stateType == 0
            responseInds_safe(m) = responseInds(k);
            m = m +1;
        else
            responseInds_threat(w) = responseInds(i);
            w = w +1;
        end
    end
    allReward_R_safe = [behSessionData(responseInds_safe).rewardR];
    allReward_L_safe= [behSessionData(responseInds_safe).rewardL]; 
    allChoices_safe = NaN(1,length(behSessionData(responseInds_safe)));
    allChoices_safe(~isnan(allReward_R_safe)) = 1;
    allChoices_safe(~isnan(allReward_L_safe)) = -1;
    allReward_R_safe(isnan(allReward_R_safe)) = 0;
    allReward_L_safe(isnan(allReward_L_safe)) = 0;
            
    allChoice_R_safe = double(allChoices_safe == 1);
    allChoice_L_safe = double(allChoices_safe == -1);
            
    allRewards_safe = zeros(1,length(allChoices_safe));
    allRewards_safe(logical(allReward_R_safe)) = 1;
    allRewards_safe(logical(allReward_L_safe)) = -1;

    allNoRewards_safe = allChoices_safe;
    allNoRewards_safe(logical(allReward_R_safe)) = 0;
    allNoRewards_safe(logical(allReward_L_safe)) = 0;

    outcomeTimes_safe = [behSessionData(responseInds_safe).rewardTime] - behSessionData(responseInds(1)).rewardTime;
    outcomeTimes_safe = [diff(outcomeTimes_safe) NaN];

    rwdMatxTmp_safe = [];
    choiceMatxTmp_safe = [];
    noRwdMatxTmp_safe = [];
        
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
        rwdMatxTmp_safe(j,:) = [NaN(1,j) allRewards_safe(1:end-j)];
        choiceMatxTmp_safe(j,:) = [NaN(1,j) allChoices_safe(1:end-j)];
        noRwdMatxTmp_safe(j,:) = [NaN(1,j) allNoRewards_safe(1:end-j)];
        rwdMatxTmp_threat(j,:) = [NaN(1,j) allRewards_threat(1:end-j)];
        choiceMatxTmp_threat(j,:) = [NaN(1,j) allChoices_threat(1:end-j)];
        noRwdMatxTmp_threat(j,:) = [NaN(1,j) allNoRewards_threat(1:end-j)];
    end

    timeTmp_safe = NaN(tMax,length(allRewards_safe)); 
    timeTmp_threat = NaN(tMax,length(allRewards_threat)); 
    for j = 1:tMax
        for k = 1:length(outcomeTimes_safe)-j
            timeTmp_safe(j,k+j) = sum(outcomeTimes_safe(k:k+j-1));
        end
        for k = 1:length(outcomeTimes_threat)-j
            timeTmp_threat(j,k+j) = sum(outcomeTimes_threat(k:k+j-1));
        end
            
    end
    
%    allRewards(allRewards == -1) = 1;

    rwdsTmp_safe = NaN(tMax,length(allRewards_safe)); 
    rwdsTmp_threat = NaN(tMax,length(allRewards_threat)); 
    for j = 1:tMax
        for k = 1:length(outcomeTimes_safe)-j
            rwdsTmp_safe(j,k+j) = sum(allRewards_safe(k:k+j-1));
        end
        for k = 1:length(outcomeTimes_threat)-j
             rwdsTmp_threat(j,k+j) = sum(allRewards_threat(k:k+j-1));
        end
    end
    
    rwdRateMatx_safe = [rwdRateMatx_safe NaN(tMax, 100) (rwdsTmp_safe ./ timeTmp_safe)];
    combinedRewardsMatx_safe = [combinedRewardsMatx_safe NaN(tMax,100) rwdMatxTmp_safe];
    combinedNoRewardsMatx_safe = [combinedNoRewardsMatx_safe NaN(tMax,100) noRwdMatxTmp_safe];
    combinedChoicesMatx_safe = [combinedChoicesMatx_safe NaN(tMax,100) choiceMatxTmp_safe];
    combinedTimesMatx_safe = [combinedTimesMatx_safe NaN(tMax, 100) timeTmp_safe];
    combinedAllChoice_R_safe = [combinedAllChoice_R_safe NaN(1,100) allChoice_R_safe];
    
    
    rwdRateMatx_threat = [rwdRateMatx_threat NaN(tMax, 100) (rwdsTmp_threat ./ timeTmp_threat)];
    combinedRewardsMatx_threat = [combinedRewardsMatx_threat NaN(tMax,100) rwdMatxTmp_threat];
    combinedNoRewardsMatx_threat = [combinedNoRewardsMatx_threat NaN(tMax,100) noRwdMatxTmp_threat];
    combinedChoicesMatx_threat = [combinedChoicesMatx_threat NaN(tMax,100) choiceMatxTmp_threat];
    combinedTimesMatx_threat = [combinedTimesMatx_threat NaN(tMax, 100) timeTmp_threat];
    combinedAllChoice_R_threat = [combinedAllChoice_R_threat NaN(1,100) allChoice_R_threat];
end


%logistic regression models
glm_rwd_safe = fitglm([combinedRewardsMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{1} = num2str(round(glm_rwd_safe.Rsquared.Adjusted*100)/100);
glm_choice_safe = fitglm([combinedChoicesMatx_safe]', combinedAllChoice_R_safe, 'distribution','binomial','link','logit'); rsq{3} = num2str(round(glm_choice_safe.Rsquared.Adjusted*100)/100);
glm_rwdANDchoice_safe = fitglm([combinedRewardsMatx_safe' combinedChoicesMatx_safe'], combinedAllChoice_R_safe, 'distribution','binomial','link','logit'); rsq{2} = num2str(round(glm_rwdANDchoice_safe.Rsquared.Adjusted*100)/100);
glm_time_safe = fitglm([combinedTimesMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{4} = num2str(round(glm_time_safe.Rsquared.Adjusted*100)/100);
glm_rwdANDtime_safe = fitglm([combinedRewardsMatx_safe' combinedTimesMatx_safe'], combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{5} = num2str(round(glm_rwdANDtime_safe.Rsquared.Adjusted*100)/100);
glm_rwdRate_safe = fitglm([rwdRateMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{6} = num2str(round(glm_rwd_safe.Rsquared.Adjusted*100)/100);
glm_rwdNoRwd_safe = fitglm([combinedRewardsMatx_safe' combinedNoRewardsMatx_safe'], combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_rwdNoRwd_safe.Rsquared.Adjusted*100)/100);
glm_all_safe = fitglm([combinedRewardsMatx_safe' combinedNoRewardsMatx_safe' combinedChoicesMatx_safe'], combinedAllChoice_R_safe, 'distribution','binomial','link','logit');

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
coefVals_safe = glm_rwdNoRwd_safe.Coefficients.Estimate(relevInds);
CIbands_safe = coefCI(glm_rwdNoRwd_safe);
errorL_safe = abs(coefVals_safe - CIbands_safe(relevInds,1));
errorU_safe = abs(coefVals_safe - CIbands_safe(relevInds,2));

if plotFlag
    errorbar((1:tMax)+0.2,coefVals_safe,errorL_safe,errorU_safe,'Color', [0.7 0 1],'linewidth',2)
end

coefVals_threat = glm_rwdNoRwd_threat.Coefficients.Estimate(relevInds);
CIbands_threat = coefCI(glm_rwdNoRwd_threat);
errorL_threat = abs(coefVals_threat - CIbands_threat(relevInds,1));
errorU_threat = abs(coefVals_threat - CIbands_threat(relevInds,2));

if plotFlag
    errorbar((1:tMax)+0.2,coefVals_threat,errorL_threat,errorU_threat,'b','linewidth',2)
end

xlabel('Reward n Trials Back')
ylabel('\beta Coefficient')
xlim([0.5 tMax+0.5])
legend('rwd', 'no rwd')
title([animal ' ' category 'safe'])
