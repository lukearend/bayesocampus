function [spikes,X,t,sample_rate] = load_data_xy(file_path)
%{
Load raw data from file.

    Args:
        file_path: string indicating the path to the data file to load.

    Returns:
        spikes: 1xK cell array of spiking data, where K is the number of units:
            spikes{1}: vector of timestamps for each spike at unit 1.
            spikes{2}: vector of timestamps for each spike at unit 2.
            ...
        X: NxM array of ground-truth stimulus features, where N is the number of
        stimulus dimensions and M is the number of sampling timestamps.
        t: 1xM array of timestamps for ground-truth stimulus sampling.
        sample_rate: sample rate of ground-truth data.
%}

% Extract the data.
load(file_path);

spikes = cell(size(unitdata.units));
for i = 1:length(unitdata.units)
    spikes{i} = unitdata.units(i).ts;
end

tmp = unitdata.rawLEDs;
X = tmp(:,2:3)';
t = tmp(:,1)';

% Preprocess the data.
pixels_to_cm = 1/4.2;

X = X*pixels_to_cm;

% Find errors in video sampling.
max_sampling_rate_error = 0.03;  % Maximum sampling rate error allowed.

diff_t = diff(t);
sample_rate = median(diff_t);
error_indices = find(abs(diff_t - sample_rate) > max_sampling_rate_error);

if error_indices
    fprintf('Found %d video sampling errors:\n', length(error_indices));
    for i = 1:length(error_indices)
        if diff_t(error_indices(i)) - sample_rate > 0
            error_type = 'skips';
        else
            error_type = 'repeats';
        end
        t0 = t(error_indices(i));
        t1 = t(error_indices(i)+1);
        fprintf('Warning %d: t(%d) %s from %d to %d (dt = %d)\n',...
            i,error_indices(i),error_type,t0,t1,t1 - t0);
    end
end

% Find video position blanks and replace them with interpolated data.
nan_index = find(isnan(X(1,:)));
ttmp = t;
Xtmp = X;
ttmp(nan_index) = [];
Xtmp(:,nan_index) = [];
X_during_nan = interp1(ttmp,Xtmp',t(nan_index))';
X(:,nan_index) = X_during_nan;