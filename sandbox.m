clear
addpath('src')

%%
file_path = '../EichenbaumData/AJF023/EF3/AJF023EF3SpksEvs.mat';
[spikes,X,t,sample_rate] = load_data_xy(file_path);

%%
t_start = t(1);
t_end = t(end);
sigma = [3 3];
bin_size = [3 3];
f_base = 2;
min_t_occ = 0.5;

[~,lambda] = build_tuning_curves('poisson',spikes,X,t,sample_rate,t_start,t_end,bin_size,sigma);
[coords,alpha,beta] = build_tuning_curves('negative_binomial',spikes,X,t,sample_rate,t_start,t_end,bin_size,sigma,f_base,min_t_occ);

%%
IC_curves = get_IC_curves(alpha,beta,f_base,min_t_occ);

%%
K = size(lambda,1);
for i = 1:K
    subplot(3,1,1);
    plot_curves('tuning_curve',coords,lambda(i,:,:));
    title(sprintf('Poisson-based tuning curve %d of %d',i,K));
    subplot(3,1,2);
    plot_curves('tuning_curve',coords,alpha(i,:,:),beta);
    title(sprintf('Negative binomial-based tuning curve %d of %d',i,K));
    subplot(3,1,3);
    plot_curves('IC_curve',coords,IC_curves(i,:,:));
    title(sprintf('Information content curve %d of %d',i,K));
    
    waitforbuttonpress;
end