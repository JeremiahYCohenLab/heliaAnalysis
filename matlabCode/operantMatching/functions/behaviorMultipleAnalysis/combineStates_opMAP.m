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
stateSwitch = true;

tMax = 12;
d = 1;

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
    responseInds_threat = find([behSessionData(responseInds).stateType] == 1);
    
    stateInds = [behSessionData(responseInds).statetype];

    for h = 1: length(stateInds)
        stateSwitchInd_safe = find(stateInds(h)- statend(h +1) <= -1) ;
        stateSwitchInd_threat = find(stateInds(h)- statend(h +1) >= 1) ;
    end
    
    
%     stateSwitch = true;
%     h = 0;
%     while (stateSwitch == true)
%         h = h +1;
%         while ((h ~= length(responseInds_safe) && (responseInds_safe(h)+1) == responseInds_safe(h+1)))
%             h = h +1;
%         end
% %         h
% %         d
%         if( h -d >=13)
        
            allReward_R_safe = [behSessionData(safeStatesInds).rewardR];
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

%     outcomeTimes_safe = [behSessionData(responseInds_safe(d:h))).rewardTime] - behSessionData(responseInds(1)).rewardTime;
%     outcomeTimes_safe = [diff(outcomeTimes_safe) NaN];

            rwdMatxTmp_safe = [];
            choiceMatxTmp_safe = [];
            noRwdMatxTmp_safe = [];
            airpuffMatxTmp = [];
            
            for j = 1:tMax
                rwdMatxTmp_safe(j,:) = [NaN(1,j) allRewards_safe(1:end-j)];
                choiceMatxTmp_safe(j,:) = [NaN(1,j) allChoices_safe(1:end-j)];
                noRwdMatxTmp_safe(j,:) = [NaN(1,j) allNoRewards_safe(1:end-j)];
            end

%     timeTmp_safe = NaN(tMax,length(allRewards_safe)); 
% 
%     for j = 1:tMax
%         for k = 1:length(outcomeTimes_safe)-j
%             timeTmp_safe(j,k+j) = sum(outcomeTimes_safe(k:k+j-1));
%         end
%     end
%     
% %    allRewards(allRewards == -1) = 1;
% 
%     rwdsTmp_safe = NaN(tMax,length(allRewards_safe)); 
% 
%     for j = 1:tMax
%         for k = 1:length(outcomeTimes_safe)-j
%             rwdsTmp_safe(j,k+j) = sum(allRewards_safe(k:k+j-1));
%         end
% %         for k = 1:length(outcomeTimes_threat)-j
% %              rwdsTmp_threat(j,k+j) = sum(allRewards_threat(k:k+j-1));
% %         end
%     end
             combinedRewardsMatx_safe_state = [combinedRewardsMatx_safe_state NaN(tMax, 13) rwdMatxTmp_safe];
             combinedNoRewardsMatx_safe_state = [combinedNoRewardsMatx_safe_state NaN(tMax,13) noRwdMatxTmp_safe];
    %        combinedChoicesMatx_threat_state = [combinedChoicesMatx_threat_state NaN(tMax,13) choiceMatxTmp_threat];
        %    combinedTimesMatx_threat_state = [combinedTimesMatx_threat_state NaN(tMax, 100) timeTmp_threat];
             combinedAllChoice_R_safe_state = [combinedAllChoice_R_safe_state NaN(1,13) allChoice_R_safe];
             combinedAirpuff_state= [combinedAirpuff_state NaN(tMax,13) airpuffMatxTmp]; 
        end
        if ((h) == length(responseInds_safe))
            stateSwitch = false;
%             disp('FALSE')
            d = 1;
            combinedRewardsMatx_safe = [combinedRewardsMatx_safe NaN(tMax,100) combinedRewardsMatx_safe_state];
            combinedNoRewardsMatx_safe = [combinedNoRewardsMatx_safe NaN(tMax,100) combinedNoRewardsMatx_safe_state];
            combinedAllChoice_R_safe = [combinedAllChoice_R_safe NaN(1,100) combinedAllChoice_R_safe_state];
            combinedRewardsMatx_safe_state = [];
            combinedNoRewardsMatx_safe_state = [];
            combinedAllChoice_R_safe_state; [];
        else
            stateSwitch = true;
                        d = h+1;
%                         disp('RUE')
        end
    end
