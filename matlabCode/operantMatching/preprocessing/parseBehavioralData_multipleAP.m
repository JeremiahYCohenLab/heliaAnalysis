function outputStruct = parseBehavioralData_multipleAP(xlFile, animal, category, revForFlag)

[root, sep] = currComputer();

[weights, dayList, ~] = xlsread(xlFile, animal);
[~,col] = find(~cellfun(@isempty,strfind(dayList, category)) == 1);
dayList = dayList(2:end,col);
endInd = find(cellfun(@isempty,dayList),1);
if ~isempty(endInd)
    dayList = dayList(1:endInd-1,:);
end
combinedAllReward_R_ap = [];
combinedAllReward_L_ap = [];
combinedAllChoice_R_ap = [];
combinedAllChoice_L_ap = [];
combinedTimeBtwn_ap = [];
combinedAllReward_R = [];
combinedAllReward_L = [];
combinedAllChoice_R = [];
combinedAllChoice_L = [];
combinedTimeBtwn = [];

for i = 1: length(dayList)
    sessionName = dayList{i};
    [animalName, date] = strtok(sessionName, 'd'); 
    animalName = animalName(2:end);
    date = date(1:9);
    sessionFolder = ['m' animalName date];

    if isstrprop(sessionName(end), 'alpha')
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session ' sessionName(end) sep sessionName '_sessionData_behav.mat'];
    else
        sessionDataPath = [root animalName sep sessionFolder sep 'sorted' sep 'session' sep sessionName '_sessionData_behav.mat'];
    end

    if exist(sessionDataPath,'file')
        load(sessionDataPath)
        if revForFlag
            behSessionData = sessionData;
        end
    elseif revForFlag                                    %otherwise generate the struct
        [behSessionData, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
    else
        [behSessionData, ~, ~, ~] = generateSessionData_operantMatchingDecoupled(sessionName);
    end
  
        responseInds = find(~isnan([behSessionData.rewardTime]));
        stateType = [behSessionData(responseInds).stateType];
        stateChangeInds = [1 (find(abs(diff([behSessionData(responseInds).stateType])) == 1) + 1) length(responseInds)];

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

            timeBtwn = [[behSessionData(2:end).rewardTime] - [behSessionData(1:end-1).CSon]];
            timeBtwn(timeBtwn < 0 ) = 0;
            timeBtwn = [0 timeBtwn(~isnan(timeBtwn))/1000];
         if(stateChangeInds(currT+1)-1 - stateChangeInds(currT) >= 12)
            if stateType(stateChangeInds(currT)) == 1
                combinedAllReward_R_ap = [combinedAllReward_R_ap 2 allReward_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)]; %2 is used as an indicator to RL models to reset Q values
                combinedAllReward_L_ap = [combinedAllReward_L_ap 2 allReward_L(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                combinedAllChoice_R_ap = [combinedAllChoice_R_ap 2 allChoice_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                combinedAllChoice_L_ap = [combinedAllChoice_L_ap 2 allChoice_L(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                combinedTimeBtwn_ap = [combinedTimeBtwn_ap 2 timeBtwn(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
            else
                combinedAllReward_R = [combinedAllReward_R 2 allReward_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)]; %2 is used as an indicator to RL models to reset Q values
                combinedAllReward_L = [combinedAllReward_L 2 allReward_L(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                combinedAllChoice_R = [combinedAllChoice_R 2 allChoice_R(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                combinedAllChoice_L = [combinedAllChoice 2 allChoice_L(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
                combinedTimeBtwn = [combinedTimeBtwn 2 timeBtwn(stateChangeInds(currT):stateChangeInds(currT+1)-1)];
            end
         end
end

%% Convert to outputStruct
outputStruct.allReward_R_ap = combinedAllReward_R_ap;
outputStruct.allReward_L_ap = combinedAllReward_L_ap;
outputStruct.allChoice_R_ap = combinedAllChoice_R_ap;
outputStruct.allChoice_L_ap = combinedAllChoice_L_ap;
outputStruct.timeBtwn_ap = combinedTimeBtwn_ap;
outputStruct.allReward_R = combinedAllReward_R_ap;
outputStruct.allReward_L = combinedAllReward_L_ap;
outputStruct.allChoice_R = combinedAllChoice_R_ap;
outputStruct.allChoice_L = combinedAllChoice_L_ap;
outputStruct.timeBtwn = combinedTimeBtwn;

end