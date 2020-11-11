function behAnalysis_opTraining(sessionName, coupledFlag, saveFigFlag)

if nargin < 3
    saveFigFlag = 1;
end

if nargin < 2
    coupledFlag = 0;
end

[root, sep] = currComputer();

[animalName, date] = strtok(sessionName, 'd'); 
animalName = animalName(2:end);
date = date(1:9);
sessionFolder = ['m' animalName date];

if isstrprop(sessionName(end), 'alpha')
    behSessionDataPath = [root animalName sep sessionFolder sep 'sortedTrainng' sep 'session ' sessionName(end) sep sessionName '_behSessionData_behav.mat'];
else
    behSessionDataPath = [root animalName sep sessionFolder sep 'sortedTraining' sep 'session' sep sessionName '_sessionData_behav.mat'];
end

if coupledFlag  
    if exist(behSessionDataPath,'file')
        load(behSessionDataPath);
        behSessionData = sessionData;
    else
        [behSessionData, blockSwitch, blockProbs] = generateSessionData_behav_operantMatchingTraining(sessionName);
    end
else
    if exist(behSessionDataPath,'file')
        load(behSessionDataPath)
%         behSessionData = sessionData;
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
if ~coupledFlag
    allProbsL = [behSessionData(responseInds).rewardProbL];
    allProbsR = [behSessionData(responseInds).rewardProbR];
end
    
if blockSwitch(end) == length(allChoices)
    blockSwitch = blockSwitch(1:end-1);
end


%% 
figure
set(gcf, 'Position', get(0,'Screensize'))
%%suptitle(sessionName)
title(sessionName);

%%
% subplot(6,8,[17:20 25:28]); hold on   %%probability of choice and reward plot
normKern = normpdf(-15:15,0,4);
normKern = normKern / sum(normKern);
% xVals = (1:(length(normKern) + length(allChoices) - 1)) - round(length(normKern)/2);
% plot(xVals, conv(allChoices,normKern)/max(conv(allChoices,normKern)),'k','linewidth',2);
% plot(xVals, conv(allRewards,normKern)/max(conv(allRewards,normKern)),'--','Color',[100 100 100]./255,'linewidth',2)
% xlabel('Trials')
% ylabel('<-- Left       Right -->')
% legend('Choices','Rewards')
% xlim([1 length(allChoice_R)])
% ylim([-1 1])
% 
% if coupledFlag
%     for i = 1:length(blockSwitch)
%         bs_loc = blockSwitch(i);
%         plot([bs_loc bs_loc],[-1 1],'--','linewidth',1,'Color',[30 144 255]./255)
%         text(bs_loc,1.04,num2str(blockProbs{i}));
%         set(text,'FontSize',3);
%     end
% else
%     for i = 1:length(blockSwitch)
%         bs_loc = blockSwitch(i);
%         plot([bs_loc bs_loc],[-1 1],'--','linewidth',1,'Color',[30 144 255]./255)
%         if rem(i,2) == 0
%             labelOffset = 1.12;
%         else
%             labelOffset = 1.04;
%         end
%         a = num2str(allProbsL(blockSwitch(i)+1));
%         b = '/';
%         c = num2str(allProbsR(blockSwitch(i)+1));
%         label = strcat(a,b,c);
%         text(bs_loc,labelOffset,label);
%         set(text,'FontSize',3);
%     end
% end
% text(0,1.12,'L/R');
% 

