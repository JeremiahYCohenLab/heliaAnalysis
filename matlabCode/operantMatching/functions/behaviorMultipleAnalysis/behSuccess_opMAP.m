function [rewardRateSafe ,rewardRateThreat, correctRateSafe, correctRateThreat, behTbl] = behSuccess_opMAP(xlFile, animal, category, revForFlag)

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
correctSafe = 0;
incorrectSafe = 0;
correctFractionSafe = zeros(1, length(dayList));
rewardFractionSafe = zeros(1, length(dayList));
correctThreat = 0;
incorrectThreat = 0;
correctFractionThreat = zeros(1, length(dayList));
rewardFractionThreat = zeros(1, length(dayList));




%guassian kernel for smoothing of raw rewards and choices
normKern = normpdf(-5:5,0,4);
normKern = normKern / sum(normKern);

choiceRange = 15;
noRwdCombinedSafe = [];
noRwdCombinedThreat = [];
changeHistogramSafe = [];
changeHistogramThreat = [];
rwdHistChangeSafe = []; 
rwdHistChangeThreat = [];
changeChoiceCombSafe = [];
changeChoiceCombThreat = [];
allRewardsCombSafe = [];
allRewardsBinCombSafe = [];
allRewardsBinCombThreat = [];
allRewardsCombThreat = [];


for i = 1: length(dayList)
    sessionName = ['m' dayList{i}];
    [animalName, date] = strtok(sessionName, 'd'); 
    animalName = animalName(2:end);
    date = date(1:9);
    sessionFolder = ['m' animalName date];


    if isstrprop(sessionName(end), 'alpha')
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sessionName(end) sep sessionName '_sessionData_behav.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sortedap' sep 'session' sep sessionName '_sessionData_behav.mat'];
    end

%     if exist(sessionDataPath,'file')
%         load(sessionDataPath);
%         behSessionData = sessionData;
%         if revForFlag
%             behSessionData = sessionData;
%         end
%     else
%         if revForFlag                                    %otherwise generate the struct
%             [behSessionData, ~] = generateSessionData_behav_operantMatching(sessionName);
%         else
%             [behSessionData, ~, ~, ~] = generateSessionData_operantMatchingDecoupled(sessionName);
             [behSessionData,blockSwitch, blockProbs, stateSwitch] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
