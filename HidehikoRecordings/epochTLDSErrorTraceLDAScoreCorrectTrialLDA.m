addpath('../Func');
addpath('../Release_LDSI_v3')
setDir;

load([TempDatDir 'Simultaneous_HiSpikes.mat'])
corrDataSet  = nDataSet;

load([TempDatDir 'SimultaneousError_HiSpikes.mat'])
timePoint    = timePointTrialPeriod(params.polein, params.poleout, params.timeSeries);
timePoint    = timePoint(2:end-1);
numSession   = length(nDataSet);
xDimSet      = [3, 3, 4, 3, 3, 5, 5, 4, 4, 4, 4];
optFitSet   = [4, 25, 7, 20, 8, 10, 1, 14, 15, 10, 15];
cmap                = cbrewer('div', 'Spectral', 128, 'cubic');

for nSession = 3%1:numSession
    
    Y          = [corrDataSet(nSession).unit_yes_trial; corrDataSet(nSession).unit_no_trial];
    numYesTrial = size(corrDataSet(nSession).unit_yes_trial, 1);
    numNoTrial  = size(corrDataSet(nSession).unit_no_trial, 1);
    Y          = permute(Y, [2 3 1]);
    T          = size(Y, 2);
    xDim       = xDimSet(nSession);
    optFit     = optFitSet(nSession);
    load ([TempDatDir 'SessionHi_' num2str(nSession) '_xDim' num2str(xDim) '_nFold' num2str(optFit) '.mat'],'Ph');
    [~, y_est, ~] = loo (Y, Ph, [0, timePoint, T]);
    totTargets    = [true(numYesTrial, 1); false(numNoTrial, 1)];
    nSessionData  = permute(y_est, [3 1 2]);
    nSessionData  = normalizationDim(nSessionData, 2);  
    coeffs        = coeffLDA(nSessionData, totTargets);
    mean_scoreMat = nan(1, size(nSessionData, 3));
    for nTime     = 1:size(nSessionData, 3)
        tscoreMat = squeeze(nSessionData(:, :, nTime)) * coeffs(:, nTime);
        mean_scoreMat(:, nTime) = mean(tscoreMat);
    end

    Y          = [nDataSet(nSession).unit_yes_trial; nDataSet(nSession).unit_no_trial];
    numYesTrial = size(nDataSet(nSession).unit_yes_trial, 1);
    numNoTrial  = size(nDataSet(nSession).unit_no_trial, 1);
    numTrials   = numYesTrial + numNoTrial;
    Y          = permute(Y, [2 3 1]);
    yDim       = size(Y, 1);
    T          = size(Y, 2);
    
    xDim       = xDimSet(nSession);
    optFit     = optFitSet(nSession);
    load ([TempDatDir 'SessionHi_' num2str(nSession) '_xDim' num2str(xDim) '_nFold' num2str(optFit) '.mat'],'Ph');
    [~, y_est, ~] = loo (Y, Ph, [0, timePoint, T]);
            
    yesActMat   = nan(size(Y, 1), length(params.timeSeries));
    noActMat    = nan(size(Y, 1), length(params.timeSeries));
    timePoints  = timePointTrialPeriod(params.polein, params.poleout, params.timeSeries);
    contraIndex = false(size(Y,1), 1);

    for nUnit   = 1:size(Y, 1)
        yesTrial = squeeze(mean(Y(nUnit,:, 1:numYesTrial), 3));
        noTrial  = squeeze(mean(Y(nUnit,:, 1+numYesTrial:end), 3));
        yesActMat(nUnit, :)  = yesTrial;
        noActMat(nUnit, :)   = noTrial;
        contraIndex(nUnit)   = sum(noTrial(timePoints(2):end))<sum(yesTrial(timePoints(2):end));
    end


    figure

    totTargets    = [true(numYesTrial, 1); false(numNoTrial, 1)];
    nSessionData  = permute(y_est, [3 1 2]);
    nSessionData  = normalizationDim(nSessionData, 2);  