%% determine and plot lick latency distributions for each spout
lickLat = [];       lickRate = [];
lickLat_L = [];     lickRate_L = [];
lickLat_R = [];     lickRate_R = [];
lickLat_LAll = [];  lickLat_RAll = []; 
for i = 1:length(behSessionData)
    if ~isnan(behSessionData(i).rewardTime)
        if ~isempty(behSessionData(i).delayNlw)
            firstLick = min(behSessionData(i).rewardTime, behSessionData(i).delayNlw);
            lickLat = [lickLat firstLick - behSessionData(i).CSon]; %same vector as in opMD
        else
            lickLat = [lickLat behSessionData(i).rewardTime - behSessionData(i).CSon]; %same vector as in opMD
        end
        if ~isempty(behSessionData(i).licksL)
            lickLat_LAll = [lickLat_LAll behSessionData(i).licksL - behSessionData(i).CSon]; 
            lickLat_L = [lickLat_L min([behSessionData(i).licksL]) - behSessionData(i).CSon];
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
        elseif ~isempty(behSessionData(i).licksR)
            lickLat_RAll = [lickLat_RAll behSessionData(i).licksR - behSessionData(i).CSon];      %make single licks zeros for easier indexing
            lickLat_R = [lickLat_R min([behSessionData(i).licksR]) - behSessionData(i).CSon];
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
    elseif ~isempty(behSessionData(i).delayNlw) 
            firstLick = behSessionData(i).delayNlw;
            lickLat = [lickLat firstLick - behSessionData(i).CSon]; %same vector as in opMD
            if ~isnan(behSessionData(i).licksL)
                lickLat_LAll = [lickLat_LAll behSessionData(i).licksL - behSessionData(i).CSon]; 
                lickLat_L = [lickLat_L min([behSessionData(i).licksL]) - behSessionData(i).CSon];
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
          elseif ~isnan(behSessionData(i).licksR)
                lickLat_RAll = [lickLat_RAll behSessionData(i).licksR - behSessionData(i).CSon];      %make single licks zeros for easier indexing
                lickLat_R = [lickLat_R min([behSessionData(i).licksR]) - behSessionData(i).CSon];      %make single licks zeros for easier indexing
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

subplot(6,8,[21 22]); hold on
histogram(lickLat_L, 0:50:1500,'Normalization','probability', 'FaceColor', 'm'); histogram(lickLat_R,0:50:1500,'Normalization','probability', 'FaceColor', 'c')
legend('Left Licks','Right Licks')
xlabel('Lick Latency (ms)');
title('first lick, all licks');

subplot(6,8,[17:20 25:28]); hold on 
histogram(lickLat_LAll,-6000:50:1500,'Normalization','probability', 'FaceColor', 'm'); histogram(lickLat_RAll,-6000:50:1500,'Normalization','probability', 'FaceColor', 'c')
legend('Left Licks','Right Licks')
xlabel('Lick Latency (ms)');
title('all licks, all licks');


%% Z-scored lick latency analysis

responseInd = find((isnan([behSessionData.rewardTime])));
str = sprintf('%f,', behSessionData.delayNlw);
values = textscan(str, '%f', 'delimiter', ',', 'EmptyValue', NaN);
responseIndnlw = find(~isnan(values{1,:}));
respondseIndnoNan1 = find(~isnan([behSessionData.rewardTime]));
responseIndnlw = transpose(responseIndnlw);
respondseIndnoNan = [respondseIndnoNan1 responseIndnlw];
respondseIndnoNan = unique(respondseIndnoNan,'first');
respondseIndnoNan = sort(respondseIndnoNan);


lickLatResp = lickLat;                   %remove NaNs from lickLat array
% lickLatInds = find(lickLatResp > 250);   
lickLatResp = lickLatResp(2:end);                       %shift for comparison to rwd history
lickLatInds = find(lickLatResp);                  %find indices of non-preemptive licks (limit to normal distribution): different values with opMD but same size of vectos. 

if ~isnan(behSessionData(responseInds(1)).rewardR)      %remove first response for shift to compare to rwd hist
    responseLat_R = lickLat_R(2:end);
    responseLat_L = lickLat_L; %same values between this nd opMD
else
    responseLat_R = lickLat_R;
    responseLat_L = lickLat_L(2:end);
end

% responseLat_R = responseLat_R(responseLat_R > 250);        %remove lick latencies outside of normal distribution
% responseLat_L = responseLat_L(responseLat_L > 250);
% responseLat_R  = zscore(responseLat_R);                   %get z scores for lick latencies based on spout side average
% responseLat_L  = zscore(responseLat_L);
% choicesLick = allChoices(respondseIndnoNan);
% choicesLick = choicesLick(2:end);                        %make shifted choice array without preemptive licks
% choicesLick = choicesLick(lickLatInds);%this vector becomes identical with opMd because in oth they're picking over 250, 

L = 1;
R = 1;
for j = 1:length(respondseIndnoNan)                   %put z scored lick latencies back in trial order
    if ~isempty([behSessionData(respondseIndnoNan(j)).licksR])
        if ~isempty([behSessionData(respondseIndnoNan(j)).licksL])
            tempR = min([behSessionData(respondseIndnoNan(j)).licksR]);
            tempL = min([behSessionData(respondseIndnoNan(j)).licksL]);
            responseLat(L) = min(tempR,tempL);
            L = L +1;
        else
            tempR = min([behSessionData(respondseIndnoNan(j)).licksR]);
            responseLat(L) = tempR;
            L = L +1;
        end
    elseif ~isempty([behSessionData(respondseIndnoNan(j)).licksL])    
        responseLat(L) = min([behSessionData(respondseIndnoNan(j)).licksL]);
        L = L +1;
    end
