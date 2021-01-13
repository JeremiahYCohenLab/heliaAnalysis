function wslsRwdHx_opMAP(xlFile, animals, categories, revForFlag, plotFlag)

if nargin < 5
    plotFlag = 0;
end
if nargin < 4
    revForFlag = 0;
end

[root, sep] = currComputer();
tMax = 12;

% for j = 1:length(animals)
    
%     [~, dayLjst, ~] = xlsread(xlfile, animals{j});
    [weights, dayList, ~] = xlsread(xlFile, animals);
    [~,col] = find(~cellfun(@isempty,strfind(dayList, categories)) == 1);
%     [~,col] = find(~cellfun(@jsempty,strfind(dayLjst, categorjes{j})) == 1);
    dayList = dayList(2:end,col);
    endInd = find(cellfun(@isempty,dayList),1);
    if ~isempty(endInd)
        dayList = dayList(1:endInd-1,:);
    end
    
    [glm_safe, glm_threat, tMax] = combineStates_opMAPP(xlFile, animals, categories, revForFlag);
    expfit_safe = singleExpFit(glm_safe.Coefficients.Estimate(2:tMax+1)); %% what glm??? i thinkrwdnorwd
    expfit_threat = singleExpFit(glm_threat.Coefficients.Estimate(2:tMax+1));
    expConv_safe = expfit_safe.a*exp(-(1/expfit_safe.b)*(1:tMax));
    expConv_safe = expConv_safe./sum(expConv_safe);
    expConv_threat = expfit_threat.a*exp(-(1/expfit_threat.b)*(1:tMax));
    expConv_threat = expConv_threat./sum(expConv_threat);

    combinedRwdHx_safe = [];
    combinedRwds_safe = [];
    combinedChangeChoice_safe = [];
    combinedRwdHx_threat = [];
    combinedRwds_threat = [];
    combinedChangeChoice_threat = [];
    
    for j = 1: length(dayList)
        sessionName = dayList{j};
        [animalName, date] = strtok(sessionName, 'd'); 
