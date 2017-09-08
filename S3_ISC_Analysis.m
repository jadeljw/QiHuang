% S3_ISC_Analysis

%% load data
p = pwd;
group_number = 1 : 3;
group_label = {'CAU','QH','Pro'};
select_group = 1;
load(strcat(p,'/Group_data/EEG_data_resample_group',num2str(select_group)));

%% initial data structure
time_label = {'baseline','begin','middle','end'};
player_number = 5;
Game_number = length(data)/player_number;
clip_length = 5;
clip_number = 5 * 60 /clip_length;


for i = 1  : length(time_label)
    eval(strcat('ISC_',group_label{select_group},'_',time_label{i},'=[];'));
    for j = 1 : Game_number
        data_name = strcat('ISC_',group_label{select_group},'_',time_label{i},'.','ISC_',group_label{select_group},'_Game',num2str(j));
        eval(strcat(data_name, '= cell(clip_number,1);'));
%         eval(strcat(data_name, '= zeros(28,combntns(play_number,2))'));
    end
end

%% data property
Fs = 50;
chn_number = 28;
% Game_start_index = 1 : 5 :length(data);

%% ISC process
for n = 1 :length(time_label)
    
    for j = 1 : Game_number
        select_Game_number = (j-1)*player_number + 1 : j * player_number;
        
        for i = 1 : clip_number
            select_time_index = (i-1) *  clip_length * Fs + 1 : (i-1) * clip_length * Fs + clip_length * Fs;
            
            % ISC
            temp_data  = zeros(28,combntns(player_number,2));
            cnt = 1;
            for ii = select_Game_number
                for jj =select_Game_number
                    if jj > ii
                        
                        % void or not
                        if ~isempty(data{ii}) && ~isempty(data{jj})
                            
                            for chn = 1 : chn_number
                                % nΪdatalabel 2->baseline; 3->begin; 4->middel; 5->end 
                                temp_data(chn ,cnt) = corr(data{ii}{n+1}(chn,select_time_index)',data{jj}{n+1}(chn,select_time_index)');
                            end
                        end
                        cnt = cnt + 1;
                    end
                end
            end
            
            data_name = strcat('ISC_',group_label{select_group},'_',time_label{n},'.','ISC_',group_label{select_group},'_Game',num2str(j),'{i}');
            eval(strcat(data_name, '= temp_data;'));
        end
    end
    save_data_name = strcat('ISC_',group_label{select_group},'_',time_label{n},'.mat');
    save(save_data_name,save_data_name(1:end-4));
end