end

respRange = minmax(responseLat);
if -respRange(1,1) > respRange(1,2)
    normRespLat = responseLat / -respRange(1,1);
else
    normRespLat = responseLat / respRange(1,2);
end

subplot(6,8,[33:36 41:44]); hold on;
histogram(responseLat_L,0:50:1500,'Normalization','probability', 'FaceColor', 'm'); histogram(responseLat_R,0:50:1500,'Normalization','probability', 'FaceColor', 'c')
legend('Left Licks','Right Licks')
xlabel('Lick Latency (ms)');
title('responded licks, response');

%% Plot Raw Data

rMag = 1;
nrMag = rMag/2;

% trial plot
subplot(6,8,[1:8]); hold on
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
            plot([i i],[rMag 0],'--r','linewidth',1)
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
        plot([i i],[-1*nrMag 0],'g', 'linewidth',3)
    elseif (~isnan(behSessionData(i).ManulWaterR)) 
        plot([i i],[0 nrMag],'g', 'linewidth',3)
    end
end

if coupledFlag
    for i = 1:length(blockSwitch)
        bs_loc = origBlockSwitch(i);
        plot([bs_loc bs_loc],[-1 1],'--','linewidth',1,'Color',[30 144 255]./255)
        text(bs_loc,1.12,blockProbs{i});
        set(text,'FontSize',3);
    end
else
    for i = 1:length(blockSwitch)
        bs_loc = origBlockSwitch(i);
        plot([bs_loc bs_loc],[-1 1],'--r','linewidth',1,'Color',[30 144 255]./255)
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

% time plot
subplot(6,8,[9:16]); hold on
xlabel('Time (min)')
j = 1;
for i = 1:length(behSessionData)
    currTime = (behSessionData(i).CSon - behSessionData(1).CSon)/1000/60; %convert to min
    if strcmp(behSessionData(i).trialType,'CSplus')
        if ~isnan(behSessionData(i).rewardR)
            if behSessionData(i).rewardR == 1 % R side rewarded
                plot([currTime currTime],[0 rMag],'k')
            else
                plot([currTime currTime],[0 nrMag],'k') % R side not rewarded
            end
        elseif ~isnan(behSessionData(i).rewardL)
            if behSessionData(i).rewardL == 1 % L side rewarded
                plot([currTime currTime],[-1*rMag 0],'k')
            else
                plot([currTime currTime],[-1*nrMag 0],'k')
            end
            
        else % CSplus trial but no rewardL or rewardR
            plot([currTime currTime],[-rMag 0],'r')
        end
    else % CS minus trial
        plot([currTime currTime],0,'ko','markersize',4,'linewidth',2)
    end
    if any(i == origBlockSwitch)
        plot([currTime currTime],[-1*rMag rMag],'--','linewidth',1,'Color',[30 144 255]./255)
    end
%     if i > responseInds(1) & lickLat(i) > 250 & ~isnan(lickLat(i))
%         plot([currTime currTime], [0 normRespLat(j)], '-', 'Color', [0.85 0.325 0.098])
%         j = j + 1;
%     end
    if (~isnan(behSessionData(i).ManulWaterL))
        plot([currTime currTime],[-1*nrMag 0],'g','linewidth',3)
    elseif (~isnan(behSessionData(i).ManulWaterL)) 
        plot([currTime currTime],[0 nrMag],'g', 'linewidth',3)
    end
end
xlim([0 currTime]); 

%% linear regression model
origBlockSwitch1 = blockSwitch;
omitInds = isnan([behSessionData.rewardTime]); 
blockSwitch1 = blockSwitch;

tempBlockSwitch1 = blockSwitch1;
for i = 2:length(blockSwitch1)
    subVal1 = sum(omitInds(tempBlockSwitch1(i-1):tempBlockSwitch1(i)));
    blockSwitch1(i:end) = blockSwitch1(i:end) - subVal1;
end

