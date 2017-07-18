function [coords,lambda] = build_poisson_tuning_curves(...
    spikes,X,t,sample_rate,t_start,t_end,bin_size,sigma)
%{
Build tuning curves from spiking data by estimating the firing rate at each
location.

	Args:
		spikes: 1 x K cell array of spiking data, where K is the number
        of units:
			spikes{1}: vector of timestamps for each spike at unit 1.
			spikes{2}: vector of timestamps for each spike at unit 2.
			...
		X: N x M array of ground-truth stimulus features, where N is the
        number of stimulus dimensions and M is the number of sampling
        timestamps.
		t: 1 x M array of timestamps for ground-truth stimulus sampling.
        sample_rate: sample rate of ground-truth data.
		t_start: vector of start times for sampling windows over which to
        construct tuning curves.
		t_end: vector of end times for sampling windows over which to
        construct tuning curves (must be same length as t_start).
		bin_size: length-N vector containing the bin size to use for each
        stimulus dimension.
		sigma: length-N vector containing the bandwidth along each
        dimension for the Gaussian kernel used to smooth occupancy and
        spike counts.

    Returns:
        coords: N x 1 cell array of coordinate locations, where N is the
        number of stimulus dimensions:
            coords{1}: N-dimensional array of the coordinate position for
            each bin in stimulus dimension 1.
            coords{2}: N-dimensional array of the coordinate position for
            each bin in stimulus dimension 2.
            ...
		lambda: (N+1)-dimensional array of mean firing rate for each bin,
        where the size of the first dimension is the number of units.
%}

% Only use ground-truth data from the specified intervals.
t_use = get_interval_logical(t,t_start,t_end);

X = X(:,t_use);
t = t(t_use);

% Put the ground-truth stimulus data into bins.
N = size(X,1);  % Dimensionality of stimulus data.
X_b = zeros(size(X));
grid_vectors = cell(1,N); % Coordinates in dimension N for each bin.
occ_size = zeros(1,N);  % The size (in bins) of the occupancy space.
for i = 1:N
    % Get the locations of every bin along this dimension.
    bins = min(X(i,:)):bin_size(i):max(X(i,:)) + bin_size(i)/2;
    grid_vectors{i} = bins;
    occ_size(i) = length(grid_vectors{i});
    
    bin_indices = 1:occ_size(i);
    
    X_b(i,:) = interp1(bins,bin_indices,X(i,:),'nearest');
end

% Get coordinates for each bin.
coords = cell(N,1);
[coords{:}] = ndgrid(grid_vectors{:});

% Get occupancy.
t_occ = get_bin_counts(X_b,occ_size)*sample_rate;

empties = t_occ == 0;

% Smooth occupancy by convolving with a Gaussian kernel.
G = build_kernel(bin_size,sigma);
t_occ = convn(t_occ,G,'same');

t_occ(empties) = nan;

% Construct an estimate of mean firing rate over occupancy space.
if N == 1
    assign_mask = true(occ_size,1);
else
    assign_mask = true(occ_size);
end

K = length(spikes); % Number of units.
lambda = zeros([K occ_size]);
for i = 1:K
    ts = spikes{i};
    
    % Only use spike data from the specified intervals.
    ts_use = get_interval_logical(ts,t_start,t_end);
    ts = ts(ts_use);
    
    % Put the spiking data into bins in stimulus space.
    ts_b = interp1(t,X_b',ts,'nearest')';
    
    % Get spike counts at each location.
    n = get_bin_counts(ts_b,occ_size,empties);
    
    % Smooth spike counts.
    n = convn(n,G,'same');
    
    % Compute the mean firing rate estimate.
    mean_firing_rate = n./t_occ;
    
    lambda(i,assign_mask) = mean_firing_rate(:);
    lambda(i,empties) = nan;
end

end
