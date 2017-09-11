% % %%% simple analysis after preprocessing
%
%
% for i=1:3
%     load(['EEG_Data_Group' num2str(i)]);
% end
%


%% data organize
clear
load('EEG_SubInfo_0803');
chan_info=load('Channel_overlap');
data_len=5*60;
group_label={'CAU','QH','Pro'};


for i=1:length(SubInfo)
    
    trigger_time=SubInfo{i}.EEGtime(1,1);
    game_begin=SubInfo{i}.EEGtime(1,2);
    game_end=SubInfo{i}.EEGtime(1,3);
    data_label(1,i)=strmatch(SubInfo{i}.Group,group_label);
    if SubInfo{i}.DataUse
        
        data_structure{i}=[];
        
        chan_max(i,:)=ones(1,28);
        
        para_name=[ 'EEG_' SubInfo{i}.Id '_' SubInfo{i}.Group '_' num2str(SubInfo{i}.Game)];
        %         filename=[pwd '\data_pre_HX\data_rejected\' para_name '_HX'];
        filename=[pwd '\data_rejected\' para_name '_HX'];
        load(filename);
        
        %         eval(['data=' para_name ';']);
        %
        %         eval(['clear ' para_name ';']);
        
        if length(data_rejected.label)==32
            chan_index=chan_info.i32;
            %             for ch=1:length(data.bad_chan)
            %                 chan_max(i,find(chan_info.i32==data.bad_chan(ch)))=0;
            %             end
        else
            chan_index=chan_info.i30;
            %             for ch=1:length(data.bad_chan)
            %                 chan_max(i,find(chan_info.i30==data.bad_chan(ch)))=0;
            %             end
        end
        
        % detrend, demean
        cfg=[];
        cfg.detrend ='yes';
        data_pre=ft_preprocessing(cfg,data_rejected);
        cfg=[];
        cfg.demean ='yes';
        data_pre=ft_preprocessing(cfg,data_pre);
        
        
%         cfg=[];
%         cfg.bpfilter =[0.5 40];
%         data_pre=ft_preprocessing(cfg,data_pre);
%         
        %         % resample
        %         cfg = [];
        %         cfg.resamplefs = 50;
        %         cfg.detrend    = 'no';
        %         data_pre = ft_resampledata(cfg, data_pre);
        
        
        %%%%%% lose time insert %%%%%%%%%%%%%
        time=data_pre.time{1};
        fs=data_pre.fsample;
        new_fs = 50;
        
        data_use=NaN(size(data_pre.trial{1},1),SubInfo{i}.DataMap(end));
        data_use(:,SubInfo{i}.DataMap)=data_pre.trial{1};
        time_use=time(1):time(2)-time(1):time(1)+(time(2)-time(1))*(SubInfo{i}.DataMap(end)-1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % baseline 1: 1min before game
        data_index=LengthRecorrection(find(time_use<game_begin & time_use>game_begin-60),60,fs);
        data_structure{i}{1}=data_use(chan_index,data_index);
        data_structure{i}{1} = resample(data_structure{i}{1}',new_fs,fs); % resample
        data_structure{i}{1} = data_structure{i}{1}';
        %         data_structure{i}{1} = resample()
        
        if game_begin>5*60
            % baseline 2: 5min before game
            %             data_index=LengthRecorrection(find(time_use<game_begin-4*60 & time_use>game_begin-5*60),60,fs);
            data_index=LengthRecorrection(find(time_use<game_begin & time_use>game_begin-5*60),60,fs);
            data_structure{i}{2}=data_use(chan_index,data_index);
            data_structure{i}{2} = resample(data_structure{i}{2}',new_fs,fs); % resample
            data_structure{i}{2} = data_structure{i}{2}';
        end
        
        % game begin 5min
        data_index=LengthRecorrection(find(time_use<game_begin+5*60 & time_use>game_begin),data_len,fs);
        data_structure{i}{3}=data_use(chan_index,data_index);
        data_structure{i}{3} = resample(data_structure{i}{3}',new_fs,fs); % resample
        data_structure{i}{3} = data_structure{i}{3}';
        
        % game middle 5min
        game_middle=(game_end-game_begin)/2+game_begin;
        data_index=LengthRecorrection(find(time_use<game_middle+2.5*60 & time_use>game_middle-2.5*60),data_len,fs);
        data_structure{i}{4}=data_use(chan_index,data_index);
        data_structure{i}{4} = resample(data_structure{i}{4}',new_fs,fs); % resample
        data_structure{i}{4} = data_structure{i}{4}';
        
        % game end 5min
        data_index=LengthRecorrection(find(time_use<game_end & time_use>game_end-5*60),data_len,fs);
        data_structure{i}{5}=data_use(chan_index,data_index);
        data_structure{i}{5} = resample(data_structure{i}{5}',new_fs,fs); % resample
        data_structure{i}{5} = data_structure{i}{5}';
        
        
        
        
    end
    
end

for i=1:3
    index=find(data_label(1,:)==i);
    data=data_structure(index);
    %     data.chan=chan_max(index,:);
    save(['EEG_Data_resample_Group' num2str(i)],'data');
end

% for i=1:5
%     index=find(role_tag==i);
%     data=data_structure(index);
% %     data.chan=chan_max(index,:);
%     save(['EEG_Data_Role' num2str(i)],'data');
% end