allReward_R1 = [behSessionData(respondseIndnoNan1).rewardR]; 
allReward_L1 = [behSessionData(respondseIndnoNan1).rewardL];  
allChoices1 = NaN(1,length(behSessionData(respondseIndnoNan1))); 
allChoices1(~isnan(allReward_R1)) = 1;  %%gives values 1 or -1 to choice R or L respectively
allChoices1(~isnan(allReward_L1)) = -1;

allReward_R1(isnan(allReward_R1)) = 0;
allReward_L1(isnan(allReward_L1)) = 0;
allChoice_R1 = double(allChoices1 == 1);
allChoice_L1 = double(allChoices1 == -1);

allRewards1 = zeros(1,length(allChoices1));
allRewards1(logical(allReward_R1)) = 1; %%gives alues to reward R and L values 1 and -1 respectively
allRewards1(logical(allReward_L1)) = -1;

allITIs1 = [behSessionData(respondseIndnoNan1).trialEnd] - [behSessionData(respondseIndnoNan1).CSon];
if ~coupledFlag
    allProbsL1 = [behSessionData(respondseIndnoNan1).rewardProbL];
    allProbsR1 = [behSessionData(respondseIndnoNan1).rewardProbR];
end
    
if blockSwitch1(end) == length(allChoices1)
    blockSwitch1 = blockSwitch1(1:end-1);
end

tMax = 10;
rwdMatx = [];
for i = 1:tMax
    rwdMatx(i,:) = [NaN(1,i) allRewards1(1:end-i)];
end

allNoRewards1 = allChoices1;
allNoRewards1(allRewards1~=0) = 0;  %%gives value of 0 to trials w
noRwdMatx = [];
for i = 1:tMax
    noRwdMatx(i,:) = [NaN(1,i) allNoRewards1(1:end-i)];
end

glm_rwdANDnoRwd = fitglm([rwdMatx; noRwdMatx]', allChoice_R1, 'distribution','binomial','link','logit'); rsq = num2str(round(glm_rwdANDnoRwd.Rsquared.Adjusted*100)/100);

subplot(6,8,[39 40 47 48]); hold on
relevInds = 2:tMax+1;
coefVals = glm_rwdANDnoRwd.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_rwdANDnoRwd);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color','c','linewidth',2)

relevInds = tMax+2:length(glm_rwdANDnoRwd.Coefficients.Estimate);
coefVals = glm_rwdANDnoRwd.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_rwdANDnoRwd);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
errorbar((1:tMax)+0.2,coefVals,errorL,errorU,'Color','m','linewidth',2)
xlabel('Outcome n Trials Back')
ylabel('\beta Coefficient')
legend('rwd', [sprintf('\n%s\n%s%s',['no rwd'], ['R^2' rsq ' | '], ['Int: ' num2str(round(100*glm_rwdANDnoRwd.Coefficients.Estimate(1))/100)])], ...
       'location','northeast')
xlim([0.5 tMax+0.5])
plot([0 tMax],[0 0],'k--') 


%% exponential decay fit to beta values from linear regression
expFit = singleExpFit(glm_rwdANDnoRwd.Coefficients.Estimate(2:end));
expConv = expFit.a*exp(-(1/expFit.b)*(1:10));
expConv = expConv./sum(expConv);
                      
allRewardsBinary = allRewards1;                %make all rewards have the same value
allRewardsBinary(find(allRewards1 == -1)) = 1;
rwdHx = conv(allRewardsBinary,expConv);              %convolve with exponential decay to give weighted moving average
rwdHx = rwdHx(1:end-(length(expConv)-1));                   %to account for convolution padding



