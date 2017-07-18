function plot_tuning_curves(coords,alpha,beta)
%{
Visualize tuning curves.

    Args:
        coords: N x 1 cell array of coordinate locations:
            coords{1}: N-dimensional array of the coordinate position for
            each bin in stimulus dimension 1.
            coords{2}: N-dimensional array of the coordinate position for
            each bin in stimulus dimension 2.
            ...

        -and-

        alpha: (N+1)-dimensional array of alpha parameter for each bin,
        where N is the number of stimulus dimensions and the size of the
        first dimension is the number of tuning curves.
        beta: N-dimensional array of beta parameter for each bin.

        -or-

        lambda: (N+1)-dimensional array of mean firing rate for each bin.
%}

N = length(coords);
num_curves = size(alpha,1);

% Check which type of tuning curve to plot.
if nargin < 3
    % Mean firing rate for Poisson tuning curve.
    lambda = alpha;
else
    % Mean firing rate for negative binomial tuning curve.
    beta_rep = repmat(permute(beta,[N+1 1:N]),[num_curves ones(1,N)]);
    lambda = (alpha - 1)./beta_rep;
end

for i = 1:num_curves
    % Plot the curve.
    if N == 1
        % Plot 1-dimensional curve.
        plot(coords{1},lambda(i,:))

        xlabel('Stimulus 1')
        ylabel('Mean firing rate (Hz)')
    elseif N == 2
        % Plot 2-dimensional curve.
        [X,Y] = coords{:};
        surf(X',Y',squeeze(lambda(i,:,:))','EdgeColor','None');
        view(2);

        colorbar;
        tmp = lambda(i,:,:);
        caxis([min(tmp(:)) max(tmp(:))])

        xlabel('Stimulus 1')
        ylabel('Stimulus 2')

        axis equal;
    else
        fprintf('3- and higher-dimensional curves not yet supported.');
        return;
    end

    % Make it pretty!
    colormap summer;

    title(sprintf('Tuning curve %d of %d',i,num_curves));

    ax = gca;
    ax.FontSize = 12;
    ax.FontWeight = 'b';
    ax.LineWidth = 1;

    if i < num_curves
        waitforbuttonpress;
    end
end

end