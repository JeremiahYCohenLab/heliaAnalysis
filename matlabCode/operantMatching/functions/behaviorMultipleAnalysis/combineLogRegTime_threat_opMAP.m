function [glm_all_threat, t] = combineLogRegTime_threat_opMAP(xlFile, animal, category, revForFlag)

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
rwdMatx_states =[]; %these go back to being empty for the next day
noRwdMatx_states = [];
combinedAllChoice_R_states = [];
rwdTempMatx = [];

%loop for each session in the list
for i = 1: length(dayList)              
    sessionName = dayList{i};                       %extract relevant info from session title
    [animalName, date] = strtok(sessionName, 'd'); 
    animalName = animalName(2:end);
    date = date(1:9);
    sessionFolder = ['m' animalName date];
     rwdRateMatx_threat_state = [];
    combinedRewardsMatx_threat_state = [];
    combinedNoRewardsMatx_threat_state = [];
    combinedChoicesMatx_threat_state = [];
    combinedAllChoice_R_threat_state = [ ];
    combinedAirpuff_state = [];
    if isstrprop(sessionName(end), 'alpha')         %define appropriate data path
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sessionName(end) sep sessionName '_sessionData_behav.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sep sessionName '_sessionData_behav.mat'];
    end

    if exist(sessionDataPath,'file')        %load preprocessed struct if there is one
        load(sessionDataPath)
         behSessionData = sessionData;
        if revForFlag
           behSessionData = sessionData;
        end
    elseif revForFlag                                    %otherwise generate the struct
        [behSessionData, blockSwitch, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
   

            %[behSessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
    end
%     if revForFlag                                    %otherwise generate the struct
%         [behsessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
% 
%     else
%         [behSessionData, ~, ~, ~] = generateSessionData_operantMatchingDecoupled(sessionName);
%     end
    
    %create arrays for choices and rewards
    responseInds = find(~isnan([behSessionData.rewardTime])); % find CS+ trials with a response in the lick window
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
    allReward_R = [behSessionData(responseInds_threat(responseInds)).rewardR]; 
    allReward_L = [behSessionData(responseInds_threat(responseInds)).rewardL]; 
    allChoices = NaN(1,length(behSessionData(responseInds_threat(responseInds))));
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
        rwdTmpMatx = NaN(tMax, length(responseInds));     %initialize matrices for number of response trials x number of time bins
        noRwdTmpMatx = NaN(tMax, length(responseInds));
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
            ;
            
            
                rwdTmpMatx = NaN(tMax, length(responseInds));     %initialize matrices for number of response trials x number of time bins
                noRwdTmpMatx = NaN(tMax, length(responseInds));
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
            %bin outcome times and use to fill matrices
            for l = 1: length(stateSwitchInd_threat)-1
                rwdTmpMatx = NaN(tMax, length(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j));     %initialize matrices for number of response trials x number of time bins
                noRwdTmpMatx = NaN(tMax, length(responseInds));
                 if(stateSwitchInd_threatTmp(stateSwitchInd_threat(l+1)) ~=0 && stateSwitchInd_threatTmp(stateSwitchInd_threat(l)) ~= 0)
                    if (length(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1))> tMax)
                        if ~isempty(timeTmpL)
                            binnedRwds = discretize(timeTmpL(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j),timeBinEdges);
                            for k = 1:tMax
                                if ~isempty(binnedRwds == k)
                                    rwdTmpMatx(k,j) = -1*sum(binnedRwds == k);
                                else
                                    rwdTmpMatx(k,j) = 0;
                                end
                            end
                        end
                        if ~isempty(timeTmpR(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j))
                            binnedRwds = discretize(timeTmpR(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j),timeBinEdges);
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
                        if isempty(timeTmpL(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j)) & isempty(timeTmpR(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j))
                            rwdTmpMatx(:,j) = 0;
                        end
                        if ~isempty(nTimeTmpL(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j))
                            binnedNoRwds = discretize(nTimeTmpL,timeBinEdges);
                            for k = 1:tMax
                                if ~isempty(binnedNoRwds == k)
                                    noRwdTmpMatx(k,j) = -1*sum(binnedNoRwds == k);
                                else
                                    noRwdTmpMatx(k,j) = 0;
                                end
                            end
                        end
                        if ~isempty(nTimeTmpR(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j))
                            binnedNoRwds = discretize(nTimeTmpR(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j),timeBinEdges);
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
                        if isempty(nTimeTmpL(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j)) & isempty(nTimeTmpR(stateSwitchInd_threat(l):stateSwitchInd_threat(l+1)-j))
                            noRwdTmpMatx(:,j) = 0;
                        end
                        rwdMatx_states = [rwdMatx_states NaN(length(timeBinEdges)-1, 15) rwdTmpMatx]; %these are the matrices of each state
                         noRwdMatx_states = [noRwdMatx_states NaN(length(timeBinEdges)-1, 15) noRwdTmpMatx];
                         combinedAllChoice_R_states = [combinedAllChoice_R_states NaN(1,15) allChoice_R]; 
                    end
              end
        end
    %concatenate temp matrix with combined matrix
%      rwdTmpMatx(:,1) = NaN;
            rwdMatx_States(:,1) = NaN;
            rwdMatx = [rwdMatx NaN(length(timeBinEdges)-1, 100) rwdMatx_states];
            noRwdMatx = [noRwdMatx NaN(length(timeBinEdges)-1, 100) noRwdMatx_states];
            combinedAllChoice_R = [combinedAllChoice_R NaN(1,100) combinedAllChoice_R_states];
            rwdMatx_states =[]; %these go back to being empty for the next day
            noRwdMatx_states = [];
            combinedAllChoice_R_states = [];
end

%logistic regression models
glm_rwd_threat = fitglm([rwdMatx]', combinedAllChoice_R,'distribution','binomial','link','logit');
glm_noRwd_threat = fitglm([noRwdMatx]', combinedAllChoice_R,'distribution','binomial','link','logit');
glm_all_threat = fitglm([rwdMatx' noRwdMatx'], combinedAllChoice_R,'distribution','binomial','link','logit');

t = struct;
t.binSize = binSize;
t.timeMax = timeMax;
t.tMax = tMax;
t.timeBinEdges = timeBinEdges;

% if plotFlag
%     figure; hold on;
%     relevInds = 2:tMax+1;
%     coefVals = glm_all_threat.Coefficients.Estimate(relevInds);
%     CIbands = coefCI(glm_all_threat);
%     errorL = abs(coefVals - CIbands(relevInds,1));
%     errorU = abs(coefVals - CIbands(relevInds,2));
%     errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)
% 
%     relevInds = tMax+2:2*tMax+1;
%     coefVals = glm_all_threat.Coefficients.Estimate(relevInds);
%     CIbands = coefCI(glm_all_threat);
%     errorL = abs(coefVals - CIbands(relevInds,1));
%     errorU = abs(coefVals - CIbands(relevInds,2));
%     errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'b','linewidth',2)
% 
%     legend('Reward', 'No Reward')
%     xlabel('Outcome n seconds back')
%     ylabel('\beta Coefficient')
%     xlim([0 tMax*binSize/1000 + binSize/1000])
%     title([animal ' ' category])
% % end