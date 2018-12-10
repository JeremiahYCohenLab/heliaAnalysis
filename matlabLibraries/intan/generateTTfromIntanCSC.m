function generateTTfromIntanCSC(sessionString, varargin)

[root, sep] = currComputer();
p = inputParser;
% default parameters if none given
p.addParameter('RecordingType', 'session');
p.addParameter('RemoveLick', false);
p.addParameter('MedianRemoval', true);
p.addParameter('HighPassCutoffInHz', 300);
p.addParameter('SamplingFreq', 20000);
p.addParameter('ThresholdFactor', 2);
p.addParameter('RefractorySamples', 20);
p.addParameter('AnalyzeSpecificTTs', []);
p.addParameter('NumberOfTTs', 8);
p.parse(varargin{:});

%set params for butterworth filter
Wn = p.Results.HighPassCutoffInHz / (p.Results.SamplingFreq/2);
[b, a] = butter(2, Wn, 'high');
tSamp = 1/p.Results.SamplingFreq * 1e6; % time per sample in microseconds

%pinmap for neuralynx eib 36 narrow connected to intan rhd2132 amplifier board
%shifted +1 to account for 0-start index of pins

if p.Results.NumberOfTTs == 16
                     %TT1          TT2       TT3      TT4        TT5         TT6           TT7         TT8 
    nlxPinMap = [25 26 27 28; 29 30 31 32; 1 2 3 4; 5 6 7 8; 24 23 22 21; 20 19 18 17; 16 15 14 13; 12 11 10 9;...
            57 58 59 60; 61 62 63 64; 33 34 35 36; 37 38 39 40; 56 55 54 53; 52 51 50 49; 48 47 46 45; 44 43 42 41];
              %TT9          TT10         TT11          TT12        TT13          TT14        TT15         TT16    
else
                 %TT1          TT2           TT3      TT4
    nlxPinMap = [25 26 27 28; 29 30 31 32; 1 2 3 4; 5 6 7 8;...
                    24 23 22 21; 20 19 18 17; 16 15 14 13; 12 11 10 9];
                    %TT5         TT6           TT7         TT8
end
                
sampBack = round(1/3*32) - 1;   %number of samples for processing in nlx spikesort 3d
sampFor = round(2/3*32);

pd = parseSessionString_oM(sessionString, root, sep);
ephysPath = [pd.ephysPath p.Results.RecordingType sep];
dirToSave = [pd.ephysPath 'spikeSort_' p.Results.RecordingType sep];

ephysDir = dir(ephysPath);
if isempty(ephysDir)
    error('No ephys folder in %s', sessionString)
end
if ~isdir(dirToSave)
    mkdir(dirToSave);
end

RHDmask = contains({ephysDir.name},'rhd');
fprintf('Analyzing %s\n', pd.sessionFolder)
digIn = [];
sampToSave = [];
featToSave = [];
ts = 0;
loopInd = 1;

if isempty(p.Results.AnalyzeSpecificTTs)
    tts = 1:p.Results.NumberOfTTs;
else
    tts = p.Results.AnalyzeSpecificTTs;
end

