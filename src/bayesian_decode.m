function [posterior] = bayesian_decode(spikes,t_start,t_end,alpha,beta)
%{
Perform Bayesian decoding on spiking data to produce a posterior
distribution over stimulus space.
    
	Args:
		spikes: 1xK cell array of spiking data, where K is the number of
        units:
			spikes{1}: vector of timestamps for the spikes at unit 1.
			spikes{2}: vector of timestamps for the spikes at unit 2.
			...
		t_start: vector of start times for decoding steps.
		t_end: vector of end times for decoding steps (must have same
        length as t_start).
        
        -and-

        lambda: (N+1)-dimensional array of mean firing rate for each bin,
        where the size of the first dimension is the number of units.
    
        (to perform decoding using Poisson tuning curves)

        -or-

        alpha: (N+1)-dimensional array of alpha parameter for each bin,
        where the size of the first dimension is the number of units.
        beta: N-dimensional array of beta parameter for each bin.
    
        (to perform decoding using negative binomial tuning curves)

	Returns:
		posterior: N-dimensional array of posterior probability for each
        bin in feature space.
%}

% Discern which tuning curve type to use based on the number of arguments.
if nargin == 4
    type_is_poisson = true;
else
    type_is_poisson = false;
end

K = length(spikes); % Number of units.
M = length(t_start);    % Number of decoding steps.

% Build the population vector specifying activity at each decoding step.
pop_vec = zeros(K,M);
for i = 1:K
    ts = spikes{i};
    
    % Interleave t_start with t_stop to get bin edges.
    bin_edges = reshape([t_start;t_end],1,[]);
    
    % Get the number of spikes in each bin.
    counts_per_bin = histcounts(ts,bin_edges);
    
    % Use the number of spikes that land between each t_start and t_stop.
    pop_vec(i,:) = counts_per_bin(1:2:end);
end

tau = t_end - t_start; % Decoding timesteps.

% Get the number of stimulus dimensions from tuning curve size.
N = length(size(alpha)) - 1;

% Get the size of the occupancy space in bins.
if N == 1
    occ_size = size(alpha,2);

    index_mask = true(occ_size,1);
else
    tmp = size(alpha);
    occ_size = tmp(2:end);

    index_mask = true(occ_size);
end

% Find the empties.
empties = isnan(alpha(1,index_mask));

k = numel(empties); % Number of bins in stimulus space.

% Loop over occupancy space, performing decoding on each bin.
posterior = zeros([M occ_size]);
for i = 1:k
    % Short-circuit the computation for empty bins.
    if empties(i)
        continue;
    end
    
    % Get the subscript indices for the bin with linear index k.
    sub_index = cell(1,N);
    [sub_index{:}] = ind2sub(occ_size,i);
    
    if type_is_poisson
        % 'alpha' function argument is taken as the tuning curve lambda.
        lambda = repmat(alpha(:,sub_index{:}),1,M); % K x M
        tau_lambda = repmat(tau,K,1).*lambda;
        
        % Poisson-based decoding.
        posterior_for_bin = prod(poisspdf(pop_vec,tau_lambda));
    else
        % r = alpha.
        r = repmat(alpha(:,sub_index{:}),1,M);  % K x M
        
        % p = (beta/tau)/(1 + (beta/tau)).
        beta_over_tau = repmat(beta(sub_index{:}),K,M)./repmat(tau,K,1);
        p = beta_over_tau./(1 + beta_over_tau); % K x M
        
        % Negative binomial-based decoding.
        posterior_for_bin = prod(nbinpdf(pop_vec,r,p));
    end
    posterior(:,sub_index{:}) = posterior_for_bin;
end

% Compute the normalizing constant for the posterior at each time step.
c = sum(reshape(posterior,M,prod(occ_size)),2);
c = repmat(c,[1 occ_size]);

% Normalize the posterior.
posterior = posterior./c;

posterior(:,empties) = nan;

end
