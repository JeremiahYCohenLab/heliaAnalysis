function multipleDaysTraining(xlFile, animal, category, session, daysBack, revForFlag)

if nargin < 6
    revForFlag = 0;
end
 
[root, sep] = currComputer();

[weights, dayList, ~] = xlsread(xlFile, animal);
[~,col] = find(~cellfun(@isempty,strfind(dayList, category)) == 1);
dayList = dayList(2:end,col);
endInd = find(cellfun(@isempty,dayList),1);
if ~isempty(endInd)
% % find(~cellfun(@isempty,strfind(dayList(:,col), session)) == 1)
    dayList = dayList(endInd-daysBack:endInd-1,:);
%     dayList = dayList(1:endInd-1,:);
else
    dayList = dayList(end-daysBack:end,:);
end
figure;
set(gcf, 'Position', get(0,'Screensize'));
t = title(category);
% ax = gca;
% ax.TitleHorizontalAlignment = 'center';

for d = 1: length(dayList)
    sessionName = dayList{d};
    [animalName, date] = strtok(sessionName, 'd'); 
    animalName = animal;
%     date = date(1:9);
    sessionFolder = ['m' animalName date];
    if isstrprop(sessionName(end), 'alpha')
        behSessionDataPath = [root animalName sep sessionFolder sep 'sortedTraining' sep 'session ' sessionName(end) sep sessionName '_behSessionData_behavTraining.mat'];
    else
        behSessionDataPath = [root animalName sep sessionFolder sep 'sortedTraining' sep 'session' sep sessionName '_sessionDataTraining_behav.mat'];
    end

    if revForFlag  
        if exist(behSessionDataPath,'file')
            load(behSessionDataPath);
            behSessionData = sessionData;
        else
            [behSessionData, blockSwitch, blockProbs] = generateSessionData_behav_operantMatchingTraining(sessionName);
        end
    else
        if exist(behSessionDataPath,'file')
            load(behSessionDataPath);
            behSessionData = sessionData;
        else
            [behSessionData, blockSwitch, blockSwitchL, blockSwitchR] = generateSessionData_operantMatchingDecoupledTraining(sessionName);
        end
    end
    
    
    %% using all the trials for trianing progress observation

    responseInds = find([behSessionData.rewardTime]); % find CS+ trials with a response in the lick window%%response or correct response?
    origBlockSwitch = blockSwitch;

    allReward_R = [behSessionData(responseInds).rewardR]; 
    allReward_L = [behSessionData(responseInds).rewardL];  
    allChoices = NaN(1,length(behSessionData(responseInds))); 
    allChoices(~isnan(allReward_R)) = 1;  %%gives values 1 or -1 to choice R or L respectively
    allChoices(~isnan(allReward_L)) = -1;

    allReward_R(isnan(allReward_R)) = 0;
    allReward_L(isnan(allReward_L)) = 0;
    allChoice_R = double(allChoices == 1);
    allChoice_L = double(allChoices == -1);

    allRewards = zeros(1,length(allChoices));
    allRewards(logical(allReward_R)) = 1; %%gives alues to reward R and L values 1 and -1 respectively
    allRewards(logical(allReward_L)) = -1;

    allITIs = [behSessionData(responseInds).trialEnd] - [behSessionData(responseInds).CSon];
    if ~revForFlag
        allProbsL = [behSessionData(responseInds).rewardProbL];
        allProbsR = [behSessionData(responseInds).rewardProbR];
    end

    if blockSwitch(end) == length(allChoices)
        blockSwitch = blockSwitch(1:end-1);
    end
    %% determine and plot lick latency distributions for each spout
lickLat = [];       lickRate = [];
lickLat_L = [];     lickRate_L = [];
lickLat_R = [];     lickRate_R = [];
for i = 1:length(behSessionData)
    if ~isempty(behSessionData(i).rewardTime)
        lickLat = [lickLat behSessionData(i).rewardTime - behSessionData(i).CSon];
        if ~isnan(behSessionData(i).rewardL)
            lickLat_L = [lickLat_L behSessionData(i).rewardTime - behSessionData(i).CSon];
            if behSessionData(i).rewardL == 1
                if length(behSessionData(i).licksL) > 1
                    lickRateTemp = 1000/(min(diff(behSessionData(i).licksL)));  %%each trial has a lick latency
                    lickRate = [lickRate lickRateTemp];
                    lickRate_L = [lickRate_L lickRateTemp];
                else
                   lickRate = [lickRate 0];
                   lickRate_L = [lickRate_L 0]; 
                end
            end
        elseif ~isnan(behSessionData(i).rewardR)
            lickLat_R = [lickLat_R behSessionData(i).rewardTime - behSessionData(i).CSon];      %make single licks zeros for easier indexing
            if behSessionData(i).rewardR == 1
                if length(behSessionData(i).licksR) > 1
                    lickRateTemp = 1000/(min(diff(behSessionData(i).licksR)));
                    lickRate = [lickRate lickRateTemp];
                    lickRate_R = [lickRate_R lickRateTemp];
                else
                    lickRate = [lickRate 0];
                    lickRate_R = [lickRate_R 0];
                end
            end
        end
    end
