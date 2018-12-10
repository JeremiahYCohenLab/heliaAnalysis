function [model] = calculateChoiceProb_opMD(sessionName,varargin)

%task and model parameters
p = inputParser;
% default parameters if none given
p.addParameter('revForFlag', false);
p.addParameter('modelNames', {'fiveParamO', 'twoParams'})
p.addParameter('params', [0.0596149,0.305917,0.642195,3.31916,0.1]);
p.addParameter('plotFlag', 0);
p.parse(varargin{:});

modelNames = p.Results.modelNames;

filename = [sessionName '.asc'];
if p.Results.revForFlag == 1
    [behSessionData, unCorrectedBlockSwitch, out] = loadBehavioralData_revFor(filename);
    behavStruct = parseBehavioralData_revFor(behSessionData, unCorrectedBlockSwitch);
else
    [behSessionData, unCorrectedBlockSwitch, out] = loadBehavioralData(filename);
    behavStruct = parseBehavioralData(behSessionData, unCorrectedBlockSwitch);
end

outcome = abs([behavStruct.allReward_R; behavStruct.allReward_L])';
choice = abs([behavStruct.allChoice_R; behavStruct.allChoice_L])';
ITI = [behavStruct.timeBtwn]';


if p.Results.plotFlag
    normKern = normpdf(-15:15,0,4);
    normKern = normKern / sum(normKern);
    normKern = fliplr(normKern(1:16));
    figure; hold on;
    allChoices = choice(:,1) - choice(:,2);
    yyaxis left; plot(conv(allChoices',normKern)/max(conv(allChoices',normKern)),'k','linewidth',1);
    ylim([-1 1])
    yticks([-1 0 1]); yticklabels([0 0.5 1])
end

for currMod = 1:length(modelNames)
    if strcmp(modelNames{currMod}, 'fiveParamO_rBarStart')
        [model.(modelNames{currMod}).LH, model.(modelNames{currMod}).probChoice, model.(modelNames{currMod}).Q, model.(modelNames{currMod}).pe, model.(modelNames{currMod}).rBar] = ...
            qLearningModel_5params_opponency(p.Results.params{currMod}, choice, outcome);
        color = [1 0 0];
    end
    
    if strcmp(modelNames{currMod}, 'twoParams')
        [model.(modelNames{currMod}).LH, model.(modelNames{currMod}).probChoice, model.(modelNames{currMod}).Q, model.(modelNames{currMod}).pe] = ...
            qLearningModel_2params(p.Results.params{currMod}, choice, outcome);
        color = [0 1 0];
    end
    
    if strcmp(modelNames{currMod}, 'fourParams_twoLearnRates_alphaForget')
        [model.(modelNames{currMod}).LH, model.(modelNames{currMod}).probChoice, model.(modelNames{currMod}).Q, model.(modelNames{currMod}).pe] = ...
            qLearningModel_4params_2learnRates_alphaForget(p.Results.params{currMod}, choice, outcome);
        color = [0 0 1];
    end
    
    if p.Results.plotFlag
        eval(['plot(model.' modelNames{currMod} '.probChoice(:,1), ''Color'',' color '''linewidth'', 1']);
    end

end

if p.Results.plotFlag
    ax = gca;
    ax.TickDir = 'out';
    set(gcf, 'Position', [-1910 159 1905 750]);
    set(gcf, 'Renderer', 'Painters')
end



