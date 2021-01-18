function outputStruct = parseBehavioralDataAP(outputStruct, blockSwitch, blockProbs, stateSwitch)
[root, sep] = currComputer();
s = outputStruct.s;

% trials of appropriate types
CSplus_responseMask = ~isnan([s.rewardTime]);
CSplus_omitMask = contains({s.trialType}, 'CSplus') & isnan([s.rewardTime]);
CSplus_allMask = contains({s.trialType}, 'CSplus');
CSminus_allMask = contains({s.trialType}, 'CSminus');


responseInds = find(~isnan([s.rewardTime]));
omitInds = isnan([s.rewardTime]);
stateChangeInds = [1 (find(abs(diff([s(responseInds).stateType])) == 1) + 1) length(responseInds)];      
stateTypeOrig = [s.stateType];   
stateTypeCorrected = [s(responseInds).stateType];     
% combinedAllReward_R_ap = []; %2 is used as an indicator to RL models to reset Q values
% combinedAllReward_L_ap = [];
% combinedAllChoice_R_ap = [];
% combinedAllChoice_L_ap = [];
% combinedTimeBtwn_ap = [];
% combinedAllReward_R = []; %2 is used as an indicator to RL models to reset Q values
% combinedAllReward_L = [];
% combinedAllChoice_R = [];
% combinedAllChoice_L = [];
% combinedTimeBtwn = [];
correctedBlockSwitch =  blockSwitch ;
correctedOmitTrials = ~CSplus_responseMask;
% tempStateSwitch = stateSwitch;
tempBlockSwitch = blockSwitch;
for i = 2:length(blockSwitch)
    subVal = sum(correctedOmitTrials(tempBlockSwitch(i-1):tempBlockSwitch(i) - 1));
    correctedBlockSwitch(i:end) = correctedBlockSwitch(i:end) - subVal;
end

tempStateSwitch = stateSwitch;
for i = 2:length(stateSwitch)
    subVal = sum(omitInds(tempStateSwitch (i-1):tempStateSwitch(i)-1));
    stateSwitch(i:end) = stateSwitch(i:end) - subVal;
end

% reward, choice, and non-reward vectors
allR_R = [s(CSplus_responseMask).rewardR]; 
allR_L = [s(CSplus_responseMask).rewardL]; 
allC = NaN(1,length(s(CSplus_responseMask)));
allC(~isnan(allR_R)) = 1;
allC(~isnan(allR_L)) = -1;

allR_R(isnan(allR_R)) = 0; allR_R = logical(allR_R);
allR_L(isnan(allR_L)) = 0; allR_L = logical(allR_L);
allC_R = double(allC == 1); allC_R = logical(allC_R);
allC_L = double(allC == -1); allC_L = logical(allC_L);

allR = zeros(1,length(allC));
allR(allR_R) = 1;
allR(allR_L) = -1;

allNoR = zeros(1, length(allC));
allNoR(logical(allC_R)) = 1;
allNoR(logical(allC_L)) = -1;
allNoR(allR ~= 0) = 0;

rt = [s(CSplus_responseMask).rewardTime] - [s(CSplus_responseMask).CSon];
rt_z = rt;
rt_z(allC_R) = zscore(rt(allC_R));
rt_z(allC_L) = zscore(rt(allC_L));

% ITIs
allITI = [s.trialEnd] - [s.CSon];
allITI = [NaN allITI(1:end - 1)];
% feedbackITI; these ITIs are the time from choice (feedback) to next CSon (when decision is presumably made)
CSplus_responseInds = find(CSplus_responseMask);
feedbackITI = NaN(1, length(CSplus_responseInds));
for i = 1:length(CSplus_responseInds) - 1
    feedbackITI(i) = s(CSplus_responseInds(i + 1)).CSon - s(CSplus_responseInds(i)).rewardTime;
end
feedbackITI = [NaN feedbackITI(1:end - 1)];
% changes in choice
changeChoice = [false diff(allC) ~= 0];
changeHistogram = [];
changeHistogram_LtoR = [];
changeHistogram_RtoL = [];
for i = find(changeChoice == 1)
    if allC(i) == 1 % if a right lick
        temp = 0;
        goBack = 1;
        while (i - goBack > 0) && allC(i-goBack) == -1 && allR(i-goBack) == 0 % if previous trial was a L lick AND resulted in no reward
            temp = temp + 1;
            goBack = goBack + 1;
        end
        changeHistogram = [changeHistogram temp];
        changeHistogram_LtoR = [changeHistogram_LtoR temp];
    elseif allC(i) == -1 %if a left lick
        temp = 0;
        goBack = 1;
        while (i - goBack > 0) && allC(i-goBack) == 1 && allR(i-goBack) == 0 % if previous trial was a R lick AND resulted in no reward
            temp = temp + 1;
            goBack = goBack + 1;
        end
        changeHistogram = [changeHistogram temp];
        changeHistogram_RtoL = [changeHistogram_RtoL temp];
    end
