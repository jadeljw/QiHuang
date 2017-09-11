% S4_ISC_statistics
% analysis Qihuang data
% 2017.9.8
% author: LJW


%% load ISC result data
p = pwd;
data_path = strcat(p,'/ISC_result_data/ISC_total_result');
load(data_path);

%% channel number
chn_number = 28;

%% data name
group_label = {'CAU','QH','Pro'};
time_label = {'baseline','begin','middle','end'};

%% average process
for select_group = 1 : length(group_label)
    for i = 1  : length(time_label)
        data_set_name = strcat('ISC_',group_label{select_group},'_',time_label{i});
        game_number = eval(strcat('length(fieldnames(',data_set_name,'))'));
        eval(strcat('ISC_',group_label{select_group},'_',time_label{i},'_game_total = cell(game_number,1);'));
        eval(strcat('ISC_',group_label{select_group},'_',time_label{i},'_game_mean = zeros(chn_number,game_number);'));
        %     game_mean = zeros(chn_number,game_number);
        
        for j = 1 : game_number
            select_game_name = strcat('ISC_',group_label{select_group},'_',time_label{i},'.','ISC_',group_label{select_group},'_Game',num2str(j));
            select_game_data = eval(select_game_name);
            temp_mat = zeros(chn_number,length(select_game_data));
            
            for n = 1 : length(select_game_data)
                % preprocess: delete all zero col
                [~, y_ind] = find(select_game_data{n}==0);
                select_game_data{n}(:,unique(y_ind)) = [];
                
                
                %average
                temp_mat(:,n) = mean(select_game_data{n},2);
                
            end
            
            % delete NaN
            temp_index = isnan(temp_mat);
            [x_ind, y_ind] = find(temp_index);
            temp_mat(:,unique(y_ind)) = [];
            
            % record into mat
            eval(strcat('ISC_',group_label{select_group},'_',time_label{i},'_game_total{j} = temp_mat;'));
            eval(strcat('ISC_',group_label{select_group},'_',time_label{i},'_game_mean(:,j) = mean(temp_mat,2)'));
        end
        
        % save data
        save_var_name1 = strcat('ISC_',group_label{select_group},'_',time_label{i},'_game_total');
        save_var_name2 = strcat('ISC_',group_label{select_group},'_',time_label{i},'_game_mean');
        save_data_name = strcat('ISC_mean_',group_label{select_group},'_',time_label{i},'.mat');
        save(save_data_name,save_var_name1,save_var_name2);
    end
    
end


