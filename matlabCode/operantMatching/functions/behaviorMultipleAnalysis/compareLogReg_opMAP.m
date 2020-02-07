function [glm_rwdNoRwd_safe, glm_rwdNoRwd_threat] = compareLogReg_opMAP(file, animal, category, revForFlag, trialFlag)

if nargin < 5
    trialFlag = 0;
end
if nargin < 4
    revForFlag = 0;
end

%run function to generate lrm
  if trialFlag
    [glm_rwdNoRwd_safe, tMax]= combineStates_opMAP(file, animal,category, revForFlag);
    [glm_rwdNoRwd_threat, ~]= combineStates_threat_opMAPP(file, animal,category, revForFlag);
 else
    [glm_rwdNoRwd_safe, s]= combineLogRegTime_safe_opMAP(file, animal, category, revForFlag);
    [glm_rwdNoRwd_threat,~]= combineLogRegTime_threat_opMAP(file, animal, category, revForFlag);
    tMax = s.tMax;
 end


%plot beta coeffs for multiple covariate type model
figure;
subplot(1,2,1); hold on;
relevInds = 2:tMax+1;
coefVals = glm_rwdNoRwd_safe.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_rwdNoRwd_safe);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
if trialFlag
    errorbar([1:tMax],coefVals,errorL,errorU,'Color',[1.0000 0.5804 0.7216],'linewidth',2)
else
    errorbar(((1:s.tMax)*s.binSize/1000),coefVals,errorL,errorU,'Color',[1.0000 0.5804 0.7216],'linewidth',2)
end

coefVals = glm_rwdNoRwd_threat.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_rwdNoRwd_threat);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
if trialFlag
    errorbar([1:tMax],coefVals,errorL,errorU,'Color', [0.6863 0.7216 0.2314],'linewidth',2)
    xlabel('Reward n trials back')
else
    errorbar(((1:s.tMax)*s.binSize/1000),coefVals,errorL,errorU,'Color', [0.6863 0.7216 0.2314],'linewidth',2)
    xlim([0 (s.tMax*s.binSize/1000 + s.binSize/1000)])
    xlabel('Reward n seconds back')
end
title('Combined Model - Reward')
legend(['safe | intercept: ' num2str(glm_rwdNoRwd_safe.Coefficients.Estimate(1))], ['threat | intercept: ' num2str(glm_rwdNoRwd_threat.Coefficients.Estimate(1))])
ylabel('\beta Coefficient')


subplot(1,2,2); hold on;
relevInds = tMax+2:tMax*2+1;
coefVals = glm_rwdNoRwd_safe.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_rwdNoRwd_safe);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
if trialFlag
    errorbar([1:tMax],coefVals,errorL,errorU,'Color',[1.0000 0.5804 0.7216],'linewidth',2)
else
    errorbar(((1:s.tMax)*s.binSize/1000),coefVals,errorL,errorU,'Color', [1.0000 0.5804 0.7216],'linewidth',2)
end

coefVals = glm_rwdNoRwd_threat.Coefficients.Estimate(relevInds);
CIbands = coefCI(glm_rwdNoRwd_threat);
errorL = abs(coefVals - CIbands(relevInds,1));
errorU = abs(coefVals - CIbands(relevInds,2));
if trialFlag
    errorbar([1:tMax],coefVals,errorL,errorU,'Color',[0.6863 0.7216 0.2314],'linewidth',2)
    xlabel('No reward n trials back')
else
    errorbar(((1:s.tMax)*s.binSize/1000),coefVals,errorL,errorU,'Color',[0.6863 0.7216 0.2314],'linewidth',2)
    xlim([0 (s.tMax*s.binSize/1000 + s.binSize/1000)])
    xlabel('No reward n seconds back')
end

title('Combined Model - No Reward')
legend('safe', 'threat')
ylabel('\beta Coefficient')
suptitle(animal)