function [glm_all_safe,glm_all_threat, t] = combineLogRegStatesTime_opMAP(xlFile, animal, category, revForFlag)

% if nargin < 5
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
noRwdMatx= [];
rwdTempMatx = [];

rwdMatx_safe = [];
noRwdMatx_safe = [];
combinedAllChoice_R_safe = [];
rwdMatx_threat = [];
noRwdMatx_threat = [];
combinedAllChoice_R_threat = [];

%loop for each session in the list
for i = 1: length(dayList)
        sessionName = dayList{i};                       %extract relevant info from session title
        [animalName, date] = strtok(sessionName, 'd'); 
        animalName = animalName(2:end);
        date = date(1:9);
        sessionFolder = ['m' animalName date];

        if isstrprop(sessionName(end), 'alpha')         %define appropriate data path
            sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sessionFolder(end) sep sessionFolder '_sessionData_behav.mat'];
        else
            sessionDataPath = [root animalName sep sessionFolder sep 'sortedap' sep 'session' sep sessionName '_sessionData_behav.mat'];
        end

        if exist(sessionDataPath,'file')        %load preprocessed struct if there is one
            load(sessionDataPath)
             behSessionData = sessionData;
            if revForFlag
               behSessionData = sessionData;
            end
        elseif revForFlag                                    %otherwise generate the struct
            [behSessionData, blockSwitch, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);


        else
            [behSessionData, ~, ~, ~] = generateSessionData_operantMatchingDecoupled(sessionName);
        end

        %create arrays for choices and rewards
        responseInds = find(~isnan([behSessionData.rewardTime])); % find CS+ trials with a response in the lick window
        stateType = [behSessionData(responseInds).stateType];
        stateChangeInds = [1 (find(abs(diff([behSessionData(responseInds).stateType])) == 1) + 1)  length(responseInds)];

        allReward_R = [behSessionData(responseInds).rewardR]; 
        allReward_L = [behSessionData(responseInds).rewardL]; 
        allChoices = NaN(1,length(behSessionData(responseInds)));
        allChoices(~isnan(allReward_R)) = 1;
        allChoices(~isnan(allReward_L)) = -1;
        allChoice_R = double(allChoices == 1);
        allChoice_L = double(allChoices == -1);

        allReward_R(isnan(allReward_R)) = 0;
        allReward_L(isnan(allReward_L)) = 0;
        allRewards = zeros(1,length(allChoices));
        allRewards(logical(allReward_R)) = 1;
        allRewards(logical(allReward_L)) = 1;
            %create binned outcome matrices
        rwdTempMatx = NaN(tMax, length(responseInds));     %initialize matrices for number of response trials x number of time bins
        noRwdTempMatx = NaN(tMax, length(responseInds));
        for j = 2:length(responseInds)          
            k = 1;
            %find time between "current" choice and previous rewards, up to timeMax in the past 
            timeTmpL = []; timeTmpR = []; nTimeTmpL = []; nTimeTmpR = [];
            while j-k > 0 & behSessionData(responseInds(j)).rewardTime - behSessionData(responseInds(j-k)).rewardTime < timeMax
                if behSessionData(responseInds(j-k)).rewardL == 1
                    timeTmpL = [timeTmpL (behSessionData(responseInds(j)).rewardTime - behSessionData(responseInds(j-k)).rewardTime)];
                end
                if behSessionData(responseInds(j-k)).rewardR == 1
                    timeTmpR = [timeTmpR (behSessionData(responseInds(j)).rewardTime - behSessionData(responseInds(j-k)).rewardTime)];
                end
                if behSessionData(responseInds(j-k)).rewardL == 0
                    nTimeTmpL = [nTimeTmpL (behSessionData(responseInds(j)).rewardTime - behSessionData(responseInds(j-k)).rewardTime)];
                end
                if behSessionData(responseInds(j-k)).rewardR == 0
                    nTtimeTmpR = [nTimeTmpR (behSessionData(responseInds(j)).rewardTime - behSessionData(responseInds(j-k)).rewardTime)];
                end
                k = k + 1;
            end
            %bin outcome times and use to fill matrices
                if ~isempty(timeTmpL)
                    binnedRwds = discretize(timeTmpL,timeBinEdges);
                    for k = 1:tMax
                        if ~isempty(binnedRwds == k)
                            rwdTempMatx(k,j) = -1*sum(binnedRwds == k);
                        else
                            rwdTempMatx(k,j) = 0;
                        end
                    end
                end
            if ~isempty(timeTmpR)
                binnedRwds = discretize(timeTmpR,timeBinEdges);
                for k = 1:tMax
                    if ~isempty(binnedRwds == k) & isnan(rwdTempMatx(k,j))
                        rwdTempMatx(k,j) = sum(binnedRwds == k);
                    elseif ~isempty(binnedRwds == k) & ~isnan(rwdTempMatx(k,j))
                        rwdTempMatx(k,j) = rwdTempMatx(k,j) + sum(binnedRwds == k);
                    else
                        rwdTempMatx(k,j) = 0;
                    end
                end
            end
            if isempty(timeTmpL) & isempty(timeTmpR)
                rwdTempMatx(:,j) = 0;
            end
            if ~isempty(nTimeTmpL)
                binnedNoRwds = discretize(nTimeTmpL,timeBinEdges);
                for k = 1:tMax
                    if ~isempty(binnedNoRwds == k)
                        noRwdTempMatx(k,j) = -1*sum(binnedNoRwds == k);
                    else
                        noRwdTempMatx(k,j) = 0;
                    end
                end
            end
            if ~isempty(nTimeTmpR)
                binnedNoRwds = discretize(nTimeTmpR,timeBinEdges);
                for k = 1:tMax
                    if ~isempty(binnedNoRwds == k) & isnan(noRwdTempMatx(k,j))
                        noRwdTempMatx(k,j) = sum(binnedNoRwds == k);
                    elseif ~isempty(binnedNoRwds == k) & ~isnan(noRwdTempMatx(k,j))
                        noRwdTempMatx(k,j) = noRwdTempMatx(k,j) + sum(binnedNoRwds == k);
                    else
                        noRwdTempMatx(k,j) = 0;
                    end
                end
            end
            if isempty(nTimeTmpL) & isempty(nTimeTmpR)
                noRwdTempMatx(:,j) = 0;
            end
        end
        for currT = 1:length(stateChangeInds)-1
            rwdMatx_safe_states =[]; 
            noRwdMatx_safe_states = [];
            combinedAllChoice_R_safe_states = [];
            rwdMatx_threat_states =[]; %these go back to being empty for the next day
            noRwdMatx_threat_states = [];
            combinedAllChoice_R_threat_states = [];
             if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 10)
                if stateType(stateChangeInds(currT)) == 1
                    rwdTempMatx_threat(:,1) = NaN;
                    rwdMatx_threat_states = [rwdMatx_threat_states NaN(length(timeBinEdges)-1,15) rwdTempMatx(:,stateChangeInds(currT):stateChangeInds(currT+1)-1)]; %these are the matrices of each state
                    noRwdMatx_threat_states = [noRwdMatx_threat_states NaN(length(timeBinEdges)-1, 15) noRwdTempMatx(:,stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                    combinedAllChoice_R_threat_states = [combinedAllChoice_R_threat_states NaN(1,15) allChoice_R(:,stateChangeInds(currT):stateChangeInds(currT+1)-1)]; 
                else
                    rwdTempMatx(:,1) = NaN;
                    rwdMatx_safe_states = [rwdMatx_safe_states NaN(length(timeBinEdges)-1,15) rwdTempMatx(:,stateChangeInds(currT):stateChangeInds(currT+1)-1)]; %these are the matrices of each state
                    noRwdMatx_safe_states = [noRwdMatx_safe_states NaN(length(timeBinEdges)-1, 15) noRwdTempMatx(:,stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                    combinedAllChoice_R_safe_states = [combinedAllChoice_R_safe_states NaN(1,15) allChoice_R(:,stateChangeInds(currT):stateChangeInds(currT+1)-1)]; 
                end
        rwdMatx_safe = [rwdMatx_safe NaN(length(timeBinEdges)-1, 100) rwdMatx_safe_states];
        noRwdMatx_safe = [noRwdMatx_safe NaN(length(timeBinEdges)-1, 100) noRwdMatx_safe_states];
        combinedAllChoice_R_safe = [combinedAllChoice_R_safe NaN(1,100) combinedAllChoice_R_safe_states];
        rwdMatx_threat = [rwdMatx_threat NaN(length(timeBinEdges)-1, 100) rwdMatx_threat_states];
        noRwdMatx_threat = [noRwdMatx_threat NaN(length(timeBinEdges)-1, 100) noRwdMatx_threat_states];
        combinedAllChoice_R_threat = [combinedAllChoice_R_threat NaN(1,100) combinedAllChoice_R_threat_states];
            end
        end
 end
    %concatenate temp matrix with combined matrix

%logistic regression models
glm_rwd_safe = fitglm([rwdMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit');
glm_noRwd_safe = fitglm([noRwdMatx_safe]', combinedAllChoice_R_safe,'distribution','binomial','link','logit');
glm_all_safe = fitglm([rwdMatx_safe' noRwdMatx_safe'], combinedAllChoice_R_safe,'distribution','binomial','link','logit');
glm_rwd_threat = fitglm([rwdMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit');
glm_noRwd_threat = fitglm([noRwdMatx_threat]', combinedAllChoice_R_threat,'distribution','binomial','link','logit');
glm_all_threat = fitglm([rwdMatx_threat' noRwdMatx_threat'], combinedAllChoice_R_threat,'distribution','binomial','link','logit');
t = struct;
t.binSize = binSize;
t.timeMax = timeMax;
t.tMax = tMax;
t.timeBinEdges = timeBinEdges;

% if plotFlag
%     figure; hold on;
%     relevInds = 2:tMax+1;
%     coefVals = glm_all_safe.Coefficients.Estimate(relevInds);
%     CIbands = coefCI(glm_all_safe);
%     errorL = abs(coefVals - CIbands(relevInds,1));
%     errorU = abs(coefVals - CIbands(relevInds,2));
%     errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)
% 
% %     relevInds = tMax+2:2*tMax+1;
% %     coefVals = glm_all_safe.Coefficients.Estimate(relevInds);
% %     CIbands = coefCI(glm_all_safe);
% %     errorL = abs(coefVals - CIbands(relevInds,1));
% %     errorU = abs(coefVals - CIbands(relevInds,2));
% %     errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'b','linewidth',2)
% 
%     legend('Reward', 'No Reward')
%     xlabel('Outcome n seconds back')
%     ylabel('\beta Coefficient')
%     xlim([0 tMax*binSize/1000 + binSize/1000])
%     title([animal ' ' category])
% % end