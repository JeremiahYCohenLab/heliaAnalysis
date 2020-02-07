 
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
    rwdRateMatx_threat_state = [];
    combinedRewardsMatx_threat_state = [];
    combinedNoRewardsMatx_threat_state = [];
    combinedChoicesMatx_threat_state = [];
    combinedAllChoice_R_threat_state = [ ];
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
    responseInds_threat = find([behSessionData.stateType] == 1);
    responseInds_threatTmp = find([behSessionData(responseInds).stateType] == 1);
    stateSwitchInd_threatTmp = NaN(1,length(responseInds)); 
    for h = 1: length(responseInds)-1
        if(isnan(stateSwitchInd_threatTmp(h)))
            if(behSessionData(responseInds(h)).stateType- behSessionData(responseInds(h+1)).stateType <= -1 )
                stateSwitchInd_threatTmp(1,h+1) = h+1;
            elseif(behSessionData(responseInds(h)).stateType- behSessionData(responseInds(h+1)).stateType >= 1 )
                 stateSwitchInd_threatTmp(1,h) = h;
                 stateSwitchInd_threatTmp(1,h+1)=0;
              
            end
        end
    end

    stateSwitchInd_threat = [];
    stateSwitchInd_threat = [stateSwitchInd_threat find(~isnan(stateSwitchInd_threatTmp))]; 
    
    if(behSessionData(length(responseInds)).stateType == 1)
        stateSwitchInd_threat = [stateSwitchInd_threat length(responseInds)];
    end

            allAirpuff = NaN(d,length(behSessionData(responseInds)));
    %         behSessionData((h-count):h)
            allAirpuffInd = [behSessionData(responseInds).AirpuffTimeOn];
            allAirpuff(~allAirpuffInd == 0) = 1;
            allAirpuff(isnan(allAirpuff)) = 0;
        %     allAirpuff(~isnan(allAirpuff)) = 1;
        %     allAirpuff(isnan(allAirpuff)) = 0;
            allReward_R_threat = [behSessionData(responseInds).rewardR];
            allReward_L_threat = [behSessionData(responseInds).rewardL]; 
            allChoices_threat = NaN(1,length(behSessionData(responseInds)));
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

%         outcomeTimes_threat = [behSessionData(h).rewardTime] - behSessionData(responseInds(1)).rewardTime;
%         outcomeTimes_threat = [diff(ht) NaN];
%         dayList(i)
%         length(allRewards_threat)
%         d
            rwdMatxTmp_threat = [];
            choiceMatxTmp_threat = [];
            noRwdMatxTmp_threat = [];
            airpuffMatxTmp = [];
    %         allRewards_threat
             for l = 1: length(stateSwitchInd_threat)-1
                rwdMatxTmp_threat = [];
                choiceMatxTmp_threat = [];
                noRwdMatxTmp_threat = [];
                airpuffMatxTmp = [];
                if(stateSwitchInd_threatTmp(stateSwitchInd_threat(l+1)) ~=0 && stateSwitchInd_threatTmp(stateSwitchInd_threat(l)) ~= 0)
                    if (length(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1))> tMax)
                        for j = 1:tMax
                            rwdMatxTmp_threat(j,:) = [NaN(1,j) allRewards_threat(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j)];
                            choiceMatxTmp_threat(j,:) = [NaN(1,j) allChoices_threat(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j)];
                            noRwdMatxTmp_threat(j,:) = [NaN(1,j) allNoRewards_threat(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j)];
                        end
                    end
                   combinedRewardsMatx_threat_state = [combinedRewardsMatx_threat_state NaN(tMax, 15) rwdMatxTmp_threat];
                   combinedNoRewardsMatx_threat_state = [combinedNoRewardsMatx_threat_state NaN(tMax,15) noRwdMatxTmp_threat];       
                   combinedChoicesMatx_threat_state = [combinedChoicesMatx_threat_state NaN(tMax,15) choiceMatxTmp_threat];
%                    combinedTimesMatx_threat_state = [combinedTimesMatx_threat_state NaN(tMax, 100) timeTmp_threat];
                   combinedAllChoice_R_threat_state = [combinedAllChoice_R_threat_state NaN(1,15) allChoice_R_threat(:,stateSwitchInd_threat(l):stateSwitchInd_threat(l+1))];
                end
             end
    combinedRewardsMatx_threat = [combinedRewardsMatx_threat NaN(tMax,100) combinedRewardsMatx_threat_state];
    combinedNoRewardsMatx_threat = [combinedNoRewardsMatx_threat NaN(tMax,100) combinedNoRewardsMatx_threat_state];
    combinedAllChoice_R_threat = [combinedAllChoice_R_threat NaN(1,100) combinedAllChoice_R_threat_state];
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
% glm_choice_threat = fitglm([combinedChoicesMatx_threat]', combinedAllChoice_R_threat, 'distribution','binomial','link','logit'); rsq{3} = num2str(round(glm_choice_threat.Rsquared.Adjusted*100)/100);
% glm_rwdANDchoice_threat = fitglm([combinedRewardsMatx_threat' combinedChoicesMatx_threat'], combinedAllChoice_R_threat, 'distribution','binomial','link','logit'); rsq{2} = num2str(round(glm_rwdANDchoice_threat.Rsquared.Adjusted*100)/100);
% glm_time_threat = fitglm([combinedTimesMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{4} = num2str(round(glm_time_threat.Rsquared.Adjusted*100)/100);
% glm_rwdANDtime_threat = fitglm([combinedRewardsMatx_threat' combinedTimesMatx_threat'], combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{5} = num2str(round(glm_rwdANDtime_threat.Rsquared.Adjusted*100)/100);
% glm_rwdRate_threat = fitglm([rwdRateMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{6} = num2str(round(glm_rwd_threat.Rsquared.Adjusted*100)/100);
glm_rwdNoRwd_threat = fitglm([combinedRewardsMatx_threat' combinedNoRewardsMatx_threat'], combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_rwdNoRwd_threat.Rsquared.Adjusted*100)/100);
% glm_all_threat = fitglm([combinedRewardsMatx_threat' combinedNoRewardsMatx_threat' combinedChoicesMatx_threat'], combinedAllChoice_R_threat, 'distribution','binomial','link','logit');
% glm_AirpuffANDchoice =  fitglm([combinedAirpuff'], combinedAllChoice_R_threat,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_AirpuffANDchoice.Rsquared.Adjusted*100)/100);

% figure; hold on;
% relevInds = 2:tMax+1;
% coefVals = glm_rwdNoRwd_threat.Coefficients.Estimate(relevInds);
% CIbands = coefCI(glm_rwdNoRwd_threat);
% errorL = abs(coefVals - CIbands(relevInds,1));
% errorU = abs(coefVals - CIbands(relevInds,2));
% errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2);
% 
% relevInds = tMax+2:length(glm_rwdNoRwd_threat.Coefficients.Estimate);
% coefVals = glm_rwdNoRwd_threat.Coefficients.Estimate(relevInds);
% CIbands = coefCI(glm_rwdNoRwd_threat);
% errorL = abs(coefVals - CIbands(relevInds,1));
% errorU = abs(coefVals - CIbands(relevInds,2));
% errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', 'b' ,'linewidth',2)
% 
% xlabel('Reward n Trials Back')
% ylabel('\beta Coefficient')
% xlim([0.5 tMax+0.5])
% legend('rwd', 'no rwd')
% title([animal ' ' category])
% % end

