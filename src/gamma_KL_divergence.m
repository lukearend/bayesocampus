function D_KL = gamma_KL_divergence(alpha_P,beta_P,alpha_Q,beta_Q)
%{
Compute the KL divergence between two gamma distributions using a
vectorized version of the equation given in Bauckhage 2014.

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

D_KL = (alpha_P - alpha_Q).*(psi(alpha_P) - log2(beta_P))...
      - alpha_Q.*log2(beta_Q) + log2(gamma(alpha_Q))...
      + alpha_P.*log2(beta_P) - log2(gamma(alpha_P))...
      + (gamma(alpha_P + 1)./gamma(alpha_P)).*(beta_Q./beta_P)...
      - alpha_P;
end
