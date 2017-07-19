function plot_curves(type,coords,curves,beta)
%{
Visualize a set of curves.

    Args:
        type: Type of curve to plot - must be 'tuning_curve', 'IC_curve',
        or 'posterior'.
        coords: N x 1 cell array of coordinate locations:
            coords{1}: N-dimensional array of the coordinate position for
            each bin in stimulus dimension 1.
            coords{2}: N-dimensional array of the coordinate position for
            each bin in stimulus dimension 2.
            ...
        curves: (N+1)-dimensional array of curves to plot, where N is the
        number of stimulus dimensions and the size of the first dimension
        is the number of curves.

        -optional-

        beta: N-dimensional array of beta parameter for each bin. If this
        argument is supplied, then 'curves' is taken as alpha parameter for
        negative binomial tuning curves.
%}

N = length(coords);
num_curves = size(curves,1);

if strcmp(type,'tuning_curve')
    if nargin == 4
        % Compute firing rate for negative binomial tuning curve.
        beta_rep = repmat(permute(beta,[N+1 1:N]),[num_curves ones(1,N)]);
        curves = (curves - 1)./beta_rep;
    end
    
    intensity_axis_label = 'Mean firing rate (Hz)';
    title_base = 'Tuning curve';
elseif strcmp(type,'IC_curve')
    intensity_axis_label = 'Information content (bits)';
    title_base = 'Information content map';
elseif strcmp(type,'posterior')
    intensity_axis_label = 'Posterior probability';
    title_base = 'Posterior distribution';
else
    fprintf('Curve type ''%s'' not recognized.\n',type);
    return;
end

for i = 1:num_curves
    % Plot the curve.
    if N == 1
        % Plot 1-dimensional curve.
        bar(coords{1},curves(i,:));

        xlabel('Stimulus 1');
        ylabel(intensity_axis_label);
    elseif N == 2
        % Plot 2-dimensional curve.
        [X,Y] = coords{:};
        surf(X',Y',squeeze(curves(i,:,:))','EdgeColor','None');
        view(2);

        colorbar;
        tmp = curves(i,:,:);
        caxis([min(tmp(:)) max(tmp(:))]);

        xlabel('Stimulus 1');
        ylabel('Stimulus 2');

        axis equal;
    else
        fprintf('3- and higher-dimensional curves not yet supported.\n');
        return;
    end

    % Make it pretty!
    colormap summer;

    title(sprintf('%s %d of %d',title_base,i,num_curves));

    ax = gca;
    ax.FontSize = 12;
    ax.FontWeight = 'b';
    ax.LineWidth = 1;

    if i < num_curves
        waitforbuttonpress;
    end
end

end