%     coeffs        = coeffLDA(nSessionData, totTargets);
    scoreMat      = nan(numTrials, size(nSessionData, 3));
    for nTime     = 1:size(nSessionData, 3)
        scoreMat(:, nTime) = squeeze(nSessionData(:, :, nTime)) * coeffs(:, nTime);
        scoreMat(:, nTime) = scoreMat(:, nTime) - mean(scoreMat(:, nTime)); %mean_scoreMat(:, nTime);%mean(scoreMat(:, nTime));
    end

    subplot(2, 2, 1)
    hold on
    maxTrialYes = min(8, numYesTrial);
    maxTrialNo  = min(8, numNoTrial);
    plot(params.timeSeries, scoreMat(1:maxTrialYes, :), '-b')
    plot(params.timeSeries, scoreMat(numYesTrial+1:numYesTrial+maxTrialNo, :), '-r')
    ylim([-0.8 0.8])
    gridxy ([params.polein, params.poleout, 0],[], 'Color','k','Linestyle','--','linewid', 0.5);
    xlim([min(params.timeSeries) max(params.timeSeries)]);
    box off
    hold off
    xlabel('Time (s)')
    ylabel('LDA score')
    title(['Score using instantaneous LDA - contra/ipsi: ' num2str(sum(contraIndex)) '/' num2str(sum(~contraIndex))])
    set(gca, 'TickDir', 'out')
    set(gca, 'YTick', -0.8:0.4:0.8)
    simCorrMat    = corr(scoreMat, 'type', 'Spearman');

    subplot(2, 2, 2)
    hold on
    imagesc(params.timeSeries, params.timeSeries, simCorrMat);
    xlim([min(params.timeSeries) max(params.timeSeries)]);
    ylim([min(params.timeSeries) max(params.timeSeries)]);
    caxis([0 1]);
    axis xy;
    gridxy ([params.polein, params.poleout, 0],[params.polein, params.poleout, 0], 'Color','k','Linestyle','--','linewid', 0.5);
    box off;
    hold off;
    xlabel('LDA score Time (s)')
    ylabel('LDA score Time (s)')
    colormap(cmap)
    title('LDA score rank similarity')
    set(gca, 'TickDir', 'out')
    
    if numYesTrial > 3
        simCorrMat   = (corr(scoreMat(1:numYesTrial, :), 'type', 'Spearman'));% abs(corr(scoreMat(1:numYesTrial, :), 'type', 'Spearman'));
        subplot(2, 2, 3)
        hold on
        imagesc(params.timeSeries, params.timeSeries, simCorrMat);
        xlim([min(params.timeSeries) max(params.timeSeries)]);
        ylim([min(params.timeSeries) max(params.timeSeries)]);
        caxis([0 1]);
        axis xy;
        gridxy ([params.polein, params.poleout, 0],[params.polein, params.poleout, 0], 'Color','k','Linestyle','--','linewid', 0.5);
        box off;
        hold off;
        xlabel('LDA score Time (s)')
        ylabel('LDA score Time (s)')
        colormap(cmap)
        title('LDA score rank similarity -- contra')
        set(gca, 'TickDir', 'out')
    end
    
    if numNoTrial > 3
        simCorrMat   = (corr(scoreMat(1+numYesTrial:end, :), 'type', 'Spearman')); % abs(corr(scoreMat(1+numYesTrial:end, :), 'type', 'Spearman'));
        subplot(2, 2, 4)
        hold on
        imagesc(params.timeSeries, params.timeSeries, simCorrMat);
        xlim([min(params.timeSeries) max(params.timeSeries)]);
        ylim([min(params.timeSeries) max(params.timeSeries)]);
        caxis([0 1]);
        axis xy;
        gridxy ([params.polein, params.poleout, 0],[params.polein, params.poleout, 0], 'Color','k','Linestyle','--','linewid', 0.5);
        box off;
        hold off;
        xlabel('LDA score Time (s)')
        ylabel('LDA score Time (s)')
        colormap(cmap)
        title('LDA score rank similarity -- ipsi')
        set(gca, 'TickDir', 'out')
    end

    setPrint(8*2, 6*2, ['Plots/TLDSLDASimilarityErrorSesssionCorrectLDA_idx_' num2str(nSession, '%02d') '_xDim_' num2str(xDim)])
end

close all