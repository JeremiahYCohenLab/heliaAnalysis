function outputStruct = loadBehavioralData_omAP(fileOrFolder, varargin)
% loadBehavioralData_df    Parses input to generate behavioral data structure
%   INPUTS
%       fileOrFolder: session name or name of .asc file
%           e.g.: 'mBB041d20161006'
%           e.g.: 'mBB041d20161006.asc'
%       varargin
%           OverrideBehavioralMatFile: default false; will override the .mat file saved
%           Root: default is from currComputer_operantMatching();
%           Separator: default is from currComputer_operantMatching();
%   OUTPUTS
%       outputStruct
%           outputStruct.s: behavioral data structure
%           outputStruct.bs: vector of trials at block switch; each number is the first trial of each block
%           outputStruct.bp: cell array of block probabilities; format is left port / right port
%           outputStruct.settings: settings for particular session
%           outputStruct.pathData: all relevant path information where data is kept
%           outputStruct.parsedData: easily-analyable parsed data

[root, sep] = currComputer();

p = inputParser;
% default parameters if none given
p.addParameter('OverrideBehavioralMatFile', false);
p.addParameter('Root', root)
p.addParameter('Separator', sep)
p.addParameter('Load_Neural_Flag', false)
p.parse(varargin{:});

% root = p.Results.Root;
% sep = p.Results.Separator;

pathData = parseSessionString_dfAP(fileOrFolder);

sortedFolder = dir(pathData.sortedFolder);

if p.Results.Load_Neural_Flag == false
    sessionDataInd = contains({sortedFolder.name},'_fullStruct.mat');
%     & contains({sortedFolder.name},pathData.suptitleName); 
    if p.Results.OverrideBehavioralMatFile == false && any(sessionDataInd) && p.Results.Load_Neural_Flag == false % check if there is a file with suptitleName prefix and _behav.mat suffix
        load([pathData.sortedFolder sortedFolder(sessionDataInd).name])
        fprintf('Loaded %s\n', sortedFolder(sessionDataInd).name);
    else
        outputStruct = generateSessionData_behav_dfAP(pathData.behavioralDataPath , pathData);
%         pathData.behavioralDataPath, pathData, 'Root', root', 'Separator', sep);
        fprintf('Generated new behavioral data structure\n')
    end
elseif p.Results.Load_Neural_Flag == true 
    if any(contains({sortedFolder.name}, 'intan.mat')) % load intan data
        fnAll = arrayfun(@(x) x.name(1:(end)), dir([pathData.sortedFolder '\*intan.mat']),'UniformOutput',false);
        if length(fnAll) == 1
            load(fullfile(pathData.sortedFolder, fnAll{1}));
            outputStruct = sessionData;
            fprintf('Loaded %s\n', fnAll{1})
        else
            error('More than 1 file *intan.mat');
        end
    elseif any(contains({sortedFolder.name}, 'nL.mat')) % load neuralynx data
        fnAll = arrayfun(@(x) x.name(1:(end)), dir([pathData.sortedFolder '\*nL.mat']),'UniformOutput',false);
        if length(fnAll) == 1
            load(fullfile(pathData.sortedFolder, fnAll{1}));
            outputStruct = sessionData;
            fprintf('Loaded %s\n', fnAll{1})
        else
            error('More than 1 file *nL.mat');
        end
    else
        error('No neural data for this session');
    end
end