%     rwdRateMatx_safe = [rwdRateMatx_safe NaN(tMax, 100) (rwdsTmp_safe ./ timeTmp_safe)];
%     combinedRewardsMatx_safe = [combinedRewardsMatx_safe NaN(tMax,100) rwdMatxTmp_safe];
%     combinedNoRewardsMatx_safe = [combinedNoRewardsMatx_safe NaN(tMax,100) noRwdMatxTmp_safe];
%     combinedChoicesMatx_safe = [combinedChoicesMatx_safe NaN(tMax,100) choiceMatxTmp_safe];
%     combinedTimesMatx_safe = [combinedTimesMatx_safe NaN(tMax, 100) timeTmp_safe];
%     combinedAllChoice_R_safe = [combinedAllChoice_R_safe NaN(1,100) allChoice_R_safe];
    
end


%logistic regression models
%glam_rwd_safe =  firglm([combinedAirpuff_safe]', combinedAllChoice_R_safe,
glm_rwd_safe = fitglm([combinedRewardsMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{1} = num2str(round(glm_rwd_safe.Rsquared.Adjusted*100)/100);
% glm_choice_safe = fitglm([combinedChoicesMatx_safe]', combinedAllChoice_R_safe, 'distribution','binomial','link','logit'); rsq{3} = num2str(round(glm_choice_safe.Rsquared.Adjusted*100)/100);
% glm_rwdANDchoice_safe = fitglm([combinedRewardsMatx_safe' combinedChoicesMatx_safe'], combinedAllChoice_R_safe, 'distribution','binomial','link','logit'); rsq{2} = num2str(round(glm_rwdANDchoice_safe.Rsquared.Adjusted*100)/100);
% glm_time_safe = fitglm([combinedTimesMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{4} = num2str(round(glm_time_safe.Rsquared.Adjusted*100)/100);
glm_rwdANDtime_safe = fitglm([combinedRewardsMatx_safe' combinedTimesMatx_safe'], combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{5} = num2str(round(glm_rwdANDtime_safe.Rsquared.Adjusted*100)/100);
% glm_rwdRate_safe = fitglm([rwdRateMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{6} = num2str(round(glm_rwd_safe.Rsquared.Adjusted*100)/100);
glm_rwdNoRwd_safe = fitglm([combinedRewardsMatx_safe' combinedNoRewardsMatx_safe'], combinedAllChoice_R_safe,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_rwdNoRwd_safe.Rsquared.Adjusted*100)/100);
% glm_all_safe = fitglm([combinedRewardsMatx_safe' combinedNoRewardsMatx_safe' combinedChoicesMatx_safe'], combinedAllChoice_R_safe, 'distribution','binomial','link','logit');
% hold on;
% glm_rwd_threat = fitglm([combinedRewardsMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{1} = num2str(round(glm_rwd_threat.Rsquared.Adjusted*100)/100);
% glm_choice_threat = fitglm([combinedChoicesMatx_threat]', combinedAllChoice_R_threat, 'distribution','binomial','link','logit'); rsq{3} = num2str(round(glm_choice_threat.Rsquared.Adjusted*100)/100);
% glm_rwdANDchoice_threat = fitglm([combinedRewardsMatx_threat' combinedChoicesMatx_threat'], combinedAllChoice_R_threat, 'distribution','binomial','link','logit'); rsq{2} = num2str(round(glm_rwdANDchoice_threat.Rsquared.Adjusted*100)/100);
% glm_time_threat = fitglm([combinedTimesMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{4} = num2str(round(glm_time_threat.Rsquared.Adjusted*100)/100);
% glm_rwdANDtime_threat = fitglm([combinedRewardsMatx_threat' combinedTimesMatx_threat'], combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{5} = num2str(round(glm_rwdANDtime_threat.Rsquared.Adjusted*100)/100);
% glm_rwdRate_threat = fitglm([rwdRateMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{6} = num2str(round(glm_rwd_threat.Rsquared.Adjusted*100)/100);
% glm_rwdNoRwd_threat = fitglm([combinedRewardsMatx_threat' combinedNoRewardsMatx_threat'], combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_rwdNoRwd_threat.Rsquared.Adjusted*100)/100);
% glm_all_threat = fitglm([combinedRewardsMatx_threat' combinedNoRewardsMatx_threat' combinedChoicesMatx_threat'], combinedAllChoice_R_threat, 'distribution','binomial','link','logit');
% figure; hold on;
% relevInds = 2:tMax+1;
% coefVals = glm_rwdNoRwd_safe.Coefficients.Estimate(relevInds);
% CIbands = coefCI(glm_rwdNoRwd_safe);
% errorL = abs(coefVals - CIbands(relevInds,1));
% errorU = abs(coefVals - CIbands(relevInds,2));
% errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)
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
% xlabel('Reward n Trials Back')
% ylabel('\beta Coefficient')
% xlim([0.5 tMax+0.5])
% legend('rwd', 'no rwd')
% title([animal ' ' category])
% % end

