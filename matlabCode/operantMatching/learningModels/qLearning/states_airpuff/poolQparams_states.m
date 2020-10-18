function[modelParams]= poolQparams_states(folder,plot)

if nargin <2
    plot = 0;
end

[root, sep] = currComputer();
[name, model] = strtok(folder, '_'); 
model = model(2:end);

paramsPath = [root folder sep model sep 'pooledparams' sep folder '_PooledParam.mat'];


if exist(paramsPath,'file')
        load(paramPath);
else
    file = what(folder);
    files = fullfile(file.mat);

    modelParams.alpha_NPE_safe = [];
    modelParams.alpha_NPE_threat = [];
    modelParams.alpha_PPE_safe = [];
    modelParams.alpha_PPE_threat = [];
    modelParams.alpha_forget = [];
    modelParams.beta = [];
    for i = 1:length(files)
        [animalName, date] = strtok(files(i), 'd'); 
        animalName = animalName(2:end);
        date = date{1,1}(1:9);
        sessionName = ['m' animalName date '_lh_choice_outcome.mat'];
        filepath = [root folder sep sessionName];
        m = char(files(i));
        mm =load(m);
        modelParams(i).alpha_NPE_safe = [mm.ans.qLearningModel_6Params_statesAP.bestParams(1)];
        modelParams(i).alpha_NPE_threat = [mm.ans.qLearningModel_6Params_statesAP.bestParams(2)];
        modelParams(i).alpha_PPE_safe = [mm.ans.qLearningModel_6Params_statesAP.bestParams(3)];
        modelParams(i).alpha_PPE_threat = [mm.ans.qLearningModel_6Params_statesAP.bestParams(4)];
        modelParams(i).alpha_forget = [mm.ans.qLearningModel_6Params_statesAP.bestParams(5)];
        modelParams(i).beta = [mm.ans.qLearningModel_6Params_statesAP.bestParams(6)];
    end


    savepath = [root sep folder sep model sep 'pooledparams' sep];


    if isempty(dir(savepath))
        mkdir(savepath)
    end


    save([savepath folder '_PooledParam.mat']);
end

if plot == 1
    f= figure;
    subplot(2,2,1); hold on;
    AlphaNPE_safe = [modelParams.alpha_NPE_safe];
    [N,edges] = histcounts(AlphaNPE_safe);
    AlphaNPE_threat = [modelParams.alpha_NPE_threat];
    edges = length(edges);
    histogram(AlphaNPE_safe,edges,'FaceColor', [ 153 0 153]./255);hold on; histogram(AlphaNPE_threat,edges,'FaceColor', [0 51 204]./255)
    legend;
    subplot(2,2,2);
    AlphaPPE_safe = [modelParams.alpha_PPE_safe];
    [N,edges2] = histcounts(AlphaPPE_safe);
    AlphaPPE_threat = [modelParams.alpha_PPE_threat];
    edges2 = length(edges2);
    histogram(AlphaPPE_safe,edges2,'FaceColor', [ 153 0 153]./255);hold on; histogram(AlphaPPE_threat,edges2,'FaceColor', [0 51 204]./255);
    legend;
    normAlphaNPE_safe = normalize(AlphaNPE_safe);
    normAlphaNPE_threat= normalize(AlphaNPE_threat);
    normAlphaPPE_safe = normalize(AlphaPPE_safe);
    normAlphaPPE_threat= normalize(AlphaPPE_threat);
    [N,edges3] = histcounts(normAlphaNPE_safe);
    edges3 = length(edges3);
    [N,edges4] = histcounts(normAlphaPPE_safe);
    edges4 = length(edges4);
    subplot(2,2,3); 
    histogram(normAlphaNPE_safe,edges3,'FaceColor', [ 153 0 153]./255);hold on; histogram(normAlphaNPE_threat,edges3,'FaceColor', [0 51 204]./255);
    legend;
    subplot(2,2,4); 
    histogram(normAlphaPPE_safe,edges4,'FaceColor', [ 153 0 153]./255);hold on; histogram(normAlphaPPE_threat,edges4,'FaceColor', [0 51 204]./255);
    legend;
    title(animalName);
    print(f, [savepath sep 'histogram_' animalName], '-dpdf');
    %saveFigurePDF(gcf,[savepath sep animalName 'histogram']);
end
end