%         end
%     end
    responseInds = find(~isnan([behSessionData.rewardTime])); % find CS+ trials with a response in the lick window
    stateType = [behSessionData(responseInds).stateType];
    stateTypeSafeInd = find(stateType ==0);
    stateTypeThreatInd = find(stateType ==1);
    allReward_R = [behSessionData(responseInds).rewardR]; 
    allReward_RSafe = allReward_R(stateTypeSafeInd);
    allReward_RThreat = allReward_R(stateTypeThreatInd);
    allReward_L = [behSessionData(responseInds).rewardL]; 
    allReward_LSafe = allReward_L(stateTypeSafeInd);
    allReward_LThreat = allReward_L(stateTypeThreatInd);
    allChoicesSafe = NaN(1,length(stateTypeSafeInd));
    allChoicesThreat = NaN(1,length(stateTypeThreatInd));
    allChoicesSafe(~isnan(allReward_LSafe)) = -1;
    allChoicesSafe(~isnan(allReward_RSafe)) = 1;
    allChoicesThreat(~isnan(allReward_LThreat)) = -1;
    allChoicesThreat(~isnan(allReward_RThreat)) = 1;
    allChoice_RSafe = double(allChoicesSafe == 1);
    allChoice_LSafe = double(allChoicesSafe == -1);
    allChoice_RThreat = double(allChoicesThreat == 1);
    allChoice_LThreat = double(allChoicesThreat == -1);
    
    allReward_RSafe(isnan(allReward_RSafe)) = 0;
    allReward_LSafe(isnan(allReward_LSafe)) = 0;
    
    allReward_RThreat(isnan(allReward_RThreat)) = 0;
    allReward_LThreat(isnan(allReward_LThreat)) = 0;

    allRewardsSafe = zeros(1,length(allChoicesSafe));
    allRewardsSafe(logical(allReward_RSafe)) = 1;
    allRewardsSafe(logical(allReward_LSafe)) = -1;
    
    allRewardsThreat = zeros(1,length(allChoicesThreat));
    allRewardsThreat(logical(allReward_RThreat)) = 1;
    allRewardsThreat(logical(allReward_LThreat)) = -1;
    
    rewardProbR = [behSessionData(responseInds).rewardProbR];
    rewardProbL = [behSessionData(responseInds).rewardProbL];
    
    rewardProbRSafe = rewardProbR(stateTypeSafeInd);
    rewardProbLSafe = rewardProbL(stateTypeSafeInd);
    
    rewardProbRThreat = rewardProbR(stateTypeThreatInd);
    rewardProbLThreat = rewardProbL(stateTypeThreatInd);
    
    
    stateChangeInds = [1 (find(abs(diff([behSessionData(responseInds).stateType])) == 1) + 1)  length(responseInds)];
    for j = 1:length(stateTypeSafeInd)
             if (allChoicesSafe(j) == 1 & (rewardProbRSafe(j) >= rewardProbLSafe(j)) | ...
                    allChoicesSafe(j) == -1 & (rewardProbLSafe(j)) >= rewardProbRSafe(j))
                    correctSafe = correctSafe + 1;
                    correctFractionSafe(i) = correctFractionSafe(i) + 1;
             else
                    incorrectSafe = incorrectSafe + 1;
             end
    end
    for j = 1:length(stateTypeThreatInd)
             if (allChoicesThreat(j) == 1 & (rewardProbRThreat(j) >= rewardProbLThreat(j)) | ...
                    allChoicesThreat(j) == -1 & (rewardProbLThreat(j) >= rewardProbRThreat(j)))
                    correctThreat = correctThreat + 1;
                    correctFractionThreat(i) = correctFractionThreat(i) + 1;
             else
                    incorrectThreat = incorrectThreat + 1;
             end
    end

    %see if behavior differs from chance
    
            if mod(length(stateTypeSafeInd),2) == 1
                tmpCorrectSafe = correctFractionSafe(i) - 1;
                tmpRespSafe = length(stateTypeSafeInd) - 1;
            else
            tmpCorrectSafe = correctFractionSafe(i);
            tmpRespSafe = length(stateTypeSafeInd);
            end
            if mod(length(stateTypeThreatInd),2) == 1
                tmpCorrectThreat = correctFractionThreat(i) - 1;
                tmpRespThreat = length(stateTypeThreatInd) - 1;
            else
            tmpCorrectThreat = correctFractionThreat(i);
            tmpRespThreat= length(stateTypeThreatInd);
            end
            
    xSafe = [ones(1, tmpCorrectSafe) zeros(1, (tmpRespSafe - tmpCorrectSafe))];
    ySafe = [ones(1, tmpRespSafe/2) zeros(1, tmpRespSafe/2)];
    randChanceSafe(i) = ranksum(xSafe,ySafe);
    
    xThreat = [ones(1, tmpCorrectThreat) zeros(1, (tmpRespThreat - tmpCorrectThreat))];
    yThreat = [ones(1, tmpRespThreat/2) zeros(1, tmpRespThreat/2)];
    randChanceThreat(i) = ranksum(xThreat,yThreat);
    
    %find fraction of trials that are rewarded and fraction that are on the higher spout
    allRewardsBinSafe = allRewardsSafe;
    allRewardsBinThreat = allRewardsThreat;
    allRewardsBinSafe(allRewardsSafe == -1) = 1;
    allRewardsBinThreat(allRewardsThreat == -1) = 1;
    rewardFractionSafe(i) = sum(allRewardsBinSafe)/length(allRewardsBinSafe);
    correctFractionSafe(i) = correctFractionSafe(i)/length(allRewardsSafe);
    allRewardsBinCombSafe = [allRewardsBinCombSafe allRewardsBinSafe];
    rewardFractionThreat(i) = sum(allRewardsBinThreat)/length(allRewardsBinThreat);
    correctFractionThreat(i) = correctFractionThreat(i)/length(allRewardsThreat);
    allRewardsBinCombThreat = [allRewardsBinCombThreat allRewardsBinThreat];
  
    %find distance between smoothed rewards and choices   
    smoothChoicesSafe = conv(allChoicesSafe,normKern, 'same')/max(conv(allChoicesSafe,normKern,'same'));
    smoothRewardsS = conv(allRewardsSafe,normKern,'same')/max(conv(allRewardsSafe,normKern,'same'));
    avgDistSafe(i) = mean(abs(smoothChoicesSafe - smoothRewardsS));
    semDistSafe(i) = std(abs(smoothChoicesSafe - smoothRewardsS)) / sqrt(length(allRewardsSafe));
    
    
    smoothChoicesThreat = conv(allChoicesThreat,normKern, 'same')/max(conv(allChoicesThreat,normKern,'same'));
    smoothRewardsTH = conv(allRewardsThreat,normKern,'same')/max(conv(allRewardsThreat,normKern,'same'));
    avgDistThreat(i) = mean(abs(smoothChoicesThreat - smoothRewardsTH));
    semDistThreat(i) = std(abs(smoothChoicesThreat - smoothRewardsTH)) / sqrt(length(allRewardsThreat));
    

    %find choice behavior prior to a zero crossing of smoothed choices
