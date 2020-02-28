function outputStruct = parseBehavioralDataAP(sessionData, blockSwitch)

responseInds = find(~isnan([sessionData.rewardTime]));
omitInds = isnan([sessionData.rewardTime]);
stateChangeInds = [1 (find(abs(diff([sessionData(responseInds).stateType])) == 1) + 1) length(responseInds)];      
stateType = [sessionData(responseInds).stateType];
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

% tempStateSwitch = stateSwitch;
tempBlockSwitch = blockSwitch;
for i = 2:length(blockSwitch)
    subVal = sum(omitInds(tempBlockSwitch(i-1):tempBlockSwitch(i)));
    blockSwitch(i:end) = blockSwitch(i:end) - subVal;
end
% for i = 2:length(stateSwitch)
%     subVal = sum(omitInds(tempStateSwitch(i-1):tempStateSwitch(i)));
%  
%     stateSwitch(i:end) = stateSwitch(i:end) - subVal;
% end

        allReward_R = [sessionData(responseInds).rewardR]; 
        allReward_L = [sessionData(responseInds).rewardL]; 
        allChoices = NaN(1,length(sessionData(responseInds)));
        allChoices(~isnan(allReward_R)) = 1;
        allChoices(~isnan(allReward_L)) = -1;

        allReward_R(isnan(allReward_R)) = 0;
        allReward_L(isnan(allReward_L)) = 0;
        allChoice_R = double(allChoices == 1);
        allChoice_L = double(allChoices == -1);

        allRewards = zeros(1,length(allChoices));
        allRewards(logical(allReward_R)) = 1;
        allRewards(logical(allReward_L)) = -1;

        timeBtwn = [[sessionData(2:end).rewardTime] - [sessionData(1:end-1).CSon]];
        timeBtwn(timeBtwn < 0 ) = 0;
        timeBtwn = [0 timeBtwn(~isnan(timeBtwn))/1000];
        
allReward_R = [sessionData(responseInds).rewardR]; 
allReward_L = [sessionData(responseInds).rewardL]; 
allChoices = NaN(1,length(sessionData(responseInds)));
allChoices(~isnan(allReward_R)) = 1;
allChoices(~isnan(allReward_L)) = -1;

allReward_R(isnan(allReward_R)) = 0;
allReward_L(isnan(allReward_L)) = 0;
allChoice_R = double(allChoices == 1);
allChoice_L = double(allChoices == -1);

allRewards = zeros(1,length(allChoices));
allRewards(logical(allReward_R)) = 1;
allRewards(logical(allReward_L)) = -1;

timeBtwn = [[sessionData(2:end).rewardTime] - [sessionData(1:end-1).CSon]];
timeBtwn(timeBtwn < 0 ) = 0;
timeBtwn = [0 timeBtwn(~isnan(timeBtwn))/1000];

%% Convert to outputStruct
outputStruct.responseInds = responseInds;
outputStruct.omitInds = omitInds;
outputStruct.blockSwitch = blockSwitch;
outputStruct.allRewards = allRewards;
outputStruct.allReward_R = allReward_R;
outputStruct.allReward_L = allReward_L;
outputStruct.allChoices = allChoices;
outputStruct.allChoice_R = allChoice_R;
outputStruct.allChoice_L = allChoice_L;
outputStruct.timeBtwn = timeBtwn;   
outputStruct.stateType = stateType;
        

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