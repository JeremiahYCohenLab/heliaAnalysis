function [glm_AirpuffANDallChoices, t] = combineStatesLogRegTimeAirpuff_opMAP(xlFile, animal, category, revForFlag)

% if nargin < 4
%     plotFlag = 0;
% end
if nargin <4
    revForFlag = 0;
end

%determine root for file location
[root, sep] = currComputer();

%import behavior session titles for desired category
[weights, dayList, ~] = xlsread(xlFile, animal);
[~,col] = find(~cellfun(@isempty,strfind(dayList, category)) == 1);
dayList = dayList(2:end,col);
endInd = find(cellfun(@isempty,dayList),1);
if ~isempty(endInd)
    dayList = dayList(1:endInd-1,:);
end

timeMax = 151000;
binSize = 15000;  %6300 for trial length
timeBinEdges = [1000:binSize:timeMax];  %no trials shorter than 1s between outcome and CS on
tMax = length(timeBinEdges) - 1;
rwdMatx =[];                            %initialize matrices for combining session data
noRwdMatx = [];
combinedAllChoice_R = []; 
combinedAirpuffMatxTmp = [];
combinedAllRewrd = [];
combinedAllChoice = [];

%loop for each session in the list
for i = 1: length(dayList)              
    sessionName = dayList{i};                       %extract relevant info from session title
    [animalName, date] = strtok(sessionName, 'd'); 
    animalName = animalName(2:end);
    date = date(1:9);
    sessionFolder = ['m' animalName date];

    if isstrprop(sessionName(end), 'alpha')         %define appropriate data path
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sessionName(end) sep sessionName '_sessionData_behav.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sep sessionName '_sessionData_behav.mat'];
    end