%% Consec no rewards before switch and time since last reward before switch
changeChoice = [false abs(diff(allChoices1)) > 0];
changeHistogram = [];
changeHistogram_LtoR = [];
changeHistogram_RtoL = [];
changeTimeHistogram_LtoR = [];
changeTimeHistogram_RtoL = [];
for i = find(changeChoice == 1)
    if allChoices(i) == 1 % if a right lick
        temp = 0;
        goBack = 1;
        while (i - goBack > 0) && allChoices1(i-goBack) == -1 && allRewards1(i-goBack) == 0 % if previous trial was a L lick AND resulted in no reward
            temp = temp + 1;
            goBack = goBack + 1;
        end
        changeHistogram = [changeHistogram temp];
        changeHistogram_LtoR = [changeHistogram_LtoR temp];
        if i - goBack > 0
            changeTimeHistogram_LtoR = [changeTimeHistogram_LtoR (behSessionData(respondseIndnoNan1(i)).CSon - behSessionData(respondseIndnoNan1(i-goBack)).rewardTime)];
        end
    elseif allChoices(i) == -1 %if a left lick
        temp = 0;
        goBack = 1;
        while (i - goBack > 0) && allChoices1(i-goBack) == 1 && allRewards1(i-goBack) == 0 % if previous trial was a R lick AND resulted in no reward
            temp = temp + 1;
            goBack = goBack + 1;
        end
        changeHistogram = [changeHistogram temp];
        changeHistogram_RtoL = [changeHistogram_RtoL temp];
        if i - goBack > 0
            changeTimeHistogram_RtoL = [changeTimeHistogram_RtoL (behSessionData(respondseIndnoNan1(i)).CSon - behSessionData(respondseIndnoNan1(i-goBack)).rewardTime)];
        end
    end
end

subplot(6,8,[31 32]); hold on;
histogram(changeHistogram_LtoR,0:max(changeHistogram), 'FaceColor', 'm')
histogram(changeHistogram_RtoL,0:max(changeHistogram), 'FaceColor', 'c')
legend('L -> R','R -> L')
xlabel('Consec No Rewards Before Switch')

changeTimeHistogram_LtoR = ceil(changeTimeHistogram_LtoR / 1000);
changeTimeHistogram_RtoL = ceil(changeTimeHistogram_RtoL / 1000);

subplot(6,8,[29 30]); hold on;
histogram(changeTimeHistogram_LtoR,0:10:(max([max(changeTimeHistogram_LtoR) max(changeTimeHistogram_RtoL)])+10), 'FaceColor', 'm')
histogram(changeTimeHistogram_RtoL,0:10:(max([max(changeTimeHistogram_LtoR) max(changeTimeHistogram_RtoL)])+10), 'FaceColor', 'c')
legend('L -> R','R -> L')
xlabel('Time Since Last Reward Before Switch')



%%
subplot(6,8,[23 24]);
stayDuration = diff([1 find(diff(allChoices1) ~= 0)]);
if ~isempty(stayDuration)
    histogram(stayDuration,1:max(stayDuration),'Normalization','probability', 'FaceColor', 'c')
    xl = xlim; yl = ylim;
    allRewardsBin = allRewards1;
    allRewardsBin(allRewards1==-1) = 1;
    changeChoice = changeChoice(2:end);
    probSwitchNoRwd = sum(changeChoice(allRewardsBin(1:end-1)==0))/sum(allRewardsBin(1:end-1)==0);
    probStayRwd = 1 - (sum(changeChoice(allRewardsBin(1:end-1)==1))/sum(allRewardsBin(1:end-1)==1));
    text('Position', [xl(2) yl(2) 0], 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'string', ...
        sprintf(['P(stay|rwd) = ' num2str(probStayRwd) '\nP(switch|no rwd) = ' num2str(probSwitchNoRwd)]));
end
xlabel('Stay Duration')


%%
cumsum_allRchoice = cumsum(allChoices1 == 1);
cumsum_allLchoice = cumsum(allChoices1 == -1);
cumsum_allRreward = cumsum(allRewards1 == 1);
cumsum_allLreward = cumsum(allRewards1 == -1);
cumsum_blockSwitch = cumsum_allLchoice(blockSwitch1);
if cumsum_blockSwitch(1) == 0
    cumsum_blockSwitch(1) = 1;
end

halfKern = normKern(round(length(normKern)/2):end);
choiceSlope = atand(diff(conv(cumsum_allRchoice,halfKern))./diff(conv(cumsum_allLchoice,halfKern)));
rwdSlope = atand(diff(conv(cumsum_allRreward,halfKern))./diff(conv(cumsum_allLreward,halfKern)));

subplot(6,8,[37 38 45 46]); hold on
plot(cumsum_allLchoice, cumsum_allRchoice,'linewidth',2,'Color',[30,144,255]/255);