end
% stay durations
Rstays = [];
Lstays = [];
tempR = 0; tempL = 0;
for i = 2:length(allC)
    if allC(i) == 1 % right choice 
        tempR = tempR + 1;
    elseif allC(i) == -1 % left choice
        tempL = tempL + 1;
    end
    if allC(i) == 1 && allC(i-1) == -1 % right and previous was left
        Lstays = [Lstays tempL];
        tempL = 0;
    elseif allC(i) == -1 && allC(i-1) == 1 % left and previous was right
        Rstays = [Rstays tempR];
        tempR = 0;
    end 
end
allStays = [Lstays Rstays];

%% Append to outputStruct
outputStruct.pd.CSplus_responseMask = CSplus_responseMask;
outputStruct.pd.CSplus_omitMask = CSplus_omitMask;
outputStruct.pd.CSplus_allMask = CSplus_allMask;
outputStruct.pd.CSminus_allMask = CSminus_allMask;
outputStruct.pd.allR = allR;
outputStruct.pd.allNoR = allNoR;
outputStruct.pd.allR_R = allR_R;
outputStruct.pd.allR_L = allR_L;
outputStruct.pd.allC = allC;
outputStruct.pd.allC_R = allC_R;
outputStruct.pd.allC_L = allC_L;
outputStruct.pd.allITI = allITI/1e3; % convert to seconds
outputStruct.pd.fbITI = feedbackITI/1e3; % convert to seconds
outputStruct.pd.rt = rt;
outputStruct.pd.rt_z = rt_z;
outputStruct.pd.changeChoice = changeChoice;
outputStruct.pd.changeHis = changeHistogram;
outputStruct.pd.change_LtoR = changeHistogram_LtoR;
outputStruct.pd.change_RtoL = changeHistogram_RtoL;
outputStruct.pd.allStays = allStays;
outputStruct.pd.lStays = Lstays;
outputStruct.pd.rStays = Rstays;
outputStruct.pd.bs_corrected = correctedBlockSwitch;
outputStruct.pd.stateSwitchCorreced = stateChangeInds;
outputStruct.pd.stateTypeCorrected = stateTypeCorrected;
% place the original block switch and block probs within pD 
outputStruct.pd.Originalbs = blockSwitch;
outputStruct.pd.Originalbp = blockProbs;  
outputStruct.pb.OriginalstateSwitch = tempStateSwitch;
outputStruct.pd.stateTypeOrig = stateTypeOrig;
        

%    for currT = 1:length(stateChangeInds)-1
% %         if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
%             if stateType(stateChangeInds(currT)) == 1
%                 combinedAllReward_R_ap = [combinedAllReward_R_ap 2 allReward_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)]; %2 is used as an indicator to RL models to reset Q values
%                 combinedAllReward_L_ap = [combinedAllReward_L_ap 2 allReward_L(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 combinedAllChoice_R_ap = [combinedAllChoice_R_ap 2 allChoice_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 combinedAllChoice_L_ap = [combinedAllChoice_L_ap 2 allChoice_L(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 combinedTimeBtwn_ap = [combinedTimeBtwn_ap 2 timeBtwn(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%             else
%                 combinedAllReward_R = [combinedAllReward_R 2 allReward_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)]; %2 is used as an indicator to RL models to reset Q values
%                 combinedAllReward_L = [combinedAllReward_L 2 allReward_L(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 combinedAllChoice_R = [combinedAllChoice_R 2 allChoice_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 combinedAllChoice_L = [combinedAllChoice_L 2 allChoice_L(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%                 combinedTimeBtwn = [combinedTimeBtwn 2 timeBtwn(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
%             end
%    end
%         
%% Convert to outputStruct
% outputStruct.stateType = 
% outputStruct.allReward_R = combinedAllReward_R;
% outputStruct.allReward_L = combinedAllReward_L;
% outputStruct.allChoice_R = combinedAllChoice_R;
% outputStruct.allChoice_L = combinedAllChoice_L;
% outputStruct.timeBtwn = combinedTimeBtwn;
% outputStruct.allReward_R = combinedAllReward_R_ap;
% outputStruct.allReward_L = combinedAllReward_L_ap;
% outputStruct.allChoice_R = combinedAllChoice_R_ap;
% outputStruct.allChoice_L = combinedAllChoice_L_ap;
% outputStruct.timeBtwn = combinedTimeBtwn;