end
    subplot(daysBack+1,5,5*d); hold on
    title([sessionName category]);
    histogram(lickLat_L,0:50:1500,'Normalization','probability', 'FaceColor', 'm'); histogram(lickLat_R,0:50:1500,'Normalization','probability', 'FaceColor', 'c')
    legend('Left Licks','Right Licks')
    xlabel('Lick Latency (ms)')
    %% Z-scored lick latency analysis
responseInd = find(~isnan([behSessionData.rewardTime])); % find CS+ trials with a response in the lick window%%response or correct response?
omitInds = isnan([behSessionData.rewardTime]); 

blockSwitch2 = blockSwitch;
origBlockSwitch = blockSwitch;
tempBlockSwitch = blockSwitch;
for i = 2:length(blockSwitch)
    subVal = sum(omitInds(tempBlockSwitch(i-1):tempBlockSwitch(i)));
    blockSwitch2(i:end) = blockSwitch(i:end) - subVal;
end

allReward_R2 = [behSessionData(responseInd).rewardR]; 
allReward_L2 = [behSessionData(responseInd).rewardL];  
allChoices2 = NaN(1,length(behSessionData(responseInd))); 
allChoices2(~isnan(allReward_R2)) = 1;  %%gives values 1 or -1 to choice R or L respectively
allChoices2(~isnan(allReward_L2)) = -1;

allReward_R2(isnan(allReward_R2)) = 0;
allReward_L2(isnan(allReward_L2)) = 0;
allChoice_R2 = double(allChoices2 == 1);
allChoice_L2 = double(allChoices2 == -1);

allRewards2 = zeros(1,length(allChoices2));
allRewards2(logical(allReward_R2)) = 1; %%gives alues to reward R and L values 1 and -1 respectively
allRewards2(logical(allReward_L2)) = -1;

lickLatResp = lickLat(responseInd);                    %remove NaNs from lickLat array
lickLatResp = lickLatResp(2:end);                       %shift for comparison to rwd history
lickLatInds = find(lickLatResp > 250);                  %find indices of non-preemptive licks (limit to normal distribution)

if ~isnan(behSessionData(responseInd(1)).rewardR)      %remove first response for shift to compare to rwd hist
    responseLat_R = lickLat_R(2:end);
    responseLat_L = lickLat_L;
else
    responseLat_R = lickLat_R;
    responseLat_L = lickLat_L(2:end);
end

responseLat_R = responseLat_R(responseLat_R > 250);        %remove lick latencies outside of normal distribution
responseLat_L = responseLat_L(responseLat_L > 250);
responseLat_R  = zscore(responseLat_R);                   %get z scores for lick latencies based on spout side average
responseLat_L  = zscore(responseLat_L);
choicesLick = allChoices2(2:end);                        %make shifted choice array without preemptive licks
choicesLick = choicesLick(lickLatInds);

L = 1;
R = 1;
for j = 1:length(choicesLick)                     %put z scored lick latencies back in trial order
    if choicesLick(j) == 1
        responseLat(j) = responseLat_R(R);
        R = R + 1;
    else
        responseLat(j) = responseLat_L(L);
        L = L + 1;
    end
end

respRange = minmax(responseLat);
if -respRange(1,1) > respRange(1,2)
    normRespLat = responseLat / -respRange(1,1);
else
    normRespLat = responseLat / respRange(1,2);