avgRwdSlope = [];
tempMax = 0;
for i = 1:length(cumsum_blockSwitch)
    if i ~= length(cumsum_blockSwitch)
        avgRwdSlope(i) = tand(nanmean(rwdSlope(blockSwitch1(i):blockSwitch1(i+1))));
        xval = [cumsum_blockSwitch(i) cumsum_blockSwitch(i+1)];
        yval = [cumsum_blockSwitch(i) cumsum_blockSwitch(i+1)]*avgRwdSlope(i) - cumsum_blockSwitch(i)*avgRwdSlope(i) + cumsum_allRchoice(blockSwitch1(i));
        tempMax = yval(2);
        plot(xval, yval, 'k','linewidth',2);
    else
        avgRwdSlope(i) = tand(mean(rwdSlope(blockSwitch1(i):end)));
        xval = [cumsum_blockSwitch(i) cumsum_allLchoice(end)];
        yval = [cumsum_blockSwitch(i) cumsum_allLchoice(end)]*avgRwdSlope(i) - cumsum_blockSwitch(i)*avgRwdSlope(i) + cumsum_allRchoice(blockSwitch1(i));
        tempMax = yval(2);
        plot(xval, yval, 'k','linewidth',2);
    end
end
limMax = max([max(cumsum_allLchoice) max(cumsum_allRchoice)]);
xlim([0 limMax])
ylim([0 limMax])
legend('Choice','Income','location','best')
xlabel('Cumulative Left Choices'); ylabel('Cumulative Right Choices')

%%
% subplot(6,8,[33:36 41:44]); hold on;
% 
% plot(choiceSlope,'linewidth',1.5,'Color',[30,144,255]/255)
% plot(rwdSlope,'k','linewidth',1.5)
% for i = 1:length(avgRwdSlope)
%     if i ~= length(avgRwdSlope)
%         plot([blockSwitch1(i) blockSwitch1(i+1)], [mean(choiceSlope(blockSwitch1(i):blockSwitch1(i+1))) mean(choiceSlope(blockSwitch1(i):blockSwitch1(i+1)))],'linewidth',4,'Color',[30,144,255]/255);
%         plot([blockSwitch1(i) blockSwitch1(i+1)], [mean(rwdSlope(blockSwitch1(i):blockSwitch1(i+1))) mean(rwdSlope(blockSwitch1(i):blockSwitch1(i+1)))],'k','linewidth',4);
%     else
%         plot([blockSwitch1(i) length(choiceSlope)], [mean(choiceSlope(blockSwitch1(i):length(choiceSlope))) mean(choiceSlope(blockSwitch1(i):length(choiceSlope)))],'linewidth',4,'Color',[30,144,255]/255)
%         plot([blockSwitch1(i) length(rwdSlope)], [mean(rwdSlope(blockSwitch1(i):length(choiceSlope))) mean(rwdSlope(blockSwitch1(i):length(choiceSlope)))],'k','linewidth',4);
%     end
% end
% 
% xlim([1 length(allChoices1)])
% ylim([0 90])
% legend('Choice','Rewards')
% xlabel('Choice number')
% ylabel('Slope (degrees)')



%% save figure
savePath = [root animalName sep sessionFolder sep  'figuresTraining' sep];
if isempty(dir(savePath))
    mkdir(savePath)
end

if saveFigFlag == 1
    saveFigurePDF(gcf,[savePath sessionName '_behavior'])
end


%%
% figure   %make new lick behavior analysis figure
% set(gcf, 'Position', get(0,'Screensize'))
% title(sessionName)


