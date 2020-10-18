function behavTable = importExcelData_behavior_om(workbookFile, animalName)

% Import the data
[~, ~, raw] = xlsread(workbookFile, animalName);
raw = raw(2:end, :);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
stringVectors = string(raw(:,[1]));
% stringVectors = string(raw(:,[1,3,5,6])); if more than coloumn 
stringVectors(ismissing(stringVectors)) = '';
% raw = raw(:,[2,4]);

% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

% Create output variable
I = cellfun(@(x) ischar(x), raw);
raw(I) = {NaN};
data = reshape([raw{:}],size(raw));

% Create table
behavTable = table;

%% Allocate imported array to column variable names
behavTable.session = stringVectors(:,1);
% behavTable.usable = data(:,1);
% behavTable.probabilities = stringVectors(:,2);
% behavTable.pupil = data(:,2);
% behavTable.neural = stringVectors(:,3);
% behavTable.misc = stringVectors(:,4);
