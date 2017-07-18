function counts = get_bin_counts(X_b,occ_size,empties)
%{
Return counts of a timestamped array which are between any t_start-t_stop
pair (vectorized).

    Args:
        X_b: N x M array of binned data points, where N is the number of
        stimulus dimensions and M is the number of samples.
        occ_size: N-length array specifying dimensions of occupancy space
        in bins.
        empties: (optional) N-dimensional logical array indicating
        unoccupied bins.

    Returns:
        counts: N-dimensional array containing the number of data points
        which landed in each occupancy bin.
%}

% Check for empties.
if nargin < 3
    empties = false(occ_size);
end
empties = empties(:);   % Unroll empties.

N = size(X_b,1);    % Number of stimulus dimensions.
M = size(X_b,2);    % Number of samples.
k = prod(occ_size); % Number of bins in the whole occupancy space.

% Get the subscript indices for each bin as an N-element column vector.
tmp = cell(N,1);
[tmp{:}] = ind2sub(occ_size,1:k);
sub_indices = cell2mat(tmp); % N x k

% Loop over the occupancy space, gathering counts.
counts = zeros(1,k);
for i = 1:k
    % Short-circuit the computation for empty bins.
    if empties(i)
        continue;
    end
    
    % Check for hits across the whole sampling period.
    check_mask = true(1,M);
    for n = 1:N
        % For each successive dimension, only check the hits found before.
        check_mask = sub_indices(n,i) == X_b(n,check_mask);
    end

    % Add up the number of hits over the full sampling period.
    counts(i) = sum(check_mask);
end

% Reshape to N-dimensional size.
if N == 1
    occ_size = [occ_size,1];
end
counts = reshape(counts,occ_size);

end
