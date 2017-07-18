function plot_IC_curves(coords,IC_curves)
%{
Visualize information content curves.

    Args:
        coords: N x 1 cell array of coordinate locations:
            coords{1}: N-dimensional array of the coordinate position for
            each bin in stimulus dimension 1.
            coords{2}: N-dimensional array of the coordinate position for
            each bin in stimulus dimension 2.
            ...
        D_KL: (N+1)-dimensional array of information content for each bin,
        where N is the number of stimulus dimensions and the size of the
        first dimension is the number of curves to plot.
%}

N = length(coords);
num_curves = size(IC_curves,1);

for i = 1:num_curves
    % Plot the curve.
    if N == 1
        % Plot 1-dimensional curve.
        plot(coords{1},IC_curves(i,:))

        xlabel('Stimulus 1')
        ylabel('Information content (bits)')
    elseif N == 2
        % Plot 2-dimensional curve.
        [X,Y] = coords{:};
        surf(X',Y',squeeze(IC_curves(i,:,:))','EdgeColor','None');
        view(2);

        colorbar;
        tmp = IC_curves(i,:,:);
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

    title(sprintf('Information content %d of %d',i,num_curves));

    ax = gca;
    ax.FontSize = 12;
    ax.FontWeight = 'b';
    ax.LineWidth = 1;

    if i < num_curves
        waitforbuttonpress;
    end
end

end