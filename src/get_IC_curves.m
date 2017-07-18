function IC_curves = get_IC_curves(alpha,beta,f_base,min_t_occ)
%{
Compute information content curves for a set of tuning curves by finding
the KL divergence between the posterior over firing rate at each location
and the posterior if firing rate is averaged across all locations.

    Args:
        alpha: (N+1)-dimensional array of alpha parameter for each bin,
        where N is the number of stimulus dimensions and the size of the
        first dimension is the number of tuning curves.
        beta: N-dimensional array of beta parameter for each bin.
        f_base: f_base parameter used to construct tuning curves.
        min_t_occ: min_t_occ parameter used to construct tuning curves.

    Returns:
        information_content: (N+1)-dimensional array of information content
        for each bin, where the size of the first dimension is the number
        of tuning curves.
%}

% Find the empties.
empties = isnan(beta);

alpha_0 = f_base*min_t_occ;
beta_0 = min_t_occ;

beta_P = beta(~empties);
beta_P = beta_P(:);

IC_curves = zeros(size(alpha));
IC_curves(:,empties) = nan;

num_curves = size(alpha,1);
for i = 1:num_curves
    % Reverse-engineer the tuning curve and build an uniform tuning curve Q
    % from the mean spike counts agnostic of location in stimulus space.
    alpha_P = alpha(i,~empties);
    alpha_P = alpha_P(:);
    
    n = alpha_P - alpha_0;
    t_occ = beta_P - beta_0;

    mean_n = mean(n);
    mean_t_occ = mean(t_occ);

    alpha_Q = mean_n + alpha_0;
    beta_Q = mean_t_occ + beta_0;
    
    % Compute the KL divergence between these tuning curves at each bin.
    D_KL = gamma_KL_divergence(alpha_P,beta_P,alpha_Q,beta_Q);

    % Fill in the map.
    IC_curves(i,~empties) = D_KL;
end

end