%     LtoR = [];
%     RtoL = [];
%     for j = 1:length(smoothChoices)-1
%         if smoothChoices(j) < 0 & smoothChoices(j+1) > 0
%             LtoR = [LtoR j];
%         elseif smoothChoices(j) > 0 & smoothChoices(j+1) < 0
%             RtoL = [RtoL j];
%         end
%     end
%     for j = 1:length(LtoR)
%         if LtoR(j) > choiceRange
%             noRwdL(j) = length(find(allRewards(LtoR(j)-choiceRange:LtoR(j)) == 0 & allChoices(LtoR(j)-choiceRange:LtoR(j)) == -1));
%         else
%             noRwdL(j) = NaN;
%         end
%     end
%     for j = 1:length(RtoL)
%         if RtoL(j) > choiceRange
%             noRwdR(j) = length(find(allRewards(RtoL(j)-choiceRange:RtoL(j)) == 0 & allChoices(RtoL(j)-choiceRange:RtoL(j)) == 1));
%         else
%             noRwdR(j) = NaN;
%         end
%     end
%     avgNoRwd(i) = nanmean([noRwdR noRwdL]);
%     noRwdCombined = [noRwdCombined noRwdR noRwdL];
        
    %find probability of switch/stay given no rwd/rwd
    changeChoiceSafe = [abs(diff(allChoicesSafe)) > 0];
    allRewardzSafe = allRewardsBinSafe(1:end-1);
    probSwitchNoRwdSafe(i) = sum(changeChoiceSafe(allRewardzSafe==0))/sum(allRewardzSafe==0);
    probStayRwdSafe(i) = 1 - (sum(changeChoiceSafe(allRewardzSafe==1))/sum(allRewardzSafe==1));
    normSwitchesSafe(i) = sum(changeChoiceSafe)/length(allChoicesSafe);
    
    changeChoiceCombSafe = [changeChoiceCombSafe changeChoiceSafe];
    allRewardsCombSafe = [allRewardsCombSafe allRewardzSafe];
 
    changeChoiceThreat = [abs(diff(allChoicesThreat)) > 0];
    allRewardzThreat = allRewardsBinThreat(1:end-1);
    probSwitchNoRwdThreat(i) = sum(changeChoiceThreat(allRewardzThreat==0))/sum(allRewardzThreat==0);
    probStayRwdThreat(i) = 1 - (sum(changeChoiceThreat(allRewardzThreat==1))/sum(allRewardzThreat==1));
    normSwitchesThreat(i) = sum(changeChoiceThreat)/length(allChoicesThreat);
    
    changeChoiceCombThreat = [changeChoiceCombThreat changeChoiceThreat];
    allRewardsCombThreat = [allRewardsCombThreat allRewardzThreat];
   %% 
