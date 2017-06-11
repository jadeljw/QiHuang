
clear
Event_Info=load('Subject_Event_Info');
path='..\QiHuang\Data_EEG\Analysis\';

load([path 'EEG_SubInfo_0803']);
chan_info=load([path 'Channel_overlap']);

game_use=[1:9 11:13];

group_label={'CAU','QH','Pro'};
role_label={'Top','Mid','Adc','Sup','Jug'};

for game_no=1:length(game_use)
    j=game_use(game_no);
for sub=1:5
    
   
    
    i=(game_no-1)*5+sub;
    
     if strcmp(SubInfo{i}.GameTime(1:4),Event_Info.Subject_Event{j}.game(5:8)) && ...
           strcmp(SubInfo{i}.Id,Event_Info.Role{j}.ID{sub})
   
         group_tag(i)=strmatch(SubInfo{i}.Group,group_label);
         role_tag(i)=strmatch(Event_Info.Role{j}.Info{sub},role_label);
         
         trigger_time=SubInfo{i}.EEGtime(1,1);
    game_begin=SubInfo{i}.EEGtime(1,2);
    game_end=SubInfo{i}.EEGtime(1,3);
    
    if SubInfo{i}.DataUse
        
        
%         chan_max(i,:)=ones(1,28);
        
        para_name=[ 'EEG_' SubInfo{i}.Id '_' SubInfo{i}.Group '_' num2str(SubInfo{i}.Game)];
        filename=[path 'data_pre_HX\data_rejected\' para_name '_HX.mat'];
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
        
        
        
        % detrend, demean and remove common average
        cfg=[];
        cfg.detrend ='yes';
        data_pre=ft_preprocessing(cfg,data_rejected);
        cfg=[];
        cfg.demean ='yes';
        data_pre=ft_preprocessing(cfg,data_pre);
%         bad_chan_label{1}='all';
%         for b_c=1:length(data.bad_chan)
%             bad_chan_label{b_c+1}=['-' data.data_after_ica.label{data.bad_chan(b_c)}];
%         end
%         cfg=[];
%         cfg.reref ='yes';
%         cfg.refchannel=bad_chan_label;
%         data_pre=ft_preprocessing(cfg,data_pre);
        
        %%%%%% lose time insert %%%%%%%%%%%%%
        time=data_pre.time{1};
        fs=data_pre.fsample;
        
        data_use=NaN(size(data_pre.trial{1},1),SubInfo{i}.DataMap(end));
        data_use(:,SubInfo{i}.DataMap)=data_pre.trial{1};
        time_use=time(1):time(2)-time(1):time(1)+(time(2)-time(1))*(SubInfo{i}.DataMap(end)-1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        data_event{i}=cell(1,3);
        for e=1:length(Event_Info.Subject_Event{j}.data(sub).event)
            time_start=game_begin+Event_Info.off_time(j)+...
                Event_Info.Subject_Event{j}.data(sub).event(e).start;
            time_end=game_begin+Event_Info.off_time(j)+...
                Event_Info.Subject_Event{j}.data(sub).event(e).end;
            data_index=find(time_use<=time_end & time_use>=time_start);
            data_event{i}{Event_Info.Subject_Event{j}.data(sub).event(e).type}= ...
                [data_event{i}{Event_Info.Subject_Event{j}.data(sub).event(e).type};...
                {data_use(chan_index,data_index)}];
        end
            
      
        
    end
     end
end
    
    
end

save('event_data','data_event','group_tag','role_tag','group_label','role_label')

% %% one game segment
% clear
% load 'event_example'
% time_off=15.109;
% 
% path='..\QiHuang\Data_EEG\Analysis\data_pre\';
% 
% load([path 'EEG_SubInfo_0803']);
% chan_info=load([path 'Channel_overlap']);
% 
% for sub=1:length(subj)
%     
%     i=sub;
%     trigger_time=SubInfo{i}.EEGtime(1,1);
%     game_begin=SubInfo{i}.EEGtime(1,2);
%     game_end=SubInfo{i}.EEGtime(1,3);
%     
%     if SubInfo{i}.DataUse
%         
%         
%         chan_max(i,:)=ones(1,28);
%         
%         para_name=[ 'EEG_' SubInfo{i}.Id '_' SubInfo{i}.Group '_' num2str(SubInfo{i}.Game)];
%         filename=[path para_name '_DY'];
%         load(filename);
%         
%         eval(['data=' para_name ';']);
%         
%         eval(['clear ' para_name ';']);
%         
%         if length(data.data_after_ica.label)==32
%             chan_index=chan_info.i32;
%             for ch=1:length(data.bad_chan)
%                 chan_max(i,find(chan_info.i32==data.bad_chan(ch)))=0;
%             end
%         else
%             chan_index=chan_info.i30;
%             for ch=1:length(data.bad_chan)
%                 chan_max(i,find(chan_info.i30==data.bad_chan(ch)))=0;
%             end
%         end
%         
%         
%         
%         % detrend, demean and remove common average
%         cfg=[];
%         cfg.detrend ='yes';
%         data_pre=ft_preprocessing(cfg,data.data_after_ica);
%         cfg=[];
%         cfg.demean ='yes';
%         data_pre=ft_preprocessing(cfg,data_pre);
%         bad_chan_label{1}='all';
%         for b_c=1:length(data.bad_chan)
%             bad_chan_label{b_c+1}=['-' data.data_after_ica.label{data.bad_chan(b_c)}];
%         end
%         cfg=[];
%         cfg.reref ='yes';
%         cfg.refchannel=bad_chan_label;
%         data_pre=ft_preprocessing(cfg,data_pre);
%         
%         %%%%%% lose time insert %%%%%%%%%%%%%
%         time=data.data_after_ica.time{1};
%         fs=data.data_after_ica.fsample;
%         
%         data_use=NaN(size(data.data_after_ica.trial{1},1),SubInfo{i}.DataMap(end));
%         data_use(:,SubInfo{i}.DataMap)=data_pre.trial{1};
%         time_use=time(1):time(2)-time(1):time(1)+(time(2)-time(1))*(SubInfo{i}.DataMap(end)-1);
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         
%         
%         data_event{sub}=cell(1,3);
%         for e=1:length(subj(sub).event)
%             time_start=game_begin+time_off+subj(sub).event(e).start;
%             time_end=game_begin+time_off+subj(sub).event(e).end;
%             data_index=find(time_use<=time_end & time_use>=time_start);
%             data_event{sub}{subj(sub).event(e).type}= ...
%                 [data_event{sub}{subj(sub).event(e).type};{data_use(chan_index,data_index)}];
%         end
%             
%       
%         
%     end
%     
% end
% 
% 
% %% data organize
% clear
% load('EEG_SubInfo_0803');
% chan_info=load('Channel_overlap');
% data_len=5*60;
% group_label={'CAU','QH','Pro'};
% 
% 
% for i=1:length(SubInfo)
%     
%     trigger_time=SubInfo{i}.EEGtime(1,1);
%     game_begin=SubInfo{i}.EEGtime(1,2);
%     game_end=SubInfo{i}.EEGtime(1,3);
%     data_label(1,i)=strmatch(SubInfo{i}.Group,group_label);
%     if SubInfo{i}.DataUse
%         
%         data_structure{i}=[];
%         
%         chan_max(i,:)=ones(1,28);
%         
%         para_name=[ 'EEG_' SubInfo{i}.Id '_' SubInfo{i}.Group '_' num2str(SubInfo{i}.Game)];
%         filename=[pwd '\PreData\' para_name '_DY'];
%         load(filename);
%         
%         eval(['data=' para_name ';']);
%         
%         eval(['clear ' para_name ';']);
%         
%         if length(data.data_after_ica.label)==32
%             chan_index=chan_info.i32;
%             for ch=1:length(data.bad_chan)
%                 chan_max(i,find(chan_info.i32==data.bad_chan(ch)))=0;
%             end
%         else
%             chan_index=chan_info.i30;
%             for ch=1:length(data.bad_chan)
%                 chan_max(i,find(chan_info.i30==data.bad_chan(ch)))=0;
%             end
%         end
%         
%         
%         
%         %%%%%% lose time insert %%%%%%%%%%%%%
%         time=data.data_after_ica.time{1};
%         fs=data.data_after_ica.fsample;
%         
%         data_use=NaN(size(data.data_after_ica.trial{1},1),SubInfo{i}.DataMap(end));
%         data_use(:,SubInfo{i}.DataMap)=data.data_after_ica.trial{1};
%         time_use=time(1):time(2)-time(1):time(1)+(time(2)-time(1))*(SubInfo{i}.DataMap(end)-1);
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         
%         
%         % baseline 1: 1min before game
%         data_index=LengthRecorrection(find(time_use<game_begin & time_use>game_begin-60),60,fs);
%         data_structure{i}{1}=data_use(chan_index,data_index);
%         
%         if game_begin>5*60
%             % baseline 2: 5min before game
%             data_index=LengthRecorrection(find(time_use<game_begin-4*60 & time_use>game_begin-5*60),60,fs);
%             data_structure{i}{2}=data_use(chan_index,data_index);
%         end
%         
%         % game begin 5min
%         data_index=LengthRecorrection(find(time_use<game_begin+5*60 & time_use>game_begin),data_len,fs);
%         data_structure{i}{3}=data_use(chan_index,data_index);
%         
%         % game middle 5min
%         game_middle=(game_end-game_begin)/2+game_begin;
%         data_index=LengthRecorrection(find(time_use<game_middle+2.5*60 & time_use>game_middle-2.5*60),data_len,fs);
%         data_structure{i}{4}=data_use(chan_index,data_index);
%         
%         
%         data_index=LengthRecorrection(find(time_use<game_end & time_use>game_end-5*60),data_len,fs);
%         data_structure{i}{5}=data_use(chan_index,data_index);
%         
%         
%         
%         
%     end
%     
% end
% 
% for i=1:3
%     index=find(data_label(1,:)==i);
%     data.data=data_structure(index);
%     data.chan=chan_max(index,:);
%     save(['EEG_Data_Group' num2str(i)],'data');
% end
% 
% 
% 
