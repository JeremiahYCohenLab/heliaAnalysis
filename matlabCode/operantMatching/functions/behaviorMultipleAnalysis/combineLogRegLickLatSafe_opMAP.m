function [glm_rwdLickSafe, safeStayLickLat, safeSwitchLickLat, tMax] = combineLogRegLickLatSafe_opMAP(xlFile, animal, category, varargin)

p = inputParser;
% default parameters if none given
p.addParameter('revForFlag',0)
p.addParameter('plotFlag', 0)
p.parse(varargin{:});
g =1;

[root, sep] = currComputer();

[weights, dayList, ~] = xlsread(xlFile, animal);
[~,col] = find(~cellfun(@isempty,strfind(dayList, category)) == 1);
dayList = dayList(2:end,col);
endInd = find(cellfun(@isempty,dayList),1);
if ~isempty(endInd)
    dayList = dayList(1:endInd-1,:);
end
combinedRewardsMatx = [];
combinedLickLat = [];
safeStayLickLat = []; 
safeSwitchLickLat = [];
tMax = 12;
stateSwitchflag = false;


for i = 1: length(dayList)
    sessionName = dayList{i};
    [animalName, date] = strtok(sessionName, 'd'); 
    animalName = animalName(2:end);
    date = date(1:9);
    sessionFolder = ['m' animalName date];
    stateSwitchflag = false;

    if isstrprop(sessionName(end), 'alpha')
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sep sessionName(end) sep sessionName '_sessionData.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sessionName '_sessionData.mat'];
    end

%     if exist(sessionDataPath,'file')
%         load(sessionDataPath)
%         if p.Results.revForFlag
%             behSessionData = sessionData;
%         end
%     else
        [behSessionData,blockSwitch, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
%     end
    
    %%generate reward matrix for tMax trials
    responseInds = find(~isnan([behSessionData.rewardTime]));
%     while ~stateSwitchflag
%         for h = 1:length(responseInds)
%             if (responseInds == stateSwitch(g))   
                responseInds_safe = find([behSessionData.stateType] == 0);
    %     allAirpuff = NaN(1,length(behSessionData(responseInds_threat)));
    %     allAirpuffInd = [behSessionData(responseInds_threat).AirpuffTimeOn];
    %     allAirpuff(~allAirpuffInd == 0) = 1;
    %     allAirpuff(isnan(allAirpuff)) = 0;% find CS+ trials with a response in the lick window
                allReward_R = [behSessionData(responseInds_safe).rewardR]; 
                allReward_L = [behSessionData(responseInds_safe).rewardL]; 
                allChoices = NaN(1,length(behSessionData(responseInds_safe)));
                allChoices(~isnan(allReward_R)) = 1;
                allChoices(~isnan(allReward_L)) = -1;
                allReward_R(isnan(allReward_R)) = 0;
                allReward_L(isnan(allReward_L)) = 0;
                allRewards = zeros(1,length(allChoices));
                allRewards(logical(allReward_R)) = 1;
                allRewards(logical(allReward_L)) = 1;


                rwdMatxTmp = []; %will make an upper triangle matrix
                for j = 1:tMax
                    rwdMatxTmp(j,:) = [NaN(1,j) allRewards(1:end-j)];
                end

                combinedRewardsMatx = [combinedRewardsMatx NaN(tMax,100) rwdMatxTmp(:,1:end-1)];


            %% determine and plot lick latency distributions for each spout
                lickLat = [behSessionData(responseInds_safe).rewardTime] - [behSessionData(responseInds_safe).CSon];
                indsR = find(allChoices == 1);
                indsL = find(allChoices == -1);
                lickLat_R = zscore(lickLat(indsR));
                lickLat_L = zscore(lickLat(indsL));
                lickLat = NaN(1, length(allChoices));
                lickLat(indsR) = lickLat_R;
                lickLat(indsL) = lickLat_L;

                combinedLickLat = [combinedLickLat NaN(1,100) lickLat(2:end)];

            %% determine lick latency for stay v switch trials
                changeChoice = [false abs(diff(allChoices)) > 0];
                safeStayLickLat = [safeStayLickLat lickLat(~changeChoice)]; 
                safeSwitchLickLat = [safeSwitchLickLat lickLat(changeChoice)];
%                 else
%                     stateSwitchflag = true;
%                     g = g +1;
            end
%         end        
%     end
end

%linear regression model
glm_rwdLickSafe = fitglm([combinedRewardsMatx]', combinedLickLat);

if p.Results.plotFlag
    figure; hold on
    relevInds = 2:tMax+1;
    coefVals = glm_rwdLickSafe.Coefficients.Estimate(relevInds);
    CIbands = coefCI(glm_rwdLickSafe);
    errorL = abs(coefVals - CIbands(relevInds,1));
    errorU = abs(coefVals - CIbands(relevInds,2));
    errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)

    xlabel('Reward n Trials Back')
    ylabel('\beta Coefficient')
    xlim([0.5 tMax+0.5])

    suptitle([animal ' ' category])
end