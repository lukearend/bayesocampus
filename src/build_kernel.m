function G = build_kernel(bin_size,sigma)
%{
Build an N-dimensional Gaussian kernel according to a specified bandwidth.

    Args:
		bin_size: length-N vector containing the bin size for each stimulus
		dimension
		sigma: length-N vector containing the bandwidth along each
        dimension for the Gaussian kernel.

    Returns:
        counts: N-dimensional array containing the number of data points
        which landed in each occupancy bin.
%}

% Figure out the size of the N-dimensional Gaussian kernel.
N = length(sigma);  % Number of stimulus dimensions.
grid_vectors = cell(1,N);   % Coordinates in dimension N for each bin.
kernel_size = zeros(1,N);   % Size of the kernel along each dimension.
for i = 1:N
    % Ensure that the kernel is at least 2 standard-deviations wide.
    w = ceil(2*sigma(i)/bin_size(i));
    grid_vectors{i} = -w:w;
    kernel_size(i) = length(grid_vectors{i});
end

% Construct a list of the coordinates at each bin inside the kernel.
tmp = cell(N,1);
[tmp{:}] = ndgrid(grid_vectors{:});
X = zeros(numel(tmp{1}),N);
for i = 1:N
    X(:,i) = tmp{i}(:);   % k x N matrix, k is the total number of bins.
end

% Compute the N-dimensional kernel from a multivariate Gaussian PDF.
mu = zeros(1,length(sigma));
G = mvnpdf(X,mu,diag(sigma)); % Get the kernel value at each point.
if length(kernel_size) == 1
    kernel_size = [1,kernel_size];
end
G = reshape(G,kernel_size); % Shape the kernel to its N-dimensional size.
G = G/sum(G(:));    % Normalize.

end
