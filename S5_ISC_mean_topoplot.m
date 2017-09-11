% S5_ISC_statistics_topoplot
% analysis Qihuang data
% 2017.9.8
% author: LJW


%% load ISC result average data
p = pwd;
data_path = strcat(p,'\ISC_mean_total\ISC_mean_total.mat');
load(data_path);

%% topoplot initial
chn_number = 28;
load('E:\DataProcessing\QiHuang\Channel_overlap.mat');
load('E:\DataProcessing\easycapm1.mat')

%% data name
group_label = {'CAU','QH','Pro'};
time_label = {'baseline','begin','middle','end'};
zlim = 0.008;

for select_group = 1 : length(group_label)
    for i = 1  : length(time_label)
        
        data_set_name = strcat('ISC_',group_label{select_group},'_',time_label{i},'_game_mean');
        plot_data = eval(data_set_name);
        
        % delete NaN
        temp_index = isnan(plot_data);
        [x_ind, y_ind] = find(temp_index);
        plot_data(:,unique(y_ind)) = [];
            
        % topoplot
        save_nameA = strcat('ISC-',group_label{select_group},'-',time_label{i},'.jpg');
        title(save_nameA(1:end-4));
        %             U_topoplot(abs(zscore(train_corr_attend_listener_w)), 'easycapm1.lay', label66(chn2chnName),[],zlim);
        U_topoplot(mean(abs(plot_data),2), 'easycapm1.lay', chan,[],zlim);
        saveas(gcf,save_nameA);
        
    end
end