%         animalName = animalName(2:end);
        date = date(1:9);
        sessionFolder = ['m' animalName date];
        sessionName  = ['m' sessionName ];

        if isstrprop(sessionName(end), 'alpha')
            sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sessionName(end) sep sessionName '_sessionData_behav.mat'];
        else
            sessionDataPath = [root animalName sep sessionFolder sep 'sortedap' sep 'session' sep sessionName '_sessionData_behav.mat'];
        end

        if exist(sessionDataPath,'file')
            load(sessionDataPath);
            if revForFlag
                behSessionData = sessionData;
            end
        elseif revForFlag                                    %otherwjse generate the struct
            [behSessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
        else
            [behSessionData, ~, ~, ~] = generateSessionData_operantMatchingDecoupled(sessionName);
        end

        responseInds = find(~isnan([behSessionData.rewardTime])); % find CS+ trjals wjth a response jn the ljck window
        stateType = [behSessionData(responseInds).stateType];
        responseIndstate = NaN(1,length(behSessionData(responseInds)));
        responseIndstate(stateType ~= 0) = 1;
        responseIndstate(isnan(responseIndstate)) = 0;
        threatInds = find(responseIndstate == 1);
        safeInds = find(responseIndstate == 0);
        stateChangeInds = [1 (find(abs(diff([behSessionData(responseInds).stateType])) == 1) + 1)  length(responseInds)];

%         allairpuff = [behsessionData(responseInds).AirpuffTimeOn];
%         allairpuff(allairpuff ~= 0) = 1;
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
        allRewardsBin = allRewards;
   
        allRewardsBin(allRewards == -1) = 1;
        
        allRewardsBin_safe = allRewardsBin(safeInds);
        allRewardsBin_threat = allRewardsBin(threatInds);
        allNoRewards = allChoices;
        allNoRewards(logical(allReward_R)) = 0;
        allNoRewards(logical(allReward_L)) = 0;
 
       
        rwdHx_safe = conv(allRewardsBin_safe, expConv_safe);
        rwdHx_safe = rwdHx_safe(1:(end-(length(expConv_safe)-1)));
        rwdHx_threat = conv(allRewardsBin_threat, expConv_threat);
        rwdHx_threat = rwdHx_threat(1:(end-(length(expConv_threat)-1)));


         
          combinedRwdHx_safe = [combinedRwdHx_safe rwdHx_safe(1:end-2)];
          combinedRwdHx_threat = [combinedRwdHx_threat rwdHx_threat(1:end-2)];
          combinedRwds_safe = [combinedRwds_safe allRewardsBin_safe(2:end-1)];
          combinedRwds_threat = [combinedRwds_threat allRewardsBin_threat(2:end-1)];
          changeChoice_safe = [abs(diff(allChoices(safeInds))) > 0];
          changeChoice_threat = [abs(diff(allChoices(threatInds))) > 0];
          combinedChangeChoice_safe = [combinedChangeChoice_safe changeChoice_safe(2:end)];
          combinedChangeChoice_threat = [combinedChangeChoice_threat changeChoice_threat(2:end)];
    end
    
    rwdHxInds_low_safe = logical(combinedRwdHx_safe < 1/3);
    rwdHxInds_low_threat = logical(combinedRwdHx_threat < 1/3);
    rwdHxInds_med_safe = logical(combinedRwdHx_safe > 1/3 & combinedRwdHx_safe < 2/3);
    rwdHxInds_med_threat = logical(combinedRwdHx_threat > 1/3 & combinedRwdHx_threat < 2/3);
    rwdHxInds_high_safe = logical(combinedRwdHx_safe > 2/3);
    rwdHxInds_high_threat = logical(combinedRwdHx_threat > 2/3);
    probSwitchNoRwd_low_safe = sum(combinedChangeChoice_safe(combinedRwds_safe==0 & rwdHxInds_low_safe))/sum(combinedRwds_safe==0 & rwdHxInds_low_safe);
    probSwitchNoRwd_low_threat = sum(combinedChangeChoice_threat(combinedRwds_threat==0 & rwdHxInds_low_threat))/sum(combinedRwds_threat==0 & rwdHxInds_low_threat);
    probSwitchNoRwd_med_safe = sum(combinedChangeChoice_safe(combinedRwds_safe==0 & rwdHxInds_med_safe))/sum(combinedRwds_safe==0 & rwdHxInds_med_safe);
    probSwitchNoRwd_med_threat = sum(combinedChangeChoice_threat(combinedRwds_threat==0 & rwdHxInds_med_threat))/sum(combinedRwds_threat==0 & rwdHxInds_med_threat);
    probSwitchNoRwd_high_safe = sum(combinedChangeChoice_safe(combinedRwds_safe==0 & rwdHxInds_high_safe))/sum(combinedRwds_safe==0 & rwdHxInds_high_safe);
    probSwitchNoRwd_high_threat = sum(combinedChangeChoice_threat(combinedRwds_threat==0 & rwdHxInds_high_threat))/sum(combinedRwds_threat==0 & rwdHxInds_high_threat);
    probStayRwd_low_safe = 1 - (sum(combinedChangeChoice_safe(combinedRwds_safe==1 & rwdHxInds_low_safe))/sum(combinedRwds_safe==1 & rwdHxInds_low_safe));
    probStayRwd_low_threat = 1 - (sum(combinedChangeChoice_threat(combinedRwds_threat==1 & rwdHxInds_low_threat))/sum(combinedRwds_threat==1 & rwdHxInds_low_threat));
    probStayRwd_med_safe = 1 - (sum(combinedChangeChoice_safe(combinedRwds_safe==1 & rwdHxInds_med_safe))/sum(combinedRwds_safe==1 & rwdHxInds_med_safe));
    probStayRwd_med_threat = 1 - (sum(combinedChangeChoice_threat(combinedRwds_threat==1 & rwdHxInds_med_threat))/sum(combinedRwds_threat==1 & rwdHxInds_med_threat));
    probStayRwd_high_safe = 1 - (sum(combinedChangeChoice_safe(combinedRwds_safe==1 & rwdHxInds_high_safe))/sum(combinedRwds_safe==1 & rwdHxInds_high_safe));
    probStayRwd_high_threat = 1 - (sum(combinedChangeChoice_threat(combinedRwds_threat==1 & rwdHxInds_high_threat))/sum(combinedRwds_threat==1 & rwdHxInds_high_threat));
figure;
subplot(1,2,1); hold on;
% for j = 1:length(animals)
    plot([1 2 3], [probStayRwd_low_safe probStayRwd_med_safe probStayRwd_high_safe], 'LineWidth', 2);
    hold on;
    plot([1 2 3], [probStayRwd_low_threat probStayRwd_med_threat probStayRwd_high_threat], 'LineWidth', 4,'Color', 'y' );
% end
xticks([0.5 2 3.5])
xticklabels({'low', 'medium', 'high'})
ylabel('probability')
title('win-stay')
% legend([animals])
subplot(1,2,2); hold on;
% for j = 1:length(animals)
    plot([1 2 3], [probSwitchNoRwd_low_safe probSwitchNoRwd_med_safe probSwitchNoRwd_high_safe], 'LineWidth', 2);
    hold on;
    plot([1 2 3], [probSwitchNoRwd_low_threat probSwitchNoRwd_med_threat probSwitchNoRwd_high_threat], 'LineWidth', 4, 'Color', 'y');
% end
xticks([0.5 2 3.5]);
xticklabels({'low', 'medium', 'high'});
ylabel('probability')
title('lose-shift');
legend('safe', 'threat');
end