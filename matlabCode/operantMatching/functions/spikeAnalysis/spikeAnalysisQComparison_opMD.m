function [maxFRp, preCSp] = spikeAnalysisQComparison_opMD(xlFile, sheet, varargin)

p = inputParser;
% default parameters if none given
p.addParameter('trialFlag', 1);
p.addParameter('figFlag', 1)
p.addParameter('plotFlag', 1)
p.addParameter('intanFlag', 0)
p.parse(varargin{:});

[root, sep] = currComputer();

[~, sessionCellList, fullSheet] = xlsread(xlFile, sheet);
cellList = sessionCellList(2:end, 1);
sessionList = sessionCellList(2:end, 2);
revForFlagList = fullSheet(2:end,3);

for i = 1:length(sessionList)

    mdlTmp = spikeAnalysisQ_opMD(sessionList{i}, 'revForFlag', cell2mat(revForFlagList(1)),...
        'intanFlag', cell2mat(revForFlagList(i)), 'cellName', cellList{i});
    maxFRp(i,:) = mdlTmp.(cellList{i}).maxFRtrialQ.Coefficients.pValue(2:end);
    preCSp(i,:) = mdlTmp.(cellList{i}).preCSspikeCountQ.Coefficients.pValue(2:end);
end