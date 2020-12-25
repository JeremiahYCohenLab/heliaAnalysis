function [fs_b]  = generateFullBehavioralStructure_session(SaveData_Flag)

behavStructStates = [];

workbookFile = 'C:\Users\Helia\Documents\heliaData\dataFullstructure\oM_behavior.xlsx';
[~, allAnimals] = xlsfinfo(workbookFile);
for currA = 1:length(allAnimals)
    behavTable = importExcelData_behavior_om(workbookFile, allAnimals{currA});
%     usableDates = behavTable.usable ~= 0;
%     behavTable = behavTable(usableDates, :);
    for currS = 1:height(behavTable)
        sessionName = ['m' char(behavTable.session(currS))];
        os = loadBehavioralData_om(sessionName, 'OverrideBehavioralMatFile', true);
        behavStructStates.(allAnimals{currA}).(strrep(sessionName,'\','')) = os;
    end
end

save('C:\Users\Helia\Documents\dataFullstructure\behavStruct.mat','behavStructStates')

%%
numTrials = 0;
numSesh = 0;
totalTime = 0;
probabilities = {};
allAnimals = fields(behavStructStates);
for currA = 1:length(allAnimals)
    allSessions = fields(behavStructStates.(allAnimals{currA}));
    numSesh = numSesh + length(allSessions);
    for currS = 1:length(allSessions)
        numTrials = numTrials + length(behavStructStates.(allAnimals{currA}).(allSessions{currS}).s);
        totalTime = totalTime + behavStructStates.(allAnimals{currA}).(allSessions{currS}).s(end).CSon - ...
            behavStructStates.(allAnimals{currA}).(allSessions{currS}).s(1).CSon;
        probabilities = [probabilities behavStructStates.(allAnimals{currA}).(allSessions{currS}).pd.bp];
    end
end
