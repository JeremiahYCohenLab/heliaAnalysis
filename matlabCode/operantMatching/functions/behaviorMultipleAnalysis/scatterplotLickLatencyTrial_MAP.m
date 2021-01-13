function scatterplotLickLatencyTrial_MAP(xlFile, animal, category, revForFlag)
%  for rt for each session two states

[root, sep] = currComputer();

[weights, dayList, ~] = xlsread(xlFile, animal);
[~,col] = find(~cellfun(@isempty,strfind(dayList, category)) == 1);
dayList = dayList(2:end,col);
endInd = find(cellfun(@isempty,dayList),1);
if ~isempty(endInd)
    dayList = dayList(1:endInd-1,:);
end
%a = length(dayList);
lickLatencySafe =  zeros(length(dayList), 2);
lickLatencythreat = zeros(length(dayList), 2);
lickLatencySafeOrg =  zeros(length(dayList), 2);
lickLatencythreatOrg = zeros(length(dayList), 2);
% combinedLickLat_safe = [];
% combinedLickLat_threat = [];
% StayLickLat_safe = []; 
% SwitchLickLat_safe = [];
% StayLickLat_threat = []; 
% SwitchLickLat_threat = [];





for i = 1: length(dayList)
    sessionName = dayList{i};
    [animalName, date] = strtok(sessionName, 'd'); 
    %animalName = animalName(2:end);
    sessionName = ['m' sessionName];
    date = date(1:9);
    sessionFolder = ['m' animalName date];
    if isstrprop(sessionName(end), 'alpha')
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sep sessionFolder(end) sep sep sessionFolder '_sessionData_behav.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sortedap' sep 'session' sep sessionName '_sessionData_behav.mat'];
    end
    if exist(sessionDataPath,'file')
        load(sessionDataPath);
        behSessionData = sessionData;
        if revForFlag
            [behSessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
        end
    elseif revForFlag                                    %otherwise generate the struct
        [behSessionData,blockSwitch, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);

    else
        [behSessionData, ~, ~, ~] = generateSessionData_operantMatchingDecoupled(sessionName);
    end
%     combinedRewardsMatx_threat = [combinedRewardsMatx_threat NaN(tMax,100) combinedRewardsMatx_threat_state];
%     combinedRewardsMatx_safe = [combinedRewardsMatx_safe NaN(tMax,100) combinedRewardsMatx_safe_state];
            %% determine and plot lick latency distributions for each spout
                responseInds = find(~isnan([behSessionData.rewardTime]));
                stateType = [behSessionData(responseInds).stateType];
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
                lickLat = [behSessionData(responseInds).rewardTime] - [behSessionData(responseInds).CSon];
                indsR = find(allChoices == 1);
                indsL = find(allChoices == -1);
                lickLat_R = zscore(lickLat(indsR));
                lickLat_L = zscore(lickLat(indsL));
                
                lickLat_ROrg = lickLat(indsR);
                lickLat_LOrg = lickLat(indsL);
                 
                 
                lickLat = NaN(1, length(allChoices));
                lickLat(indsR) = lickLat_R;
                lickLat(indsL) = lickLat_L;
                
                
                lickLatOrg = NaN(1, length(allChoices));
                lickLatOrg(indsR) = lickLat_ROrg;
                lickLatOrg(indsL) = lickLat_LOrg;
                stateChangeInds = [1 (find(abs(diff([behSessionData(responseInds).stateType])) == 1) + 1)  length(responseInds)];
%   combinedLickLatOrg_threat_state = [];    
%   changeChoice_threat_state = [];
%   StayLickLatOrg_threat_state = []; 
%   SwitchLickLatOrg_threat_state = [];
%   combinedLickLatOrg_safe_state = [];
%   changeChoice_safe_state = [];
%   StayLickLatOrg_safe_state = []; 
%   SwitchLickLatOrg_safe_state = [];                           
%   combinedLickLat_threat_state = [];    
%   changeChoice_threat_state = [];
%   StayLickLat_threat_state = []; 
%   SwitchLickLat_threat_state = [];
%   combinedLickLat_safe_state = [];
%   changeChoice_safe_state = [];
%   StayLickLat_safe_state = []; 
%   SwitchLickLat_safe_state = [];
  LickLat_threat_state = [];
  LickLat_safe_state = [];
  LickLat_threat_stateOrg = [];
  LickLat_safe_stateOrg = [];
 changeChoice = [false abs(diff(allChoices)) > 0];
  for currT = 1:length(stateChangeInds)-1   %% determine lick latency for stay v switch trials for safe and threat sepearetaly
%          if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
            if stateType(stateChangeInds(currT)) == 1 %plus 2 to not look at the first lick lat
%                 combinedLickLat_threat_state = [combinedLickLat_threat_state NaN(1,15) lickLat(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
                LickLat_threat_state = [LickLat_threat_state lickLat(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                LickLat_threat_stateOrg = [LickLat_threat_stateOrg lickLatOrg(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 changeChoice_threat_state = [false abs(diff(allChoices(stateChangeInds(currT-1)+1:stateChangeInds(currT)-1))) > 0];
%                 StayLickLat_threat_state = [StayLickLat_threat_state  lickLat(~changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))]; 
%                 SwitchLickLat_threat_state = [SwitchLickLat_threat_state lickLat(changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))];
            else
%                 combinedLickLat_safe_state = [combinedLickLat_safe_state NaN(1,15) lickLat(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
                LickLat_safe_state = [LickLat_safe_state lickLat(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                LickLat_safe_stateOrg = [LickLat_safe_stateOrg lickLatOrg(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 changeChoice_safe_state = [false abs(diff(allChoices(stateChangeInds(currT-1)+1:stateChangeInds(currT)-1))) > 0];
%                 StayLickLat_safe_state = [StayLickLat_safe_state  lickLat(~changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))]; 
%                 SwitchLickLat_safe_state = [SwitchLickLat_safe_state  lickLat(changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))];
            end
  end
    lickLatencySafe(i,1) =  median(LickLat_safe_state);
    lickLatencySafe(i,2) = mean(LickLat_safe_state);
    lickLatencythreat(i,1) = median(LickLat_threat_state);
    lickLatencythreat(i,2)  =  mean(LickLat_threat_state);

    lickLatencySafeOrg(i,1) =  median(LickLat_safe_stateOrg);
    lickLatencySafeOrg(i,2) = mean(LickLat_safe_stateOrg);
    lickLatencythreatOrg(i,1) = median(LickLat_threat_stateOrg);
    lickLatencythreatOrg(i,2)  =  mean(LickLat_threat_stateOrg);
end
%         combinedLickLat_safe = [combinedLickLat_safe NaN(1,100) combinedLickLat_safe_state];
%         combinedLickLat_threat = [combinedLickLat_threat NaN(1,100) combinedLickLat_threat_state];
%         changeChoice_safe = [changeChoice_safe changeChoice_safe_state];
%         StayLickLat_safe = [StayLickLat_safe StayLickLat_safe_state]; 
%         SwitchLickLat_safe = [SwitchLickLat_safe SwitchLickLat_safe_state];
%          changeChoice_threat = [changeChoice_threat changeChoice_threat_state];
%         StayLickLat_threat = [StayLickLat_threat StayLickLat_threat_state]; 
%         SwitchLickLat_threat = [SwitchLickLat_threat SwitchLickLat_threat_state];
%         for currT = 1:length(stateChangeInds)-1   %% determine lick latency for stay v switch trials for safe and threat sepearetaly
%          if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
%             if stateType(stateChangeInds(currT)) == 1 %plus 2 to not look at the first lick lat
%                 combinedLickLatOrg_threat_state = [combinedLickLatOrg_threat_state NaN(1,15) lickLatOrg(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
%                 StayLickLatOrg_threat_state = [StayLickLatOrg_threat_state  lickLatOrg(~changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))]; 
%                 SwitchLickLatOrg_threat_state = [SwitchLickLatOrg_threat_state  lickLatOrg(changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))];
%             else
%                 combinedLickLatOrg_safe_state = [combinedLickLatOrg_safe_state NaN(1,15) lickLatOrg(stateChangeInds(currT)+1:stateChangeInds(currT+1)-1)];
%                 StayLickLatOrg_safe_state = [StayLickLatOrg_safe_state  lickLatOrg(~changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))]; 
%                 SwitchLickLatOrg_safe_state = [SwitchLickLatOrg_safe_state   lickLatOrg(changeChoice(stateChangeInds(currT):stateChangeInds(currT+1)-1))];
%             end
%          end
%        end
%         combinedLickLatOrg_safe = [combinedLickLatOrg_safe NaN(1,100) combinedLickLatOrg_safe_state];
%         combinedLickLatOrg_threat = [combinedLickLatOrg_threat NaN(1,100) combinedLickLatOrg_threat_state];
%         StayLickLatOrg_safe = [StayLickLatOrg_safe StayLickLatOrg_safe_state]; 
%         SwitchLickLatOrg_safe = [SwitchLickLatOrg_safe SwitchLickLatOrg_safe_state];
%         StayLickLatOrg_threat = [StayLickLatOrg_threat StayLickLatOrg_threat_state]; 
%         SwitchLickLatOrg_threat = [SwitchLickLatOrg_threat SwitchLickLatOrg_threat_state];

figure;
sp_mean = subplot(1,2,1); hold on
sp_median = subplot(1,2,2); hold on

subplot(sp_mean); title('median lick latency');
scatter(lickLatencySafe(:,1), lickLatencythreat(:,1), 25, 'filled', 'MarkerFaceColor',[0 .7 .7]); xlabel('safe'); ylabel('threat');
subplot(sp_median); hold on; title('mean lick latency');
scatter(lickLatencySafe(:,2), lickLatencythreat(:,2), 25, 'filled', 'MarkerFaceColor',[0 .85 .85]); xlabel('safe'); ylabel('threat');

for cP = [sp_mean sp_median]
    subplot(cP)
    xlim([-1 1])
    ylim([-1 1])
    plot([-1 1],[-1 1],'k:')
    axis square
    set(cP, 'tickdir', 'out')
end




figure;
sp_mean = subplot(1,2,1); hold on
sp_median = subplot(1,2,2); hold on
subplot(sp_mean); title('median lick latency absolute values'); hold on;
scatter(lickLatencySafeOrg(:,1), lickLatencythreatOrg(:,1), 25, 'filled', 'MarkerFaceColor',[0 .7 .7]); xlabel('safe'); ylabel('threat');
subplot(sp_median); hold on; title('mean lick latency absolute values');
scatter(lickLatencySafeOrg(:,2), lickLatencythreatOrg(:,2), 25, 'filled', 'MarkerFaceColor',[0 .85 .85]); xlabel('safe'); ylabel('threat');


for cP = [sp_mean sp_median]
    subplot(cP)
    xlim([200 1500])
    ylim([200 1500])
    plot([200 1500],[200 1500],'k:')
    axis square
    set(cP, 'tickdir', 'out')
end
end