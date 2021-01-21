function ms = fitLearningMods_dfAP(os, varargin)
% fitLearningMods_df    Fits operant matching behavioral models with fmincon
%   ms = fitLearningMods_oM(os, varargin)
%   INPUTS
%       os: behavioral data structure
%       varargin
%           StartingPoints: determines how many points to optimize from
%           modStruct: model structure (output from importLearningModels_oM)
%           modType: model types to import
%   
%   OUTPUTS
%       ms: model structure of fits

p = inputParser;
p.addParameter('StartingPoints', 1)
p.addParameter('modStruct', '');
p.addParameter('modType', 'Q');
p.addParameter('particularModel', []);
p.addParameter('InputChoiceDirectly_Flag', false)
p.addParameter('Choices', []);
p.addParameter('Outcomes', []);
p.parse(varargin{:});

% if modStruct isn't supplied, generate it; this is here to speed up code if called many times (i.e. all behavioral data)
if isempty(p.Results.modStruct)
    ms = importLearningModels_df(p.Results.modType);
else
    ms = p.Results.modStruct;
end

% Set up optimization problem
options = optimset('Algorithm', 'interior-point','ObjectiveLimit',...
    -1.000000000e+300,'TolFun',1e-15, 'Display','off');

if p.Results.InputChoiceDirectly_Flag == false
    choice = abs([os.pd.allC_L; os.pd.allC_R])';
    outcome = abs([os.pd.allR_L; os.pd.allR_R])';
else
    choice = p.Results.Choices;
    outcome = p.Results.Outcomes;
end
    

if isempty(p.Results.particularModel)
    modList = fields(ms)';
else
%     if numel(p.Results.particularModel) == 1 % turn into a cell array if only one input is given
%         modList = {p.Results.particularModel};
%     else
        modList = p.Results.particularModel;
%     end
end
for currMod = modList
    currMod = currMod{:};
    % initialize start values; randomize within range of relevant variable
    startValues = rand(p.Results.StartingPoints, length(ms.(currMod).params));
    startValues = startValues.*ms.(currMod).b_range + ms.(currMod).b_min;
    
    % init other relev variables
    A = [eye(size(startValues, 2)); -eye(size(startValues, 2))];
    allParams = zeros(size(startValues));
    runs = size(startValues, 1);
    numParam = size(startValues, 2);
    LH = NaN(size(startValues, 1), 1);
    
    clear modOutput bestLH bestParams v

    parfor r = 1:runs
         [allParams(r, :), LH(r, :)] = fmincon(ms.(currMod).fh, startValues(r, :), A, ms.(currMod).b, [], [], [], [], [], options, choice, outcome, os.pd.fbITI);
    end
    
    [~, bestFit] = min(LH);
    bestParams = allParams(bestFit, :);
    bestLH = LH(bestFit);
    
    [~, modOutput] = ms.(currMod).fh(bestParams, choice, outcome, os.pd.fbITI);
    ms.(currMod).modOutput = modOutput;
    ms.(currMod).LH = bestLH;
    ms.(currMod).bestParams = bestParams;
    ms.(currMod).BIC = log(length(outcome))*numParam - 2*-bestLH;
end