function [tbl, samples] = stan_qLearningFit(xlFile, animal, category, varargin)

p = inputParser;
% default parameters if none given
p.addParameter('revForFlag', 0);
p.addParameter('fixedParams', 0);
p.addParameter('params', ['fiveParamOfourStart_preS']);
p.addParameter('paramInds', [1 2 3 4 5]);
p.addParameter('paramNames', {'aN', 'aP', 'aF', 'beta', 'v'});
p.addParameter('animalName', []);
p.addParameter('modelType', ['fourParam']);
p.parse(varargin{:});

[root, sep] = currComputer();

[~, dayList, ~] = xlsread(xlFile, animal);
[~,col] = find(~cellfun(@isempty,strfind(dayList, category)) == 1);
dayList = dayList(2:end,col);
endInd = find(cellfun(@isempty,dayList),1);
if ~isempty(endInd)
    dayList = dayList(1:endInd-1,:);
end

for i = 1:length(dayList)
    sessionName = dayList{i};
    filename = [sessionName '.asc'];
    [behSessionData, unCorrectedBlockSwitch, out] = loadBehavioralData(filename, p.Results.revForFlag);
    behavStruct = parseBehavioralData(behSessionData, unCorrectedBlockSwitch);

    choiceTmp{i} = behavStruct.allChoices;
    choiceTmp{i}(choiceTmp{i} == -1) = 2;
    outcomeTmp{i} = abs(behavStruct.allRewards); 
    Tsesh(i,1) = length(outcomeTmp{i});
end

T = max(Tsesh);
N = length(dayList);
choice = zeros(N, T);
outcome = zeros(N, T);

for i = 1:N
    choice(i, 1:Tsesh(i)) = choiceTmp{i};
    outcome(i, 1:Tsesh(i)) = outcomeTmp{i};
end


if p.Results.fixedParams
    [allParams, modelNames, ~] = xlsread('stanParams.xlsx', animal);
    [~,col] = find(~cellfun(@isempty,strfind(modelNames, p.Results.params)) == 1);
    params = allParams(p.Results.paramInds,col);
    session_dat = struct('N',N,'T',T, 'Tsesh', Tsesh, 'choice', choice, 'outcome', outcome, 'params', params);
else
    session_dat = struct('N',N,'T',T, 'Tsesh', Tsesh, 'choice', choice, 'outcome', outcome);
end

filePath = ['C:\Users\cooper_PC\Desktop\githubRepositories\cooperAnalysis\matlabCode\operantMatching\learningModels\stan\'];
switch p.Results.modelType
    case 'fourParam'
        fit = stan('file',[filePath 'stan_qLearning_4params.stan'],'data',session_dat,'verbose',true);
    case 'fourParamFixed'
        scriptName = ['stan_qLearning_4params_fixedParams_' ...
            p.Results.paramNames{setdiff([1:4], p.Results.paramInds)} '.stan'];
        fit = stan('file',[filePath scriptName],'data',session_dat,'verbose', true);
    case 'fiveParamO'
        fit = stan('file',[filePath 'stan_qLearning_5params_opponency.stan'],'data',session_dat,'verbose', true);
    case 'fiveParamO_rBarStart'
        fit = stan('file',[filePath 'stan_qLearning_5params_opponency_rBarStart.stan'],'data',session_dat,'verbose', true);
    case 'fiveParamOFixed'
        scriptName = ['stan_qLearning_5params_opponency_fixedParams_' ...
            p.Results.paramNames{setdiff([1:5], p.Results.paramInds)} '.stan'];
        fit = stan('file',[filePath scriptName],'data',session_dat,'verbose', true);
    case 'fiveParamO_strongPriors'
        fit = stan('file',[filePath 'stan_qLearning_5params_opponency_strongPriors.stan'],'data',session_dat,'verbose', true);
    case 'fiveParam_peBeta'
        fit = stan('file',[filePath 'stan_qLearning_5params_peBeta.stan'],'data',session_dat,'verbose', true);
    case 'sixParam_peBeta'
        fit = stan('file',[filePath 'stan_qLearning_6params_peBeta.stan'],'data',session_dat,'verbose', true);
    otherwise
        fprintf([p.Results.modelType ' model does not exist'])
end

disp('pres any key to continue once the stan processing has been completed')
pause;


samples = fit.extract('permuted',true);
[~, tbl] = fit.print();

paramEsts = [];
if p.Results.fixedParams
    [binNum, edges]  = discretize(eval(['samples.mu_' p.Results.paramNames{setdiff([1:5], p.Results.paramInds)}]),100);
    binInd = mode(binNum);
    paramEsts = mean([edges(binInd) edges(binInd + 1)]);
else
    for i = 1:length(p.Results.paramInds)
        [binNum, edges]  = discretize(eval(['samples.mu_' p.Results.paramNames{p.Results.paramInds(i)}]),100);
        binInd = mode(binNum);
        paramEsts(i) = mean([edges(binInd) edges(binInd + 1)]);
    end
end


if p.Results.fixedParams
    sampFile = [animal category, '_', p.Results.modelType, '_', p.Results.paramNames{setdiff([1:5], p.Results.paramInds)}];
    saveFile = [sampFile '.mat'];
    eval([sampFile,  ' = samples;']);
else
    sampFile = [animal category '_', p.Results.modelType];
    saveFile = [sampFile '.mat'];
    eval([sampFile,  ' = samples;']);
end

savePath = [root animal sep animal 'sorted' sep 'stan' sep];
if ~exist(savePath)
    mkdir(savePath);
end
save([savePath saveFile], sampFile, 'paramEsts', 'dayList')

figure; 
title([animal ' - ' p.Results.modelType], 'Interpreter', 'none');
if p.Results.fixedParams
    histogram(eval(['samples.mu_' p.Results.paramNames{setdiff([1:5], p.Results.paramInds)}]), 100,...
            'Normalization', 'Probability', 'FaceColor', 'k')
        set(gca,'tickdir', 'out')
        xlabel( p.Results.paramNames{setdiff([1:5], p.Results.paramInds)})
else
    numParams = length(p.Results.paramInds);
    blue = [0 1 1];
    purp = [0.7 0 1];
    colors = [linspace(blue(1),purp(1),numParams)', linspace(blue(2),purp(2),numParams)', linspace(blue(3),purp(3),numParams)'];
    for i = 1:numParams
        subplot(1,numParams,i); hold on;
        histogram(eval(['samples.mu_' p.Results.paramNames{p.Results.paramInds(i)}]) , 100,...
            'Normalization', 'Probability', 'FaceColor', colors(i,:))
        set(gca,'tickdir', 'out') 
        title(p.Results.paramNames{p.Results.paramInds(i)})
    end
end
set(gcf,'Renderer', 'Painters')
    
    
    
