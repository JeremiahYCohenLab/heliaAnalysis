function [termStruct] = generateStanModelTerms_opMD(modelType, modelPath, sessionName, revForFlag)

%get model params
load(modelPath);
sessionInd = find(~cellfun(@isempty,strfind(dayList,sessionName)));
tmp = whos;
samples = eval(tmp(1).name);
mdlFields = fields(samples);
paramInds = find(~cellfun(@isempty,strfind(mdlFields,'mu_')));
paramInds = paramInds(2:end);
paramInds = paramInds - length(paramInds);

for j = 1:length(paramInds)
    tmp = eval(['samples.' mdlFields{paramInds(j)}]);
    tmp = tmp(:,sessionInd);
    [binNum, edges]  = discretize(tmp,100);
    binInd = mode(binNum);
    startValues(j) = mean([edges(binInd) edges(binInd + 1)]);
end 


%get session behavior
[behSessionData,blockSwitch,~] = loadBehavioralData([sessionName '.asc'], revForFlag);
o = parseBehavioralData(behSessionData, blockSwitch);
outcome = abs([o.allReward_R; o.allReward_L])';
choice = abs([o.allChoice_R; o.allChoice_L])';


switch modelType
    case 'fiveParamO_rBarStart'
        [LH, probChoice, Q, pe, rBar] = qLearningModel_5params_opponency(startValues, choice, outcome);
        rBarFlag = true;
end


termStruct.LH = LH;
termStruct.probChoice = probChoice;
termStruct.Q = Q;
termStruct.pe = pe;
if rBarFlag
    termStruct.rBar = rBar;
end


end