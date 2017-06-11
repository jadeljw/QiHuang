% function S1_ReadData(sub_id)
clear

for sub_num=4:5

sub_id = '20160625-CAU';
game_num = 1;
good_chan=32;

% load data
% file_to_load=[pwd '\' sub_id '\PM\Game' num2str(game_num) '\' num2str(sub_num) '.bdf'];
file_to_load=[pwd '\' sub_id '\AM\' num2str(sub_num) '.bdf'];

cfg = [];
cfg.dataset = file_to_load;
cfg.continuous = 'yes';
data_raw = ft_preprocessing(cfg);

if strmatch('A1',data_raw.label)
    cfg=[];
    cfg.channel={'all','-A1','-A2'};
    data_raw = ft_preprocessing(cfg,data_raw);
    good_chan=30;
end

% data fix
data_fix = data_raw;
for j = 1:size(data_fix.trial{1},1)
    for k = 1:size(data_fix.trial{1},2)-1
        if(abs(data_fix.trial{1}(j,k+1)-data_fix.trial{1}(j,k))>10000)
            data_fix.trial{1}(j,k+1) = data_fix.trial{1}(j,k);
            disp(['Chn ' int2str(j) ', sample ' int2str(k) ' fixed.']);
        end
    end
end



% remove channel
% cfg = [];
% % cfg.layout    = 'biosemi64.lay';
% cfg.viewmode='vertical';
% ft_databrowser(cfg,data_fix);

cfg=[];
cfg.method='trial';
data_reject=ft_rejectvisual(cfg,data_fix);

bad_chan=input('bad channel?');
bad_chan_label=cell(1,1+length(bad_chan));
bad_chan_label{1}='all';
for i=1:length(bad_chan)
    bad_chan_label{i+1}=['-' data_reject.label{bad_chan(i)}];
end

% low-pass filter
cfg = [];
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.5 40];
data_filtered = ft_preprocessing(cfg,data_fix);


% ica
ica_data=data_filtered;
cfg = [];
cfg.channel=bad_chan_label;
cfg.method = 'runica';
data_comp = ft_componentanalysis(cfg,ica_data);

%plot and remove

figure;
cfg = [];
cfg.component = [1:good_chan-length(bad_chan)] ; % specify the component(s) that should be plotted
cfg.layout    = 'biosemi64.lay'; % specify the layout file that should be used for plotting
cfg.viewmode='component';
ft_topoplotIC(cfg, data_comp);

figure;
cfg = [];
cfg.component = [1:good_chan-length(bad_chan)] ; % specify the component(s) that should be plotted
cfg.layout    = 'biosemi64.lay'; % specify the layout file that should be used for plotting
cfg.viewmode='component';
ft_databrowser(cfg, data_comp);


cfg = [];
cfg.component = input('bad component?'); % to be removed component(s)
data_after_ica = ft_rejectcomponent(cfg, data_comp, ica_data);

file_name=[ 'CAU_25AM_Game1_Sub' num2str(sub_num)];
save(file_name,'data_comp','bad_chan','data_filtered','data_after_ica','data_fix');

end


% %%
% clear
% for sub_num=1:5
%     
% file_name=[ 'CAU_24PM_Game1_Sub' num2str(sub_num)];
% load(file_name);
% game=1;
% save_name=['EEG_' num2str(sub_num+5) '_CAU_' num2str(game)];
% eval([save_name '.data_comp=data_comp;'])
% eval([save_name '.data_filtered=data_filtered;'])
% eval([save_name '.data_after_ica=data_after_ica;'])
% eval([save_name '.data_fix=data_fix;'])
% eval([save_name '.bad_chan=bad_chan;'])
% 
% save([save_name '_DY'],save_name)
% end
% 
% 
% 
% %%
% figure;
% cfg = [];
% cfg.component = [1:32] ; % specify the component(s) that should be plotted
% cfg.layout    = 'biosemi64.lay'; % specify the layout file that should be used for plotting
% cfg.viewmode='component';
% ft_topoplotIC(cfg, data_comp);
% 
% %%
% cfg = [];
% cfg.layout    = 'biosemi64.lay'; % specify the layout file that should be used for plotting
% cfg.viewmode='component';
% ft_databrowser(cfg, data_comp);
% 
% %%
% cfg = [];
% cfg.viewmode = 'vertical';
% ft_databrowser(cfg, data_after_ica);
% ft_databrowser(cfg, data_one);
% 
% 
% 
% 
% 
% %%
% %%%%%%%%%%%%%%   mannually    %%%%%%%%%%%%%%%%%%%%%%%%%
% %% data load
% 
% filename='RVG_Game1_2';
% data=EEG.data;
% time=EEG.times;
% fs=EEG.srate;
% event=EEG.event;
% time_range=[0,5;7,12;13,18;19,24];
% save(filename,'data','time','fs','event','time_range');
% 
% 
% %%
% clear
% load 'CAU_25am1_2';
% 
% trigger_time=event(end).latency;
% 
% 
% 
% %%
% for i=1:size(time_range,1)
%     time_index=find(time>time_range(i,1)*fs+trigger_time ...
%         & time>time_range(i,2)*fs+trigger_time);
%     data_analysis{i}=data(:,time_index);
% end
% 
% pxx=[];
% 
% for i=1:32
%     
%     for j=1:4
%         [pxx{i}(:,j),f]=pwelch(data_analysis{j}(i,:),fs,1\2*fs,1\2*fs,fs);
%     end
%     
%     
% end
% 
% color=['b','g','r','m'];
% for i=1:32
%     figure;
%     for j=2:4
%         plot(f(5:20),10*log10(pxx{i}(5:20,j)),color(j));
%         hold on;
%     end
%     legend('begin','middle','end')
%     pause
%     close all
% end
% 
% %%
% 
% filename='CAU_25am1_1';
% data=EEG.data;
% time=EEG.times;
% fs=EEG.srate;
% event=EEG.event;
% time_range=[0,5;8,13;20,25;30,35];
% save(filename,'data','time','fs','event','time_range');

