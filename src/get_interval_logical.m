function t_use = get_interval_logical(t,t_start,t_end)
%{
Return logicals of a timestamped array which are between any t_start-t_stop
pair (vectorized).

    Args:
        t: array of sequential timestamps.
        t_start: array of interval start times.
        t_end: array of interval end times.

    Returns:
        t_use: logical of whether each t is within an interval.
%}

t_use = zeros(size(t));

% Interleave t_start with t_end and produce a histogram of the number of
% t's which fall in each bin.
counts_per_bin = histcounts(t,[0 reshape([t_start;t_end],1,[]) inf]);

% Collect the counts from start up through each of those bins.
cum_counts_per_bin = cumsum(counts_per_bin);

% Get the number of counts in every 'keep' bin.
keep_counts = counts_per_bin(2:2:end);

% Set indices of 'keep' timestamps to 1.
t_use((1:sum(keep_counts)) + repelem(cum_counts_per_bin(1:2:end-1)...
    - [0 cumsum(keep_counts(1:end-1))],keep_counts)) = 1;

t_use = logical(t_use);

end
