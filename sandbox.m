clear
addpath('src')

%%
file_path = '../EichenbaumData/AJF023/EF3/AJF023EF3SpksEvs.mat';
[spikes,X,t,sample_rate] = load_data_xy(file_path);

%%
t_start = t(1);
t_end = t(end);
sigma = [3 3 3];
bin_size = [3 3 3];
f_base = 2;
min_t_occ = 0.5;

[coords,alpha,beta] = build_NB_tuning_curves(spikes,X,t,sample_rate,t_start,t_end,bin_size,sigma,f_base,min_t_occ);

%%
IC_curves = get_IC_curves(alpha,beta,f_base,min_t_occ);

%%
for i = 1:size(alpha,1)
    subplot(1,2,1);
    plot_tuning_curves(coords,alpha(i,:,:),beta);
    subplot(1,2,2);
    plot_IC_curves(coords,IC_curves(i,:,:));
    
    waitforbuttonpress;
end