%     tMax = 10;
%     rwdMatx = [];
%     for j = 1:tMax
%         rwdMatx(j,:) = [NaN(1,j) allRewards(1:end-j)];
%     end
% 
%     glm_rwd = fitglm([rwdMatx]', allChoice_R,'distribution','binomial','link','logit');
%     
%     expFit = singleExpFit(glm_rwd.Coefficients.Estimate(2:end));
%     expConv = expFit.a*exp(-(1/expFit.b)*(1:10));
%     expConv = expConv./sum(expConv);
% 
%     rwdsTemp = find(allRewards == -1);                          %make all rewards have the same value
%     allRewardsBinary = allRewards;
%     allRewardsBinary(rwdsTemp) = 1;
%     rwdHx = conv(allRewardsBinary,expConv);              %convolve with exponential decay to give weighted moving average
%     rwdHx = rwdHx(1:end-(length(expConv)-1));                   %to account for convolution padding
%     rwdHx_L = conv(allReward_L,expConv);                 %same convolution but only with L rewards over all trials
%     rwdHx_L = rwdHx_L(1:end-(length(expConv)-1));  
%     rwdHx_R = conv(allReward_R,expConv);
%     rwdHx_R = rwdHx_R(1:end-(length(expConv)-1));
%     
%     for j = find(changeChoice == 1)
%         if j > 1
%             if allChoices(j) == 1 
%                 temp = 0;
%                 goBack = 1;
%                 while (j - goBack > 0) && allChoices(j-goBack) == -1 && allRewards(j-goBack) == 0
%                     temp = temp + 1;
%                     goBack = goBack + 1;
%                 end
%                 changeHistogram = [changeHistogram temp];
%                 rwdHistChange = [rwdHistChange rwdHx(j-1)];
%             elseif allChoices(j) == -1
%                 temp = 0;
%                 goBack = 1;
%                 while (j - goBack > 0) && allChoices(j-goBack) == 1 && allRewards(j-goBack) == 0 % 
%                     temp = temp + 1;
%                     goBack = goBack + 1;
%                 end
%                 changeHistogram = [changeHistogram temp];
%                 rwdHistChange = [rwdHistChange rwdHx(j-1)];
%             end
%         end
%     end
    
    
%%
    ITIlicksSafe(i) = 0;
    for j = 1:length(stateTypeSafeInd)
        ITIlicksSafe(i) =  ITIlicksSafe(i) + sum([behSessionData(j).licksR > (behSessionData(j).CSon + 2500) behSessionData(j).licksL > (behSessionData(j).CSon + 2500)]);
    end
    ITIlicksSafe(i) = ITIlicksSafe(i)/length(stateTypeSafeInd);
    
    ITIlicksThreat(i) = 0;
    for j = 1:length(stateTypeThreatInd)
        ITIlicksThreat(i) =  ITIlicksThreat(i) + sum([behSessionData(j).licksR > (behSessionData(j).CSon + 2500) behSessionData(j).licksL > (behSessionData(j).CSon + 2500)]);
    end
    ITIlicksThreat(i) = ITIlicksThreat(i)/length(stateTypeThreatInd);
    
%%
    %find model parameters
%     x = qLearning_fit2LR([dayList{i} '.asc']);
%     alphaNPE(i) = x.threeParams_twoLearnRates.bestParams(1);
%     alphaPPE(i) = x.threeParams_twoLearnRates.bestParams(2);
%     beta(i) = x.threeParams_twoLearnRates.bestParams(3);
    
end

probSwitchNoRwdCombSafe = sum(changeChoiceCombSafe(allRewardsCombSafe==0))/sum(allRewardsCombSafe==0);
probStayRwdCombSafe = 1 - (sum(changeChoiceCombSafe(allRewardsCombSafe==1))/sum(allRewardsCombSafe==1));

correctRateSafe = correctSafe/(correctSafe + incorrectSafe);
rewardRateSafe = sum(allRewardsBinCombSafe)/length(allRewardsBinCombSafe);
noRwdAvgSafe = nanmean(noRwdCombinedSafe);


correctRateThreat= correctThreat/(correctThreat + incorrectThreat);
rewardRateThreat = sum(allRewardsBinCombThreat)/length(allRewardsBinCombThreat);
noRwdAvgThreat = nanmean(noRwdCombinedThreat);

% behTbl = table(dayList, correctFraction', rewardFraction', avgDist', semDist', probSwitchNoRwd', probStayRwd', randChance', normSwitches', avgNoRwd', ITIlicks',...
%     'VariableNames', {'Session' 'Fraction_Correct' 'Fraction_Rewarded' 'Distance_Avg' 'Distance_SEM' 'Prob_Switch' 'Prob_Stay' 'pVal_Chance'... 
%     'Norm_Switches' 'No_Reward' 'ITI_Licks'});


behTbl = table(dayList, correctFractionSafe', correctFractionThreat',rewardFractionSafe', rewardFractionThreat',avgDistSafe', avgDistThreat',semDistSafe', semDistThreat',probSwitchNoRwdSafe', probSwitchNoRwdThreat',probStayRwdSafe', probStayRwdThreat',randChanceSafe', randChanceThreat',normSwitchesSafe', normSwitchesThreat', ITIlicksSafe',ITIlicksThreat',...
    'VariableNames', {'Session' 'Fraction_correct_safe' 'Fraction_correct_threat' 'Fraction_rewarded_safe' 'Fraction_rewarded_threat' 'Distance_avg_safe' 'Distance_avg_threat' 'Distance_SEM_safe' 'Distance_SEM_threat'  'probability_switchNoRwd_Safe' 'Probability_switchNoRwd_threat' 'Probability_stayRwd_safe' 'Probability_stayRwd_threat' 'P-val_chance,safe' 'P-val_chance,threat' ...
    'Norm_switches_safe' 'Norm_switches_threat' 'ITI_licks_safe' 'ITI_licks_threat'});



