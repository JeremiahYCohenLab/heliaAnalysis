function [glm_rwdLickSafe, glm_rwdLickThreat] = compareLogRegLickStates_opMAP(file, animal, category, revForFlag, trialFlag)

if nargin < 5
    trialFlag = 0;
end

%run function to generate lrm 
if trialFlag
    [glm_rwdLickSafe, glm_rwdLickThreat, StayLickLat_safe, SwitchLickLat_safe, StayLickLat_threat, SwitchLickLat_threat, tMax] = combineLogRegLickLatStates_opMAP(file, animal, category, revForFlag);
else
    [glm_rwdLickSafe, glm_rwdLickThreat, StayLickLat_safe, SwitchLickLat_safe, StayLickLat_threat, SwitchLickLat_threat,  binSize, timeMax, tMax] = combineLogRegLickLatStatesTime_opMAP(file, animal, category, revForFlag);
%     timeBinEdges = [1000:binSize:timeMax];
      
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
    errorbar(((1:tMax)*binSize/1000),coefVals,errorL,errorU,'Color', [255,255,0]./255,'linewidth',2)
    xlim([0 (tMax*binSize/1000 + 5)])
    xlabel('Reward n seconds back')
end
title('LRM - Rewards on Licks')
suptitle(animal)
legend('safe', 'threat')
ylabel('\beta Coefficient')


figure;
% set(gcf,'defaultAxesColorOrder',[[255,204,255]./255; [255,255,0]./255]);

subplot(2,2,1)
yyaxis left; histogram(StayLickLat_safe, 30, 'Normalization', 'probability', 'Facecolor', [255,204,255]./255)
yyaxis right; histogram(StayLickLat_threat, 30, 'Normalization', 'probability', 'FaceColor', [255,255,0]./255)
legend('safe', 'threat')
title('stay lick latency')

subplot(2,2,2)
yyaxis left; histogram(SwitchLickLat_safe, 30, 'Normalization', 'probability','Facecolor', [255,204,255]./255)
yyaxis right; histogram(SwitchLickLat_threat, 30, 'Normalization', 'probability','FaceColor', [255,255,0]./255)
legend('safe', 'threat')
title('switch lick latency')

subplot(2,2,3)
yyaxis left; histogram(StayLickLat_safe, 30, 'Normalization', 'probability', 'Facecolor',[58,199,199]./255)
yyaxis right; histogram(SwitchLickLat_safe, 30, 'Normalization', 'probability','Facecolor', [255,204,255]./255)
legend('stay', 'switch')
title('safe lick latency')

subplot(2,2,4)
yyaxis left; histogram(StayLickLat_threat, 30, 'Normalization', 'probability','Facecolor',  [58,199,199]./255)
yyaxis right; histogram(SwitchLickLat_threat, 30, 'Normalization', 'probability', 'Facecolor', [200,200,0]./255)
legend('stay', 'switch')
title('threat lick latency')


suptitle(animal)