% %% lick latency and recent rwd hist analysis
% 
% timeMax = 61000;
% binSize = 10000;
% timeBinEdges = [1000:binSize:timeMax];  %no trials shorter than 1s between outcome and CS on
% tMax = length(timeBinEdges) - 1;
% rwdTimeMatx = zeros(tMax, length(respondseIndnoNan1));     %initialize matrices for number of response trials x number of time bins
% for j = 2:length(respondseIndnoNan1)          
%     k = 1;
%     %find time between "current" choice and previous rewards, up to timeMax in the past 
%     timeTmp = []; timeTmpN =[];
%     while j-k > 0 & behSessionData(respondseIndnoNan1(j)).rewardTime - behSessionData(respondseIndnoNan1(j-k)).rewardTime < timeMax
%         if behSessionData(respondseIndnoNan1(j-k)).rewardL == 1 || behSessionData(respondseIndnoNan1(j-k)).rewardR == 1
%             timeTmp = [timeTmp (behSessionData(respondseIndnoNan1(j)).rewardTime - behSessionData(respondseIndnoNan1(j-k)).rewardTime)];
%         end
%         k = k + 1;
%     end
%     %bin outcome times and use to fill matrices
%     if ~isempty(timeTmp)
%         binnedRwds = discretize(timeTmp,timeBinEdges);
%         for k = 1:tMax
%             if ~isempty(find(binnedRwds == k))
%                 rwdTimeMatx(k,j) = sum(binnedRwds == k);
%             end
%         end
%     end
% end
% 
% %fill in NaNs at beginning of session
% j = 2;
% while behSessionData(respondseIndnoNan1(j)).rewardTime - behSessionData(respondseIndnoNan1(1)).rewardTime < timeMax
%     tmpDiff = behSessionData(respondseIndnoNan1(j)).rewardTime - behSessionData(respondseIndnoNan1(1)).rewardTime;
%     binnedDiff = discretize(tmpDiff, timeBinEdges);
%     rwdTimeMatx(binnedDiff:tMax,j) = NaN;
%     j = j+1;
% end
% 
% rwdTimeMatx(:,1) = NaN;
% glm_rwdLickLat = fitlm([rwdTimeMatx(:,lickLatInd)]', responseLat);                 
% glm_rwdLickRate = fitlm([rwdTimeMatx(:,logical(allRewardsBin))]', lickRate);
% 
% %plot beta coefficients from lrm's
% subplot(4,2,1); hold on;
% relevInds = 2:tMax+1;
% coefVals = glm_rwdLickLat.Coefficients.Estimate(relevInds);
% CIbands = coefCI(glm_rwdLickLat);
% errorL = abs(coefVals - CIbands(relevInds,1));
% errorU = abs(coefVals - CIbands(relevInds,2));
% errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)
% 
% plot([0 (tMax*binSize/1000 + 5)],[0 0],'k--')
% xlabel('reward n seconds back')
% ylabel('\beta Coefficient')
% xlim([0 (tMax*binSize/1000 + 5)])
% title('LRM: rewards in time on lick latency')
% 
% subplot(4,2,2); hold on;
% coefVals = glm_rwdLickRate.Coefficients.Estimate(relevInds);
% CIbands = coefCI(glm_rwdLickRate);
% errorL = abs(coefVals - CIbands(relevInds,1));
% errorU = abs(coefVals - CIbands(relevInds,2));
% errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'Color', [0.7 0 1],'linewidth',2)
% 
% plot([0 (tMax*binSize/1000 + 5)],[0 0],'k--')
% xlabel('reward n seconds back')
% ylabel('\beta Coefficient')
% xlim([0 (tMax*binSize/1000 + 5)])
% title('LRM: rewards in time on lick rate')
% 
% %plot reward history smoothed with kernel derived from beta coefficients (licks) v lick behavior 
% purp = [0.5 0 0.8];
% blue = [0 0 1];
% set(gcf,'defaultAxesColorOrder',[blue; purp]);
% 
% rwdsSmooth = fastsmooth(allRewardsBin, 5, 3);
% 
% subplot(4,2,3)
% yyaxis left; plot(rwdsSmooth(lickLatInds), 'b'); hold on
% ylabel('Reward History (from lick LRM)')
% yyaxis right; plot(fastsmooth(responseLat,5,3),'-','Color', purp);
% ylabel('Response Latency Z-Score')
% xlabel('Choice Trials')
% 
% 
% subplot(4,2,4)
% yyaxis left; plot(rwdsSmooth(logical(allRewardsBin)), 'b'); hold on
% ylabel('Reward History (from lick LRM)')
% yyaxis right; plot(fastsmooth(lickRate,5,3),'-','Color', purp);
% ylabel('Peak Lick Rate Z-Score')
% xlabel('Rewarded Trials')
% 
% %plot scatters for reward history smoothed with kernel derived from beta coefficients (choices) v lick behavior  
% expFit = singleExpFit(glm_rwdANDnoRwd.Coefficients.Estimate(2:end));
% expConv = expFit.a*exp(-(1/expFit.b)*(1:10));
% expConv = expConv./sum(expConv);
% rwdHx = conv(allRewardsBin,expConv);
% rwdHx = rwdHx(1:end-(length(expConv)-1)); 
% 
% rwdHxLick = rwdHx(lickLatInds);                   %remove preemptive lick trials from rwd hist
% 
% coeffs = polyfit(rwdHxLick, responseLat, 1);
% fittedX = linspace(0, 1, 200);
% fittedY = polyval(coeffs, fittedX);
% mdl = fitlm(rwdHxLick, responseLat);
% rSqr = mdl.Rsquared(1).Ordinary(1);
% 
% purp = [0.5 0 0.8];
% blue = [0 0 1];
% set(gcf,'defaultAxesColorOrder',[blue; purp]);
% 
% subplot(4,2,5)
% scatter(rwdHxLick, responseLat,'b'); hold on
% ylabel('Lick Latency Z Score')
% xlabel('Reward History (from choice LRM)')
% plot(fittedX, fittedY, '-','Color', purp, 'LineWidth', 3);
% legend('Licks', sprintf(['R^2: ' num2str(rSqr)]))
% 
% %
% rewardsLick = allRewards(allRewards == 1 | allRewards == -1);
% if behSessionData(respondseIndnoNan1(1)).rewardR == 1      %remove first response for shift to compare to rwd hist
%     responseRate_R = lickRate_R(2:end);
%     responseRate_L = lickRate_L;
%     responseRate = lickRate(2:end);
%     responseRateInds = find(lickRate(2:end) < 15);
%     rewardsLick = rewardsLick(2:end);
% elseif behSessionData(respondseIndnoNan1(1)).rewardL == 1 
%     responseRate_R = lickRate_R;
%     responseRate_L = lickRate_L(2:end);
%     responseRate = lickRate(2:end);
%     responseRateInds = find(lickRate(2:end) < 15);
%     rewardsLick = rewardsLick(2:end);
% else
%     responseRate_R = lickRate_R;
%     responseRate_L = lickRate_L;
%     responseRate = lickRate;
%     responseRateInds = find(lickRate < 15);
% end
% 
% 
% responseRate = responseRate(responseRate < 15);
% responseRate_R = responseRate_R(responseRate_R < 15);
% responseRate_L = responseRate_L(responseRate_L < 15);
% responseRate_R = zscore(responseRate_R);
% responseRate_L = zscore(responseRate_L);
% rewardsLick = rewardsLick(responseRateInds);
% 
% L = 1;
% R = 1;
% for j = 1:length(rewardsLick)                     %put z scored lick rates back in trial order
%     if rewardsLick(j) == 1
%         responseRate(j) = responseRate_R(R);
%         R = R + 1;
%     elseif rewardsLick(j) == -1
%         responseRate(j) = responseRate_L(L);
%         L = L + 1;
%     end
% end
% 
% 
% binAllRewards = logical(allRewards == 1 | allRewards == -1);
% rwdHxRwd = rwdHx(binAllRewards(2:end)==1);
% rwdHxRwd = rwdHxRwd(responseRateInds);
% 
% 
% coeffs2 = polyfit(rwdHxRwd, responseRate, 1);
% fittedY2 = polyval(coeffs2, fittedX);
% mdl2 = fitlm(rwdHxRwd, responseRate);
% rSqr2 = mdl2.Rsquared(1).Ordinary(1);
% 
% subplot(4,2,6)
% scatter(rwdHxRwd, responseRate, 'b'); hold on;
% xlabel('Reward History (from choice LRM)')
% ylabel('Peak Lick Rate Z-Score')
% plot(fittedX, fittedY2, '-','Color', purp, 'LineWidth', 3);
% legend('Licks', sprintf(['R^2: ' num2str(rSqr2)]))
% 
% 
% subplot(4,2,7)
% yyaxis left; plot(fastsmooth(rwdHxLick, 5, 3), 'b'); hold on
% ylabel('Reward History (from choice LRM)')
% yyaxis right; plot(fastsmooth(responseLat,5,3),'-','Color', purp);
% ylabel('Response Latency Z-Score')
% xlabel('Choice Trials')
% 
% subplot(4,2,8)
% yyaxis left; plot(fastsmooth(rwdHxRwd, 5, 3), 'b'); hold on
% ylabel('Reward History (from choice LRM)')
% yyaxis right; plot(fastsmooth(responseRate,5,3),'-','Color', purp);
% ylabel('Peak Lick Rate Z-Score')
% xlabel('Rewarded Trials')
% 
% 
% % savePath = [root animalName sep sessionFolder sep  'figures' sep];
% % if isempty(dir(savePath))
% %     mkdir(savePath)
% % end
% 
% % if saveFigFlag == 1
% %     saveFigurePDF(gcf,[savePath sep sessionName '_lickBehavior'])
% % end