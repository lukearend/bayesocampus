function D_KL = gamma_KL_divergence(alpha_P,beta_P,alpha_Q,beta_Q)
%{
Compute the KL divergence between two gamma distributions using the
equation given in W.D. Penny, KL-Divergences of Normal, Gamma, Dirichlet,
and Wishart densities (available at
www.fil.ion.ucl.ac.uk/~wpenny/publications/densities.ps).

    Args:
        alpha_P: alpha parameter of distribution P.
        beta_P: beta parameter of distribution P.
        alpha_Q: alpha parameter of distribution Q.
        beta_Q: beta parameter of distribution Q.

        alpha_P and beta_P may be scalars or vectors of equal length.
        alpha_Q and beta_Q must be scalars or vectors of length alpha_P.

    Returns:
        D_KL: KL divergence between distributions P and Q.

        D_KL will have the size equal to alpha_P.
%}

D_KL = (alpha_Q - 1).*psi(alpha_Q) + log2(beta_Q) - alpha_Q...
     + log2(gamma(alpha_P)./gamma(alpha_Q)) - alpha_P.*log2(beta_P)...
     - (alpha_P - 1).*(psi(alpha_Q) - log2(beta_Q))...
     + beta_P.*alpha_Q./beta_Q;
end
