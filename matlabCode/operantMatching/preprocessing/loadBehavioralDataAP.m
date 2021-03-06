function [behSessionData, blockSwitch, stateSwitch, outputPathStruct] = loadBehavioralDataAP(fileOrFolder, revForFlag)

if nargin < 2
    revForFlag = 1;
end

[root, sep] = currComputer();

if ~isempty(strfind(fileOrFolder,'.asc')) % input is .asc file
    filename = fileOrFolder;
    [animalName, date] = strtok(filename, 'd'); 
%     animalName = animalName(2:end);
    sessionName = fileOrFolder;
%     date = date(1:9);
    sessionFolder = ['m' animalName date];
    behavioralDataPath = [root animalName sep sessionFolder sep 'behavior' sep filename];
    suptitleName = filename(1:strfind(filename,'.asc')-1);
    saveFigName = suptitleName;
else % input is the folder
    sessionFolder = fileOrFolder;
    animalName = strtok(sessionFolder, 'd');
%     animalName = animalName(2:end);
    sessionName = fileOrFolder;
    sessionName = ['m' sessionName];
    filepath = [root animalName sep sessionFolder sep 'behavior' sep];
    allFiles = dir(filepath);
    fileInd = ~cellfun(@isempty,strfind({allFiles.name},'.asc'));
    behavioralDataPath = [filepath allFiles(fileInd).name];
%     suptitleName = allFiles(fileInd).name;
    saveFigName = sessionFolder(~(sessionFolder==sep));
end

if isstrprop(fileOrFolder(end), 'alpha')
    sortedFolderLocation = [root animalName sep sessionFolder sep 'sorted' sep 'session ' suptitleName(end) sep];
else
    sortedFolderLocation = [root animalName sep sessionFolder sep 'sortedap' sep 'session' sep];
end
sortedFolder = dir(sortedFolderLocation);
sessionDataInd = ~cellfun(@isempty,strfind({sortedFolder.name},'_behav.mat')) & ~cellfun(@isempty,strfind({sortedFolder.name},sessionName)); 
if any(sessionDataInd) % check if there is a file with suptitleName prefix and _behav.mat suffix
    load([sortedFolderLocation sortedFolder(sessionDataInd).name])
    behSessionData = sessionData;
% %     if revForFlag
%         behSessionData = sessionData;
% %     end
else
% %     if revForFlag
        [behSessionData, blockSwitch, stateSwitch, ~] = generateSessionData_behav_operantMatchingAirpuff(sessionName);
%     else
%         [behSessionData, blockSwitch] = generateSessionData_operantMatchingDecoupled(suptitleName);
%     end
end

outputPathStruct.suptitleName = sessionName;
outputPathStruct.sessionFolder = sessionFolder;
outputPathStruct.animalName = animalName;
% outputPathStruct.saveFigName = saveFigName;