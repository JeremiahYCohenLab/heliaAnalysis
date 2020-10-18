data_wt2001 = load('/Users/heliaseifikar/Documents/GitHub/heliaData/Wt1805022001_5param/5param/pooledparams/Wt1805022001_5param_PooledParam.mat');
ppeLR_threat_2001 = [data_wt2001.modelParams(:).alpha_PPE_threat];
npeLR_threat_2001 = [data_wt2001.modelParams(:).alpha_NPE_threat];
ppeLR_safe_2001 = [data_wt2001.modelParams(:).alpha_PPE_safe];
npeLR_safe_2001 = [data_wt2001.modelParams(:).alpha_NPE_safe];

f= figure;
subplot(2,2,1); hold on;

[N,edges] = histcounts(npeLR_safe_2001);
edges = length(edges);
histogram(npeLR_safe_2001,edges,'FaceColor', [ 153 0 153]./255);hold on; histogram(npeLR_threat_2001,edges,'FaceColor', [0 51 204]./255)
legend('safe', 'threat');
title('negative learnig rate');
subplot(2,2,2);
[N,edges2] = histcounts(ppeLR_safe_2001);
edges2 = length(edges2);
histogram(ppeLR_safe_2001,edges2,'FaceColor', [ 153 0 153]./255);hold on; histogram(ppeLR_threat_2001,edges2,'FaceColor', [0 51 204]./255);
legend('safe', 'threat');
title('positive learnig rate');
normAlphaNPE_safe = normalize(npeLR_safe_2001);
normAlphaNPE_threat= normalize(npeLR_threat_2001);
normAlphaPPE_safe = normalize(ppeLR_safe_2001);
normAlphaPPE_threat= normalize(ppeLR_threat_2001);
[N,edges3] = histcounts(normAlphaNPE_safe);
edges3 = length(edges3);
[N,edges4] = histcounts(normAlphaPPE_safe);
edges4 = length(edges4);
subplot(2,2,3);
histogram(normAlphaNPE_safe,edges3,'FaceColor', [ 153 0 153]./255);hold on; histogram(normAlphaNPE_threat,edges3,'FaceColor', [0 51 204]./255);
legend('safe', 'threat');
title('normalized negative learnig rate');
subplot(2,2,4);
histogram(normAlphaPPE_safe,edges4,'FaceColor', [ 153 0 153]./255);hold on; histogram(normAlphaPPE_threat,edges4,'FaceColor', [0 51 204]./255);
legend('safe', 'threat');
title('normalized positive learnig rate');
print(f, ['/Users/heliaseifikar/Documents/GitHub/heliaData/Wt1805022001_5param/LRHist_animalName'], '-dpdf');