function optoIDintanTT(filename, varargin)

p = inputParser;
% default parameters if none given
p.addParameter('Session', 'opto')
p.addParameter('SamplingFreq', 20000)
p.addParameter('Pulses', 10)
p.addParameter('Trains', 10)
p.addParameter('PulseWidth', 10)
p.addParameter('PulseFreq', 10)
p.addParameter('ResponseWindow', 30)
p.addParameter('MedianRemoval', true)
p.addParameter('HighPassCutoffInHz', 300);
p.parse(varargin{:});

%set params for butterworth filter
Wn = p.Results.HighPassCutoffInHz / (p.Results.SamplingFreq/2);
[b, a] = butter(2, Wn, 'high');

%pinmap for neuralynx eib 36 narrow connected to intan rhd2132 amplifier board
%shifted +1 to account for 0-start index of pins
                 %TT1          TT2       TT3      TT4        TT5         TT6           TT7         TT8 
nlxPinMap = [25 26 27 28; 29 30 31 32; 1 2 3 4; 5 6 7 8; 24 23 22 21; 20 19 18 17; 16 15 14 13; 12 11 10 9;...
        57 58 59 60; 61 62 63 64; 33 34 35 36; 37 38 39 40; 56 55 54 53; 52 51 50 49; 48 47 46 45; 44 43 42 41];
          %TT9          TT10         TT11          TT12        TT13          TT14        TT15         TT16   

%get session info
[root, sep] = currComputer();
[animalName, date] = strtok(filename, 'd'); 
animalName = animalName(2:end);
date = date(1:9);
sessionFolder = ['m' animalName date];

%specify and make directories
sortedDataPath = [root animalName sep sessionFolder sep 'sorted' sep p.Results.Session sep];
unsortedDataPath = [root animalName sep sessionFolder sep 'ephys' sep p.Results.Session sep];
saveDir = [root animalName sep sessionFolder sep 'figures'];
if ~exist(saveDir, 'dir')
    mkdir(saveDir)
end

%get sorted and raw ephys data
optoFiles = dir(fullfile(unsortedDataPath,'*.rhd'));
sortedFiles = dir(fullfile(sortedDataPath,'*.txt'));

%get list of channels with sorted units
for i = 1:length(sortedFiles)
    tmpInds = strfind(sortedFiles(i).name, '_');
    ttList(i) = str2double(sortedFiles(i).name(tmpInds(1)+1:tmpInds(2)-1));
end
chanList = nlxPinMap(ttList, :);


%combine traces and DI data from raw files, only from relvant channels
laser = [];
traces = [];
for i = 1:length(optoFiles)
    [digInTmp, tracesTmp, ~] = readIntan(unsortedDataPath, optoFiles(i).name);
    laser = [laser digInTmp(8,:)];
    traces = [traces tracesTmp];
end
if p.Results.MedianRemoval
    traces = traces - median(traces);
end

laserOnInds = find(laser(1:end-1) == 0 &  laser(2:end) > 0) + 1;
laserOffInds = find(laser(1:end-1) > 0 &  laser(2:end) == 0) + 1;

%create timestamps
tSamp = 1/p.Results.SamplingFreq * 1e3; % time per sample in ms
ts_interp = 0:tSamp:tSamp*(length(traces));
tSamp_us = 1/p.Results.SamplingFreq * 1e6;
ts_interp_us = 0:tSamp_us:tSamp_us*(length(traces));

laserOn = ts_interp(laserOnInds); %laser time on in ms
laserOff = ts_interp(laserOffInds);

%set window and stim paramaters
tB = 500;
tA = 500;
pulseInds = (1:p.Results.Pulses:p.Results.Pulses*p.Results.Trains);
respWin = p.Results.ResponseWindow;
rasterLength = length(-1*tB:(p.Results.Pulses*(1000/p.Results.PulseFreq)+tA));
    

%% 