%     if exist(sessionDataPath,'file')        %load preprocessed struct if there is one
%         load(sessionDataPath)
%          behSessionData = sessionData;
%         if revForFlag
%            behSessionData = sessionData;
%         end
%     elseif revForFlag                                    %otherwise generate the struct
        [behSessionData, blockSwitch, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
   

            %[behSessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
%     end
%     if revForFlag                                    %otherwise generate the struct
%         [behsessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
% 
%     else
%         [behSessionData, ~, ~, ~] = generateSessionData_operantMatchingDecoupled(sessionName);
%     end
    
    %create arrays for choices and rewards
    responseInds = find(~isnan([behSessionData.rewardTime])); % find CS+ trials with a response in the lick window
    responseInds_threat = find([behSessionData.stateType]== 1); 
    allReward_R = [behSessionData(responseInds_threat).rewardR]; 
    allReward_L = [behSessionData(responseInds_threat).rewardL]; 
    allChoices = NaN(1,length(behSessionData(responseInds_threat)));
    allChoices(~isnan(allReward_R)) = 1;
    allChoices(~isnan(allReward_L)) = -1;
    allChoice_R = double(allChoices == 1);
    allChoice_L = double(allChoices == -1);
    allChoice = NaN(1,length(behSessionData(responseInds_threat)));
    allChoice(~isnan(allReward_R)) = 1;
    allChoice(~isnan(allReward_L)) = 1;
    
    
    allAirpuff = NaN(1,length(behSessionData(responseInds_threat)));
    allAirpuffInd = [behSessionData(responseInds_threat).AirpuffTimeOn];
    allAirpuff(~allAirpuffInd == 0) = 1;
    allAirpuff(isnan(allAirpuff)) = 0;
    
    allReward_R(isnan(allReward_R)) = 0;
    allReward_L(isnan(allReward_L)) = 0;
    allRewards = zeros(1,length(allChoices));
    allRewards(logical(allReward_R)) = 1;
    allRewards(logical(allReward_L)) = 1;

    %create binned outcome matrices
    rwdTmpMatx = NaN(tMax, length(responseInds_threat));     %initialize matrices for number of response trials x number of time bins
    noRwdTmpMatx = NaN(tMax, length(responseInds_threat));
    airpuffMatxTmp = NaN(tMax, length(responseInds_threat));
    for j = 2:length(responseInds_threat)          
        k = 1;
        %find time between "current" choice and previous rewards, up to timeMax in the past 
        timeTmpL = []; timeTmpR = []; nTimeTmpL = []; nTimeTmpR = []; timeTmpAirpuff= [];
        while j-k > 0 & behSessionData(responseInds_threat(j)).rewardTime - behSessionData(responseInds_threat(j-k)).rewardTime < timeMax
            if behSessionData(responseInds_threat(j-k)).rewardL == 1
                timeTmpL = [timeTmpL (behSessionData(responseInds_threat(j)).rewardTime - behSessionData(responseInds_threat(j-k)).rewardTime)];
            end
            if behSessionData(responseInds_threat(j-k)).rewardR == 1
                timeTmpR = [timeTmpR (behSessionData(responseInds_threat(j)).rewardTime - behSessionData(responseInds_threat(j-k)).rewardTime)];
            end
            if behSessionData(responseInds_threat(j-k)).rewardL == 0
                nTimeTmpL = [nTimeTmpL (behSessionData(responseInds_threat(j)).rewardTime - behSessionData(responseInds_threat(j-k)).rewardTime)];
            end
            if behSessionData(responseInds_threat(j-k)).rewardR == 0
                nTtimeTmpR = [nTimeTmpR (behSessionData(responseInds_threat(j)).rewardTime - behSessionData(responseInds_threat(j-k)).rewardTime)];
            end
            if allAirpuff(j) == 1
                timeTmpAirpuff =  [timeTmpAirpuff (behSessionData(responseInds_threat(j)).rewardTime - behSessionData(responseInds_threat(j-k)).rewardTime)];
            end
            k = k + 1;
        end
        %bin outcome times and use to fill matrices
        if ~isempty(timeTmpL)
            binnedRwds = discretize(timeTmpL,timeBinEdges); %has a value of 1-length of bined edges: depending on what entry the time of reward l falles into 
            for k = 1:tMax
                if ~isempty(binnedRwds == k)
                    rwdTmpMatx(k,j) = -1*sum(binnedRwds == k);
                else
                    rwdTmpMatx(k,j) = 0;
                end
            end
        end
        if ~isempty(timeTmpR)
            binnedRwds = discretize(timeTmpR,timeBinEdges);
            for k = 1:tMax
                if ~isempty(binnedRwds == k) & isnan(rwdTmpMatx(k,j))
                    rwdTmpMatx(k,j) = sum(binnedRwds == k);
                elseif ~isempty(binnedRwds == k) & ~isnan(rwdTmpMatx(k,j))
                    rwdTmpMatx(k,j) = rwdTmpMatx(k,j) + sum(binnedRwds == k);
                else
                    rwdTmpMatx(k,j) = 0;
                end
            end
        end
        if isempty(timeTmpL) & isempty(timeTmpR)
            rwdTmpMatx(:,j) = 0;
        end
        if ~isempty(timeTmpAirpuff)
            binnedAir = discretize(timeTmpAirpuff,timeBinEdges);
            for k = 1:tMax
                if ~isempty(binnedAir == k)
                    airpuffMatxTmp(k,j) = sum(binnedAir == k);
                end
            end
        else
            airpuffMatxTmp(:,j) = 0;
        end
        if ~isempty(nTimeTmpL)
            binnedNoRwds = discretize(nTimeTmpL,timeBinEdges);
            for k = 1:tMax
                if ~isempty(binnedNoRwds == k)
                    noRwdTmpMatx(k,j) = -1*sum(binnedNoRwds == k);
                else
                    noRwdTmpMatx(k,j) = 0;
                end
            end
        end
        if ~isempty(nTimeTmpR)
            binnedNoRwds = discretize(nTimeTmpR,timeBinEdges);
            for k = 1:tMax
                if ~isempty(binnedNoRwds == k) & isnan(noRwdTmpMatx(k,j))
                    noRwdTmpMatx(k,j) = sum(binnedNoRwds == k);
                elseif ~isempty(binnedNoRwds == k) & ~isnan(noRwdTmpMatx(k,j))
                    noRwdTmpMatx(k,j) = noRwdTmpMatx(k,j) + sum(binnedNoRwds == k);
                else
                    noRwdTmpMatx(k,j) = 0;
                end
            end
        end
        if isempty(nTimeTmpL) & isempty(nTimeTmpR)
            noRwdTmpMatx(:,j) = 0;
        end
    end
    
    %concatenate temp matrix with combined matrix
    rwdTmpMatx(:,1) = NaN;
    airpuffMatxTmp(:,1) = NaN;
    rwdMatx = [rwdMatx NaN(length(timeBinEdges)-1, 100) rwdTmpMatx];
    noRwdMatx = [noRwdMatx NaN(length(timeBinEdges)-1, 100) noRwdTmpMatx];
    combinedAllChoice_R = [combinedAllChoice_R NaN(1,100) allChoice_R];
    combinedAllRewrd = [combinedAllRewrd NaN(1,100) allRewards];
    combinedAirpuffMatxTmp = [combinedAirpuffMatxTmp NaN(length(timeBinEdges)-1, 100) airpuffMatxTmp];
    combinedAllChoice = [combinedAllChoice NaN(1,100) allChoice];
end

%logistic regression models
glm_rwd_threat = fitglm([rwdMatx]', combinedAllChoice_R,'distribution','binomial','link','logit');
glm_noRwd_threat = fitglm([noRwdMatx]', combinedAllChoice_R,'distribution','binomial','link','logit');
glm_all_threat = fitglm([rwdMatx' noRwdMatx'], combinedAllChoice_R,'distribution','binomial','link','logit');
glm_AirpuffANDchoice =  fitglm([combinedAirpuffMatxTmp'], combinedAllChoice_R,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_AirpuffANDchoice.Rsquared.Adjusted*100)/100);
glm_AirpuffANDrwrd =  fitglm([combinedAirpuffMatxTmp'], combinedAllRewrd,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_AirpuffANDrwrd.Rsquared.Adjusted*100)/100);
glm_AirpuffANDallChoices =  fitglm([combinedAirpuffMatxTmp'], combinedAllChoice,'distribution','binomial','link','logit'); rsq{7} = num2str(round(glm_AirpuffANDallChoices.Rsquared.Adjusted*100)/100);



t = struct;
t.binSize = binSize;
t.timeMax = timeMax;
t.tMax = tMax;
t.timeBinEdges = timeBinEdges;

% % if plotFlag
%     figure; hold on;
%     relevInds = 2:tMax+1;
%     coefVals = glm_AirpuffANDchoice.Coefficients.Estimate(relevInds);
%     CIbands = coefCI(glm_AirpuffANDchoice);
%     errorL = abs(coefVals - CIbands(relevInds,1));
%     errorU = abs(coefVals - CIbands(relevInds,2));
%     errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)
% 
% %     relevInds = tMax+2:2*tMax+1;
% %     coefVals = glm_all_threat.Coefficients.Estimate(relevInds);
% %     CIbands = coefCI(glm_all_threat);
% %     errorL = abs(coefVals - CIbands(relevInds,1));
% %     errorU = abs(coefVals - CIbands(relevInds,2));
% %     errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'b','linewidth',2)
% 
%     legend('airpuff')
%     xlabel('choice')
%     ylabel('\beta Coefficient')
%     xlim([0 tMax*binSize/1000 + binSize/1000])
%     title([animal ' ' category])
% % end
% figure; hold on;
% relevInds = 2:tMax+1;
% coefVals = glm_AirpuffANDrwrd.Coefficients.Estimate(relevInds);
% CIbands = coefCI(glm_AirpuffANDrwrd);
% errorL = abs(coefVals - CIbands(relevInds,1));
% errorU = abs(coefVals - CIbands(relevInds,2));
% errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)
% legend('airpuff')
% xlabel('reward')
% ylabel('\beta Coefficient')
% xlim([0 tMax*binSize/1000 + binSize/1000])
% title([animal ' ' category])

figure; hold on;
relevInds = 2:tMax+1;
coefVals = glm_AirpuffANDallChoices.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_AirpuffANDallChoices);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)
legend('airpuff')
xlabel('all choice')
ylabel('\beta Coefficient')
xlim([0 tMax*binSize/1000 + binSize/1000])
title([animal ' ' category])


