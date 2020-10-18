function [fs_b]  = generateFullBehavioralStructure_session(SaveData_Flag)

behavStruct = [];

workbookFile = 'C:\Users\Helia\Documents\dataFullstructure\oM_behavior.xlsx';
[~, allAnimals] = xlsfinfo(workbookFile);
for currA = 1:length(allAnimals)
    behavTable = importExcelData_behavior_om(workbookFile, allAnimals{currA});
%     usableDates = behavTable.usable ~= 0;
%     behavTable = behavTable(usableDates, :);
    for currS = 1:height(behavTable)
        sessionName = ['m' char(behavTable.session(currS))];
        os = loadBehavioralData_om(sessionName, 'OverrideBehavioralMatFile', true);
%         behavStruct.(allAnimals{currA}).(strrep(sessionName,'\','')) = os;
    end
end

save('C:\Users\Helia\Documents\dataFullstructure\behavStruct.mat','behavStruct')

%%
numTrials = 0;
numSesh = 0;
totalTime = 0;
probabilities = {};
allAnimals = fields(behavStruct);
for currA = 1:length(allAnimals)
    allSessions = fields(behavStruct.(allAnimals{currA}));
    numSesh = numSesh + length(allSessions);
    for currS = 1:length(allSessions)
        numTrials = numTrials + length(behavStruct.(allAnimals{currA}).(allSessions{currS}).s);
        totalTime = totalTime + behavStruct.(allAnimals{currA}).(allSessions{currS}).s(end).CSon - ...
            behavStruct.(allAnimals{currA}).(allSessions{currS}).s(1).CSon;
        probabilities = [probabilities behavStruct.(allAnimals{currA}).(allSessions{currS}).pd.bp];
    end
end
