function [fit, samples] = stan_qLearningFit_manip(xlFile, animal, pre, post, varargin)

p = inputParser;
% default parameters if none given
p.addParameter('revForFlag', 0);
p.addParameter('paramInds', [1 2 3 4 5]);
p.addParameter('paramNames', {'aN', 'aP', 'aF', 'beta', 'v'});
p.addParameter('animalName', []);
p.addParameter('modelType', ['fourParam']);
p.parse(varargin{:});

[root, sep] = currComputer();

[~, dayList, ~] = xlsread(xlFile, animal);
[~,col] = find(~cellfun(@isempty,strfind(dayList, pre)) == 1);
dayListPre = dayList(2:end,col);
endIndPre = find(cellfun(@isempty,dayListPre),1);
if ~isempty(endIndPre)
    dayListPre = dayListPre(1:endIndPre-1,:);
end
[~,col] = find(~cellfun(@isempty,strfind(dayList, post)) == 1);
dayListPost = dayList(2:end,col);
endIndPost = find(cellfun(@isempty,dayListPost),1);
if ~isempty(endIndPost)
    dayListPost = dayListPost(1:endIndPost-1,:);
end


for i = 1:length(dayListPre)
    sessionName = dayListPre{i};
    filename = [sessionName '.asc'];
    if p.Results.revForFlag == 1
        [behSessionData, unCorrectedBlockSwitch, out] = loadBehavioralData_revFor(filename);
        behavStruct = parseBehavioralData_revFor(behSessionData, unCorrectedBlockSwitch);
    else
        [behSessionData, unCorrectedBlockSwitch, out] = loadBehavioralData(filename);
        behavStruct = parseBehavioralData(behSessionData, unCorrectedBlockSwitch);
    end

    choiceTmpPre{i} = behavStruct.allChoices;
    choiceTmpPre{i}(choiceTmpPre{i} == -1) = 2;
    outcomeTmpPre{i} = abs(behavStruct.allRewards); 
    TseshPre(i,1) = length(outcomeTmpPre{i})
end

for i = 1:length(dayListPost)
    sessionName = dayListPost{i};
    filename = [sessionName '.asc'];
    if p.Results.revForFlag == 1
        [behSessionData, unCorrectedBlockSwitch, out] = loadBehavioralData_revFor(filename);
        behavStruct = parseBehavioralData_revFor(behSessionData, unCorrectedBlockSwitch);
    else
        [behSessionData, unCorrectedBlockSwitch, out] = loadBehavioralData(filename);
        behavStruct = parseBehavioralData(behSessionData, unCorrectedBlockSwitch);
    end

    choiceTmpPost{i} = behavStruct.allChoices;
    choiceTmpPost{i}(choiceTmpPost{i} == -1) = 2;
    outcomeTmpPost{i} = abs(behavStruct.allRewards); 
    TseshPost(i,1) = length(outcomeTmpPost{i});
end

T = max([TseshPre TseshPost]);
N = length(dayListPre);
M = length(dayListPost);
choicePre = zeros(N,T);
outcomePre = zeros(N,T);
choicePost = zeros(M,T);
outcomePost = zeros(M,T);

for i = 1:N
    choicePre(1:Tsesh(i),i) = choiceTmpPre{i};
    outcomePre(1:Tsesh(i),i) = outcomeTmpPre{i};
end
for i = 1:M
    choicePost(1:Tsesh(i),i) = choiceTmpPost{i};
    outcomePost(1:Tsesh(i),i) = outcomeTmpPost{i};
end

session_dat = struct('N',N,'M',M,'T',T,'Tsesh', TseshPre, 'choice', choicePre, 'outcome', outcomePre,...
    'TseshM', TseshPost, 'choiceM', choicePost, 'outcomeM', outcomePost);

filePath = ['C:\Users\cooper_PC\Desktop\githubRepositories\cooperAnalysis\matlabCode\operantMatching\learningModels\stan\'];
switch p.Results.modelType
    case 'fiveParamO'
        fit = stan('file',[filePath 'stan_qLearning_5params_opponency_manip.stan'],'data',session_dat,'verbose', true);
    otherwise
        fprintf([p.Results.modelType ' model does not exist'])
end

disp('pres any key to continue once the stan processing has been completed')
pause;

samples = fit.extract('permuted',true);
sampFile = [animal pre '_', p.Results.modelType '_change'];
saveFile = [sampFile '.mat'];
eval([sampFile,  ' = samples;']);

savePath = [root animal sep animal 'sorted' sep 'stan' sep];
if ~exist(savePath)
    mkdir(savePath);
end
save([savePath saveFile], sampFile)

    
    
    
    
    