for i = 1:length(sortedFiles)
    [cellName, ~] = strtok(sortedFiles(i).name, '.');
    spikeTimesTmp = [load(strcat(sortedDataPath, sortedFiles(i).name))]';
    traceInds = nlxPinMap(ttList(i),:);
    
    [spikeInds, ~] = ismember(ts_interp_us, spikeTimesTmp);     %convert to us to get correct/whole indices
    spikeInds = find(spikeInds == 1);
    for j = 1:length(spikeInds)
        traceSlopeTmp = fliplr(diff(traces(traceInds,spikeInds(j)-40:spikeInds(j)), [], 2)); %get slopes of trace in 2ms before spike peak, flip
        for k = 1:length(traceInds)
            if ~isempty(find((traceSlopeTmp(k,1:end-1) < 0 & traceSlopeTmp(k,2:end) > 0) | (traceSlopeTmp(k,1:end-1) > 0 & traceSlopeTmp(k,2:end) < 0), 1));
                spikeThreshInd(k) = find((traceSlopeTmp(k,1:end-1) < 0 & traceSlopeTmp(k,2:end) > 0) | (traceSlopeTmp(k,1:end-1) > 0 & traceSlopeTmp(k,2:end) < 0), 1) + 1;
            else
                spikeThreshInd(k) = NaN;
            end
        end
        spikeTimes(j) = spikeTimesTmp(j) - min(spikeThreshInd)*tSamp_us;
    end
    spikeTimes = spikeTimes/1000;           %convert to ms from us
    
    spikeRast = [];
    for j = 1:p.Results.Trains
        spikeRast{j} = spikeTimes(spikeTimes > (laserOn(pulseInds(j)) - tB) & spikeTimes < (laserOff(pulseInds(j)+9) + tA));
        spontSpikeRast{j} = spikeTimes((spikeTimes > (laserOn(pulseInds(j)) - tB) & spikeTimes < laserOn(pulseInds(j))) |...
            (spikeTimes > (laserOff(pulseInds(j)+9) + respWin) & spikeTimes < (laserOff(pulseInds(j)+9) + tA)));
        if ~isempty(spikeRast{j})
            spikeRast{j} = spikeRast{j} - laserOn(pulseInds(j)); %puts in time relative to first light pulse
        end
    end
    
    %find times when there is no light for control comparison
    laserSham = [linspace(-tB, 0-1000/p.Results.PulseFreq, p.Results.Pulses/2) ...
        linspace(p.Results.Pulses*1000/p.Results.PulseFreq, rasterLength-1000/p.Results.PulseFreq, p.Results.Pulses/2)];
    
    spikeLat = [];
    spikeLatSham = [];
    lightSpikeTimes = [];
    for j = 1:p.Results.Trains              %for all pulses in all trains, find spikes within the response window
        for k = 1:p.Results.Pulses
            spikeRespTmp = spikeTimes(spikeTimes > laserOn(pulseInds(j)+k-1) & ...
                spikeTimes < laserOn(pulseInds(j)+k-1) + respWin);
            spikeRespTmpSham = spikeTimes(spikeTimes > laserSham(k) + laserOn(pulseInds(j)) & ...
                spikeTimes < laserSham(k) + laserOn(pulseInds(j)) + respWin);
            if ~isempty(spikeRespTmp)
                spikeLat(j,k) = spikeRespTmp(1) - laserOn(pulseInds(j)+k-1);
                lightSpikeTimes = [lightSpikeTimes spikeRespTmp(1)];
            else
                spikeLat(j,k) = NaN;
            end
             if ~isempty(spikeRespTmpSham)
                spikeLatSham(j,k) = spikeRespTmpSham(1) - (laserSham(k) + laserOn(pulseInds(j)));
            else
                spikeLatSham(j,k) = NaN;
            end           
        end
    end
    avgSpikeLat = nanmean(spikeLat);    avgSpikeLatSham = nanmean(spikeLatSham);        %find average spikeLat and P(spike)
    spikeProb = mean(~isnan(spikeLat)); spikeProbSham = mean(~isnan(spikeLatSham));
    
    %using spike times, get indices for extracting spike waveforms
    [lightSpikeInds, ~] = ismember(ts_interp_us, lightSpikeTimes*1000);     %convert to us to get correct/whole indices
    lightSpikeInds = find(lightSpikeInds == 1);
    for j = 1:length(lightSpikeInds)
        lightSpikeMat(j,:) = [(lightSpikeInds(j)-10) : (lightSpikeInds(j)+20)];     %create mat for waveforms
    end
    
    spontSpikeTimes = [];
    for j = 1:length(spontSpikeRast)
        if ~isempty(spontSpikeRast{j})
            spontSpikeTimes = [spontSpikeTimes spontSpikeRast{j}];
        end
    end
    [spontSpikeInds, ~] = ismember(ts_interp_us, spontSpikeTimes*1000);
    spontSpikeInds = find(spontSpikeInds == 1);
    
    for j = 1:length(spontSpikeInds)
        spontSpikeMat(j,:) = [(spontSpikeInds(j)-10) : (spontSpikeInds(j)+20)];
    end
    
    lightSpikeTraces = []; spontSpikeTraces = [];
    spontFlag = exist('spontSpikeMat', 'var');
    for j = 1:length(traceInds)
        traceTmp = traces(traceInds(j),:);
        lightSpikeTraces(:,:,j) = traceTmp(lightSpikeMat);       %extract waveforms from trace
        if spontFlag
            spontSpikeTraces(:,:,j) = traceTmp(spontSpikeMat);
        end
    end
    
    
    %% plot everything
    
    rasters = figure; subplot(4,3,[1:6]); hold on; title(strcat(filename, '_', cellName),'Interpreter','none')
    xlabel('Time (ms)'); ylabel('Trials')
    LineFormat.Color = 'k'; LineFormat.LineWidth = 1;
    plotSpikeRaster(spikeRast,'PlotType','vertline','XLimForCell',[-1*tB rasterLength-tB],'LineFormat',LineFormat);
    hold on;
    x = linspace(0, ((p.Results.Pulses-1)*1000/p.Results.PulseFreq), p.Results.Pulses);
    xx = x + p.Results.PulseWidth;
    for j = 1:length(x)
        plotShaded([x(j) xx(j)],[0 0; 1+p.Results.Trains 1+p.Results.Trains],'b');
    end
    
    subplot(4,3,[7]); hold on;
    xlabel('Pulse'); ylabel('Latency (ms)'); ylim([0 30]); xlim([0 p.Results.Pulses+1])
    plot(avgSpikeLat, 'b', 'LineWidth', 2);
    plot(avgSpikeLatSham, 'k', 'LineWidth', 2);
    legend('laser','control');
    
    subplot(4,3,10); hold on;
    xlabel('Pulse'); ylabel('P(spike)'); ylim([-0.1 1.1]); xlim([0 p.Results.Pulses+1])
    plot(spikeProb, 'b', 'LineWidth', 2);
    plot(spikeProbSham, 'k', 'LineWidth', 2);
    
    spikeDur = [ts_interp(1:size(lightSpikeTraces, 2))];
    subplot(4,3,8); hold on;
    ylabel('Amplitude (uV)');
    for j = 1:length(traceInds)
        plot(spikeDur+spikeDur(end)*(j-1), mean(lightSpikeTraces(:,:,j)), '-b', 'linewidth', 2)
    end
    
    if spontFlag
        subplot(4,3,11); hold on;
        xlabel('Times (ms)'); ylabel('Amplitude (uV)');
        for j = 1:length(traceInds)
            plot(spikeDur+spikeDur(end)*(j-1), mean(spontSpikeTraces(:,:,j)), '-k', 'linewidth', 2)
        end
    end
    
    subplot(4,3,[9 12]); hold on
    xlabel('Time (ms)'); ylabel('Amplitude (uV)')
    for j = 1:length(traceInds)
        errorfill(spikeDur+spikeDur(end)*(j-1), mean(lightSpikeTraces(:,:,j)), std(lightSpikeTraces(:,:,j)), 'b');
    end
    if spontFlag
        for j = 1:length(traceInds)
            errorfill(spikeDur+spikeDur(end)*(j-1), mean(spontSpikeTraces(:,:,j)), std(spontSpikeTraces(:,:,j)), 'k');
        end
    end
 
    set(rasters, 'Position', get(0,'Screensize'))
    saveFigurePDF(rasters,[saveDir sep filename '_' cellName '_' p.Results.Session 'ID'])
end
  