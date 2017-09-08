% S4_ISC_statistics
% analysis Qihuang data 
% 2017.9.8
% author: LJW


%% load ISC data
p = pwd;
data_path = strcat(p,'/ISC_result_data/ISC_total_result');
load(data_path);

%% channel number
chn_number = 28;

%% data name
group_number = 1 : 3;
group_label = {'CAU','QH','Pro'};
select_group = 1;


time_label = {'baseline','begin','middle','end'};

for i = 1  : length(time_label)
    data_set_name = strcat('ISC_',group_label{select_group},'_',time_label{i});
    Game_number = eval(strcat('length(fieldnames(',data_set_name,'))'));
    game_total = cell(Game_number,1);
    game_mean = zeros(chn_number,Game_number);
    
    for j = 1 : Game_number
        select_game_name = strcat('ISC_',group_label{select_group},'_',time_label{i},'.','ISC_',group_label{select_group},'_Game',num2str(j));
        select_game_data = eval(select_game_name);
        temp_mat = zeros(chn_number,length(select_game_data));
        
        for n = 1 : length(select_game_data)
            % preprocess: delete all zero col
            [x_ind, y_ind] = find(select_game_data{n}==0);
            select_game_data{n}(:,unique(y_ind)) = [];
            
            %average
            temp_mat(:,n) = mean(select_game_data{n},2); 
        end
        game_total{j} =  temp_mat;
        game_mean(:,j) = mean(temp_mat,2);
    end
    
end