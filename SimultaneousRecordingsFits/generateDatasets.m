%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0.  Generate raw activity of all neurons sorted in different ways
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Comparison_V2_0

addpath('../Func');
setDir;

minNumTrialToAnalysis  = 20;
params.frameRate       =  29.68/2;
params.binsize         =  1/params.frameRate;
params.polein          =  -2.6;
params.poleout         =  -1.3;
minTimeToAnalysis      =  round(-3.1 * params.frameRate);
maxTimeToAnalysis      =  round(2.0 * params.frameRate);
params.timeWindowIndexRange  = minTimeToAnalysis : maxTimeToAnalysis;
params.timeSeries      = params.timeWindowIndexRange * params.binsize;
params.minNumTrialToAnalysis =  minNumTrialToAnalysis;
params.expression      = 'None';
minFiringRate          = 5; % Hz per epoch
nDataSet               = getSpikeDataWithEphysTime(SpikingDataDir, SpikeFileList, params.minNumTrialToAnalysis, params.timeSeries, params.binsize);                                  
ActiveNeuronIndex      = findHighFiringUnits(nDataSet, params, minFiringRate);
CR                     = getBehavioralPerformance(SpikingDataDir, SpikeFileList);



nDataSetOld            = nDataSet;
ActiveNeuronIndexOld   = ActiveNeuronIndex;
CROld                  = CR;
nDataSet               = getSpikeDataWithEphysTime(SpikingDataDir2, SpikeFileList2, params.minNumTrialToAnalysis, params.timeSeries, params.binsize);                                  
ActiveNeuronIndex      = findHighFiringUnits(nDataSet, params, minFiringRate);
CR                     = getBehavioralPerformance(SpikingDataDir2, SpikeFileList2);

for nUnit = 1:length(nDataSet)
    nDataSet(nUnit).sessionIndex  = nDataSet(nUnit).sessionIndex + length(SpikeFileList);
end

nDataSet               = [nDataSetOld; nDataSet];
ActiveNeuronIndex      = [ActiveNeuronIndexOld; ActiveNeuronIndex];
CR                     = [CROld; CR];

save([TempDatDir 'Shuffle_Spikes.mat'], 'nDataSet', 'params', 'ActiveNeuronIndex', 'CR');