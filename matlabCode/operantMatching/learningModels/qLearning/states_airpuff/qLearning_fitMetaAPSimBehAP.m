function [model] = qLearning_fitMetaAPSimBehAP(filename, startValues, varargin)

p = inputParser;
% default parameters if none given
p.addParameter('figFlag', 0)
p.addParameter('testFlag', 0)
p.addParameter('revForFlag',1)
p.addParameter('mouse',[])
p.addParameter('category', [])
p.parse(varargin{:});

[root, sep] = currComputer();


if ~isempty(p.Results.mouse)
    behavStruct = parseBehavioralData_multipleAP(filename, p.Results.mouse, p.Results.category, p.Results.revForFlag);
else
    [behSessionData, blockSwitch, stateSwitch, outputPathStruct] = loadBehavioralDataAP(filename, p.Results.revForFlag);
    behavStruct = parseBehavioralDataAP(behSessionData, blockSwitch);
end


outcome = abs([behavStruct.allReward_R; behavStruct.allReward_L])';
choice = abs([behavStruct.allChoice_R; behavStruct.allChoice_L])';
ITI = [behavStruct.timeBtwn]';
stateType = [behavStruct.stateType];



% Initialize models
modelName = {'qLearningModel_6Params_statesAP'};
startValues = load(startValues);



% Set up optimization problem
options = optimset('Algorithm', 'interior-point','ObjectiveLimit',...
    -1.000000000e+300,'TolFun',1e-15, 'Display','off');

% alpha_range = [0 1];
% alpha_range_threat = [0 1];
alphaNPE_range = [0 1];
alphaNPE_range_threat = [0 1];
alphaPPE_range = [0 1];
alphaPPE_range_threat = [0 1];
alphaForget_range = [0 1];
beta_range = [0 double(intmax)];
betaRate_range = [0 1];
betaMin_range = [0 double(intmax)];
betaMax_range = [0 double(intmax)];
v_range = [0 1];
rBarStart_range = [0 1]; 
tForget_range = [0 1];
bias_range = [-5 5];

if p.Results.figFlag
    figure; hold on;
end
   startValues = startValues.ans.qLearningModel_6Params_statesAP.bestParams;  
%     if p.Results.testFlag == 1
%         startValues = startValues(1, :);
%     end
   
    % initialize output variables
    runs = size(startValues, 1);
    allParams = zeros(size(startValues, 1), size(startValues, 2));
    LH = zeros(size(startValues, 1), 1);
    exitFl = zeros(size(startValues, 1), 1);
    hess = zeros(size(startValues, 1), size(startValues, 2), size(startValues, 2));
    numParam = size(startValues, 2);
    A=[eye(size(startValues, 2)); -eye(size(startValues, 2))];
    b=[ alphaNPE_range(2); alphaNPE_range_threat(2); alphaPPE_range(2); alphaPPE_range_threat(2);  alphaForget_range(2); beta_range(2);
           -alphaNPE_range(1); alphaNPE_range_threat(1); -alphaPPE_range(1); alphaPPE_range_threat(1); -alphaForget_range(1); -beta_range(1)];
        parfor r = 1:runs
            [allParams(r, :), LH(r, :), exitFl(r, :), ~, ~, ~, hess(r, :, :)] = ...
                fmincon(@qLearningModel_6Params_statesAP, startValues(r,:), A, b, [], [], [], [], [], options, choice, outcome, stateType);
        end
%         [~,bestFit] = min(LH);
%         model.(modelName).bestParams = allParams(bestFit, :);
        
         [~, model.probChoice, model.Q, model.pe] = ...
            qLearningModel_6Params_statesAP(startValues, choice, outcome, stateType);
plot(model.probChoice(:,1)/max(model.probChoice(:,1)), 'linewidth', 2);
hold on;
model.choice = choice;
model.outcome = outcome;

    for i = 1:length(choice)
        if choice(i,1) == 1
            if outcome(i,1) == 1
                plot([i i], [0.8 1], '-k');hold on;
            else
                plot([i i], [0.8 0.9], '-k'); hold on;
            end
        else
            if outcome(i,2) == 1
                plot([i i], [0 0.2], '-k'); hold on;
            else
                plot([i i], [0.1 0.2], '-k'); hold on;
            end
        end
    end
    str = [modelName];
    str = regexprep(str, '\_', ' ');
    legend(str)
title(filename);
[animalName date] = strtok(filename, 'd'); 
animalName = animalName(2:end);
savepath = [root sep animalName '_5param' sep];
if isempty(dir(savepath))
    mkdir(savepath)
end
saveFigurePDF(gcf,[savepath  sep 'simulted_qlearning_5params_' filename])
end