end

    %% Plot Raw Data

    rMag = 1;
    nrMag = rMag/2;
    nqrMag = rMag/4;

    % trial plot
    
    subplot(daysBack+1,5,[((5*d)-4) ((5*d)-1)]); hold on
    normKern = normpdf(-15:15,0,4);
    normKern = normKern / sum(normKern);
    smoothRew = conv(allRewards,normKern)/max(conv(allRewards,normKern));
    kernShift = (length(normKern) - 1)/2;
    smoothRew = smoothRew(kernShift:(length(smoothRew)-kernShift));
    smoothRewGaps = [];

    j = 1;
    for i = 1:length(behSessionData)
        if strcmp(behSessionData(i).trialType,'CSplus')
            if ~isnan(behSessionData(i).rewardR)
                if behSessionData(i).rewardR == 1 % R side rewarded
                    plot([i i],[0 rMag],'k')
                else
                    plot([i i],[0 nrMag],'k') % R side not rewarded
                end
            elseif ~isnan(behSessionData(i).rewardL)
                if behSessionData(i).rewardL == 1 % L side rewarded
                    plot([i i],[-1*rMag 0],'k')
                else
                    plot([i i],[-1*nrMag 0],'k')
                end
            else
                plot([i i],[-rMag 0],'r');  
            end
             % CSplus trial but no rewardL or rewardR
            if (~isempty(behSessionData(i).delayNlw))
                plot([i i],[nqrMag 0],'--r','linewidth',1)
  %%when animal does not lick or licks in delay so many times thaty it moves to next trial

            end
        else % CS minus trial
            plot([i],0,'ko','markersize',4,'linewidth',2)
        end
        if any(i == origBlockSwitch)
            plot([i i],[-1*rMag rMag],'--','linewidth',1,'Color',[30 144 255]./255)
        end
    %     if i > responseInds(1) & lickLat(i) > 250 & ~isnan(lickLat(i))
    %         plot([i i], [0 normRepLat(j)], '-', 'Color', [0.85 0.325 0.098])
    %         j = j + 1;
    %     end
        if (~isnan(behSessionData(i).ManulWaterL))
            plot([i i],[-1*nrMag 0],'g', 'linewidth',4)
        elseif (~isnan(behSessionData(i).ManulWaterR)) 
            plot([i i],[0 nrMag],'g', 'linewidth',4)
        end
%         if (~isempty(behSessionData(i).delayNlw))
%             plot([i i],[rMag 0],'--r', 'linewidth',1)
%         end
    end

    if revForFlag
        for i = 1:length(blockSwitch)
            bs_loc = origBlockSwitch(i);
            plot([bs_loc bs_loc],[-1 1],'--','linewidth',1,'Color',[30 144 255]./255)
            text(bs_loc,1.12,blockProbs{i});
            set(text,'FontSize',3);
        end
    else
        for i = 1:length(blockSwitch)
            bs_loc = origBlockSwitch(i);
            plot([bs_loc bs_loc],[-1 1],'--','linewidth',1,'Color',[30 144 255]./255)
            if rem(i,2) == 0
                labelOffset = 1.12;
            else
                labelOffset = 1.28;
            end
            a = num2str(allProbsL(blockSwitch(i)+1));
            b = '/';
            c = num2str(allProbsR(blockSwitch(i)+1));
            label = strcat(a,b,c);
            text(bs_loc,labelOffset,label);
            set(text,'FontSize',3);
        end
    end
    text(0,1.5,'L/R');
    ylabel('<-- L       R  -->')
%     % time plot
%     subplot(6,8,[9:16]); hold on
%     xlabel('Time (min)')
%     j = 1;
%     for i = 1:length(behSessionData)
%         currTime = (behSessionData(i).CSon - behSessionData(1).CSon)/1000/60; %convert to min
%         if strcmp(behSessionData(i).trialType,'CSplus')
%             if ~isnan(behSessionData(i).rewardR)
%                 if behSessionData(i).rewardR == 1 % R side rewarded
%                     plot([currTime currTime],[0 rMag],'k')
%                 else
%                     plot([currTime currTime],[0 nrMag],'k') % R side not rewarded
%                 end
%             elseif ~isnan(behSessionData(i).rewardL)
%                 if behSessionData(i).rewardL == 1 % L side rewarded
%                     plot([currTime currTime],[-1*rMag 0],'k')
%                 else
%                     plot([currTime currTime],[-1*nrMag 0],'k')
%                 end
% 
%             else % CSplus trial but no rewardL or rewardR
%                 plot([currTime currTime],[-rMag rMag],'r')
%             end
%         else % CS minus trial
%             plot([currTime currTime],0,'ko','markersize',4,'linewidth',2)
%         end
%         if any(i == origBlockSwitch)
%             plot([currTime currTime],[-1*rMag rMag],'--','linewidth',1,'Color',[30 144 255]./255)
%         end
%     %     if i > responseInds(1) & lickLat(i) > 250 & ~isnan(lickLat(i))
%     %         plot([currTime currTime], [0 normRespLat(j)], '-', 'Color', [0.85 0.325 0.098])
%     %         j = j + 1;
%     %     end
%         if (~isnan(behSessionData(i).ManulWaterL))
%             plot([currTime currTime],[-1*nrMag 0],'g')
%         elseif (~isnan(behSessionData(i).ManulWaterL)) 
%             plot([currTime currTime],[0 rMag],'g')
%         end
%     end
%     xlim([0 currTime]); 
end
    savePath = [root animal sep 'training'];
    if isempty(dir(savePath))
        mkdir(savePath)
    end
    saveFigurePDF(gcf,[savePath sep session category '_sum']);