for currRHD_ind = find(RHDmask)
    %SAVE THIS STRUCT AND OPEN IF IT ALREADY EXISTS
    fprintf('Recording file number: %d of %d \n', loopInd, sum(RHDmask));
    filename = ephysDir(currRHD_ind).name;
    [digIn, traces, ~] = readIntan(ephysPath, filename);
    
    if p.Results.MedianRemoval == true
        traces = traces - median(traces);
    end
        
    for ttInd = tts 
        filtTrace = [];
        for i = 1:4
            filtTrace(i,:) = filtfilt(b, a, -traces(nlxPinMap(ttInd,i),:));
            tsInterp = ts:tSamp:ts + tSamp*(length(filtTrace(i,:)) - 1);
            
            % threshold and median method from Rey, Pedreira, Quiroga (2015)
            thresh = p.Results.ThresholdFactor*round(median(abs(filtTrace(i,:)))/0.6745);
    %        locs = sort([peakseek(filtTrace, p.Results.RefractorySamples, thresh) peakseek(-filtTrace, p.Results.RefractorySamples, thresh)]); % look for a peak, avoid 32 samples (1ms at 32kHz)
            locs = peakseek(filtTrace(i,:), p.Results.RefractorySamples, thresh);

            allLocsTmp{i} = unique(locs, 'stable');
            allLocsTmp{i}(allLocsTmp{i} > length(tsInterp) - p.Results.RefractorySamples) = []; % remove spikes within 1ms of the end of recording
            allLocsTmp{i}(allLocsTmp{i} < p.Results.RefractorySamples) = []; % remove spikes within 1ms of the beginning of recording

            while any(diff(allLocsTmp{i}) < p.Results.RefractorySamples) % while there is an overlap in peaks within 1ms
                for j = 1:length(allLocsTmp{i}) - 1
                    if allLocsTmp{i}(j + 1) < allLocsTmp{i}(j) + p.Results.RefractorySamples
                        % save each trace and find where the best peak is
                        tmp(1, :) = filtTrace(i, allLocsTmp{i}(j):allLocsTmp{i}(j) + p.Results.RefractorySamples);
                        [~, tmpi] = max(max(tmp));
                        allLocsTmp{i}(j) = allLocsTmp{i}(j) + tmpi - 1;
                        allLocsTmp{i}(j + 1) = allLocsTmp{i}(j);
                    end
                end
                allLocsTmp{i} = unique(allLocsTmp{i}, 'stable');
            end
            while allLocsTmp{i}(end) > (size(filtTrace,2) - sampFor)  %gets rid of spikes to close to the end
                allLocsTmp{i} = allLocsTmp{i}(1:end-1);
            end
            while allLocsTmp{i}(1) < sampBack  %gets rid of spikes too close to the beginning
                allLocsTmp{i} = allLocsTmp{i}(2:end);
            end    
        end
        
        allLocs = unique([allLocsTmp{1} allLocsTmp{2} allLocsTmp{3} allLocsTmp{4}], 'stable');
        clear allLocsTmp
        
        % remove lick artifact from TT; remove the 1ms preceding every lick event
        if p.Results.RemoveLick == true
            lickInds = [];
            lickOn = find((digIn(5,1:end-1) == 0 &  digIn(5,2:end) > 0) | ...
                (digIn(6,1:end-1) == 0 &  digIn(6,2:end) > 0 ));
            for j = 1:length(lickOn)
                lickIndsTmp{j} = find(allLocs < lickOn(j) & allLocs > lickOn(j) - 50);
                if ~isempty(lickIndsTmp{j})
                    [~, lickIndsMax] = max(filtTrace(allLocs(lickIndsTmp{j})));
                    lickInds(j) = lickIndsTmp{j}(lickIndsMax);
                else
                    lickInds(j) = NaN;
                end
            end
            lickInds = lickInds(~isnan(lickInds));
            allLocs(lickInds) = [];
        end      
        
        locMat = NaN(length(allLocs), 32);      %for taking 32 samples around peak, has to be 32 for spikesort3D
        for j = 1:length(allLocs)
            locMat(j, :) = allLocs(j) - sampBack:allLocs(j) + sampFor;
        end
        for i = 1:4
            filtTraceTmp = filtTrace(i,:);
            sampToSaveTemp(:,i,:) = filtTraceTmp(locMat)'*100;          %multiply to scale for spikesort3D
            featToSaveTemp(i,:) = max(filtTraceTmp(locMat)'*100);
            featToSaveTemp(i+4,:) = min(filtTraceTmp(locMat)'*100);
        end
        if loopInd == 1
            sampToSave{ttInd} = sampToSaveTemp;
            featToSave{ttInd} = featToSaveTemp;
            tsToSave{ttInd} = tsInterp(allLocs);       
        else
            sampToSave{ttInd} = cat(3, sampToSave{ttInd}, sampToSaveTemp);
            featToSave{ttInd} = [featToSave{ttInd}, featToSaveTemp];
            tsToSave{ttInd} = [tsToSave{ttInd} tsInterp(allLocs)];
        end
        clear sampToSaveTemp featToSaveTemp tsToSaveTemp
    end
 
    ts = tsInterp(end) + tSamp;
    loopInd = loopInd + 1;
    
end

fileInd = 1;
for ttInd = tts
    fprintf('Saving spikesort file %d of %d \n', fileInd, length(tts))
    Mat2NlxSpike([dirToSave 'TT_' num2str(ttInd) '.ntt'], 0, 1, [], [1 1 1 1 1], tsToSave{ttInd}, ...
        zeros(1, length(tsToSave{ttInd})), zeros(1, length(tsToSave{ttInd})), featToSave{ttInd}, sampToSave{ttInd});  
    fileInd = fileInd + 1;
end
    
fprintf('Finished\n')