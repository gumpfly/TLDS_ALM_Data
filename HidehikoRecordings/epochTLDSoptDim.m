addpath('../Func');
addpath('../Release_LDSI_v3')
setDir;

load([TempDatDir 'Simultaneous_HiSpikes.mat'])
mean_type    = 'Constant_mean';
tol          = 1e-6;
cyc          = 10000;
timePoint    = timePointTrialPeriod(params.polein, params.poleout, params.timeSeries);
timePoint    = timePoint(2:end-1);
numSession   = length(nDataSet);
xDimSet      = [3, 3, 3, 3, 2, 5, 5, 4, 4, 4, 4, 5, 4, 4, 4, 4, 4, 3;
                0, 0, 4, 0, 3, 0, 0, 0, 0, 0, 0, 6, 6, 0, 5, 5, 6, 0];
nFold        = 30;

for nSession = 1:numSession
    Y          = [nDataSet(nSession).unit_yes_trial; nDataSet(nSession).unit_no_trial];
    Y          = permute(Y, [2 3 1]);
    T          = size(Y, 2);
    for nDim   = 1:size(xDimSet, 1)
        xDim       = xDimSet(nDim, nSession);
        if xDim>0
            curr_err   = nan(nFold, 1);
            for n_fold = 1:nFold
                is_fit     = false;
                while ~is_fit
                    try
                        Ph         = lds(Y, xDim, 'tol', tol, 'cyc', cyc, 'mean_type',mean_type, 'timePoint', timePoint);
                        is_fit     = true;
                    catch
                        is_fit     = false;
                    end
                end
                [curr_err(n_fold),~] = loo (Y, Ph, [0, timePoint, T]);
                save([TempDatDir 'SessionHi_' num2str(nSession) '_xDim' num2str(xDim) '_nFold' num2str(n_fold) '.mat'],'Ph');
            end
            [~, optFit] = min(curr_err);
            disp([numSession, xDim, optFit])
        end
    end
end

close all