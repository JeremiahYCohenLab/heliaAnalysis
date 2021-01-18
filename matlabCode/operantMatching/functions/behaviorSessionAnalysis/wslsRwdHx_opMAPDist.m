function wslsRwdHx_opMAPDist(xlFile, animal, category, revForFlag, plotFlag)

ws_safeCom = [];
ls_safeCom = [];
ws_threatCom = [];
ls_threatCom = [];
if nargin < 5
    plotFlag = 0;
end
if nargin < 4
    revForFlag = 0;
end

[root, sep] = currComputer();

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
    w_safe = 0;
    w_threat = 0;
    ws_safe = 0;
    ws_threat = 0;
    
    l_safe = 0;
    l_threat = 0;
    ls_safe = 0;
    ls_threat = 0;
    responseInds = find(~isnan([behSessionData.rewardTime]));
    omitInds = isnan([behSessionData.rewardTime]); 
    stateType = [behSessionData(responseInds).stateType];
    stateChangeInds = [1 (find(abs(diff([behSessionData(responseInds).stateType])) == 1) + 1)  length(responseInds)];
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
    allNoRewards = allChoices;
    allNoRewards(logical(allReward_R)) = 0;
    allNoRewards(logical(allReward_L)) = 0;
%     outcomeTimes = [behSessionData(responseInds).rewardTime] - behSessionData(responseInds(1)).rewardTime;
%     outcomeTimes = [diff(outcomeTimes) NaN];
    for i = 1:length(responseInds) - 1
%         if i ~= stateChangeInds(:)
            if stateType(i) == 0
                if allRewards(i) == 1 % right reward
                    w_safe = w_safe + 1;
                    if  allChoices(i+1) == 1 % right choice
                        ws_safe = ws_safe + 1;
                    end
                elseif allRewards(i) == -1 % left reward
                    w_safe = w_safe + 1;
                    if allChoices(i+1) == -1 % left choice
                        ws_safe = ws_safe + 1;
                    end
                elseif allRewards(i) == 0 % no reward
                    l_safe = l_safe + 1;
                    if allChoices(i) == 1 && allChoices(i + 1) == -1 % prev right and next left
                        ls_safe = ls_safe + 1;
                    elseif allChoices(i) == -1 && allChoices(i + 1) == 1 % prev left and next right
                        ls_safe = ls_safe + 1;
                    end
                end
            elseif stateType(i) == 1
                if allRewards(i) == 1 % right reward
                    w_threat = w_threat + 1;
                    if  allChoices(i+1) == 1 % right choice
                        ws_threat = ws_threat + 1;
                    end
                elseif allRewards(i) == -1 % left reward
                    w_threat = w_threat + 1;
                    if allChoices(i+1) == -1 % left choice
                        ws_threat = ws_threat + 1;
                    end
                elseif allRewards(i) == 0 % no reward
                    l_threat = l_threat + 1;
                    if allChoices(i) == 1 && allChoices(i + 1) == -1 % prev right and next left
                        ls_threat = ls_threat + 1;
                    elseif allChoices(i) == -1 && allChoices(i + 1) == 1 % prev left and next right
                        ls_threat = ls_threat + 1;
                    end
                end
            end
%         end
    end
    ws_threatCom = [ws_threatCom ws_threat/w_threat];
    ls_threatCom = [ls_threatCom ls_threat/l_threat];
    ws_safeCom = [ws_safeCom ws_safe/w_safe];
    ls_safeCom = [ls_safeCom ls_safe/l_safe];
    
end
%%
figure
subplot(1,2,1); hold on
bins = linspace(0, 1, 20);
histogram(ws_safeCom, bins, 'normalization', 'probability','FaceColor', [1 1 1])
histogram(ws_threatCom, bins, 'normalization', 'probability','FaceColor', [255,255,0]./255)
legend('safe','threat')
title('Win-Stay')

subplot(1,2,2); hold on
bins = linspace(0, 1, 20);
histogram(ls_safeCom, bins, 'normalization', 'probability', 'FaceColor', [1 1 1])
histogram(ls_threatCom, bins, 'normalization', 'probability', 'FaceColor', [255,255,0]./255)
legend('safe','threat')
title('Lose-Shift')

%%
% real_fake = [ones(numel(ws_cno_real) + numel(ws_veh_real), 1); 2*ones(numel(ws_cno_fake) + numel(ws_veh_fake), 1)];
% cno_veh = [ones(numel(ws_cno_real), 1); 2*ones(numel(ws_veh_real), 1); ones(numel(ws_cno_fake), 1); ones(numel(ws_veh_fake), 1)];
% ws_mod = fitlm([real_fake cno_veh],[ws_cno_real ws_veh_real ws_cno_fake ws_veh_fake]');
% 
% real_fake = [ones(numel(ls_cno_real) + numel(ls_veh_real), 1); 2*ones(numel(ls_cno_fake) + numel(ls_veh_fake), 1)];
% cno_veh = [ones(numel(ls_cno_real), 1); 2*ones(numel(ls_veh_real), 1); ones(numel(ls_cno_fake), 1); ones(numel(ls_veh_fake), 1)];
% ls_mod = fitlm([real_fake cno_veh],[ls_cno_real ls_veh_real ls_cno_fake ls_veh_fake]');

% %%
% figure; hold on
% errorbar(0.9, mean(ws_threat), sem(ws_threat), 'k', 'linewidth', 2)
% errorbar(1.1, mean(ws_safe), sem(ws_safe), 'g', 'linewidth', 2)
%%
% 
% errorbar(1.9, mean(ws_threat), sem(ws_threat), 'k', 'linewidth', 2)
% errorbar(2.1, mean(ws_cno), sem(ws_cno), 'g', 'linewidth', 2)