function [glm_rwdLickSafe, glm_rwdLickThreat] = compareLogRegLickStates_opMAP(file, animal, category, revForFlag, trialFlag)

if nargin < 5
    trialFlag = 0;
    revForFlag = 0;
end

%run function to generate lrm 
if trialFlag
    [glm_rwdLickSafe, safeStayLickLat, safeSwitchLickLat, tMax]= combineLogRegLickLatSafe_opMAP(file, animal, category, 'revForFlag', revForFlag);
    [glm_rwdLickThreat, threatStayLickLat, threatSwitchLickLat, ~]= combineLogRegLickLatThreat_opMAP(file, animal, category, 'revForFlag', revForFlag);
else
    [glm_rwdLickSafe, safeStayLickLat, safeSwitchLickLat, binSize, timeMax]= combineLogRegLickLatSafeTime_opMAP(file, animal, category, 'revForFlag', revForFlag);
    [glm_rwdLickThreat, threatStayLickLat, threatSwitchLickLat, ~, ~]= combineLogRegLickLatTime_opMD(file, animal, category, 'revForFlag', revForFlag);
    timeBinEdges = [1000:binSize:timeMax];
    tMax = length(timeBinEdges) - 1;
end


%plot beta coeffs for multiple covariate type model
figure; hold on;
relevInds = 2:tMax+1;
coefVals = glm_rwdLickSafe.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_rwdLickSafe);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
if trialFlag
    errorbar([1:tMax],coefVals,errorL,errorU,'Color', [255,204,255]./255,'linewidth',2)
else
    errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'Color', [255,204,255]./255,'linewidth',2)
end

coefVals = glm_rwdLickThreat.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_rwdLickThreat);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
if trialFlag
    errorbar([1:tMax],coefVals,errorL,errorU,'Color', [255,255,0]./255,'linewidth',2)
    xlabel('Reward n trials back')
else
    errorbar(((1:timeMax)*binSize/1000),coefVals,errorL,errorU,'Color', [255,255,0]./255,'linewidth',2)
    xlim([0 (timeMax*binSize/1000 + binSize/1000)])
    xlabel('Reward n seconds back')
end
title('LRM - Rewards on Licks')
suptitle(animal)
legend('safe', 'threat')
ylabel('\beta Coefficient')


figure;
mag = [1 0 1];
cyan = [0 1 1];
set(gcf,'defaultAxesColorOrder',[[255,204,255]./255; [255,255,0]./255]);

subplot(2,2,1)
yyaxis left; histogram(safeStayLickLat, 30, 'Normalization', 'probability')
yyaxis right; histogram(threatStayLickLat, 30, 'Normalization', 'probability')
legend('safe', 'threat')
title('stay lick latency')

subplot(2,2,2)
yyaxis left; histogram(safeSwitchLickLat, 30, 'Normalization', 'probability')
yyaxis right; histogram(threatSwitchLickLat, 30, 'Normalization', 'probability')
legend('safe', 'threat')
title('switch lick latency')

subplot(2,2,3)
yyaxis left; histogram(safeStayLickLat, 30, 'Normalization', 'probability')
yyaxis right; histogram(safeSwitchLickLat, 30, 'Normalization', 'probability')
legend('stay', 'switch')
title('pre lick latency')

subplot(2,2,4)
yyaxis left; histogram(threatStayLickLat, 30, 'Normalization', 'probability')
yyaxis right; histogram(threatSwitchLickLat, 30, 'Normalization', 'probability')
legend('stay', 'switch')
title('post lick latency')


suptitle(animal)