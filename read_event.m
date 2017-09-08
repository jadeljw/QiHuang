clear;
load('Subject_Event.mat');

for i=1:length(Subject_Event)
 [~, ~, raw]=xlsread([Subject_Event{i}.game '.xlsx'],'Match Info');
 
 for j=1:5
     Role{i}.ID{j}=Subject_Event{i}.data(j).id;
     Role{i}.Info{j}=raw{j+3,4}; 
 end
end


%%
flag=12; 
game_name='20160629_RVG_Male_Game2_B1';
Subject_Event{flag}.game=game_name;
for i=1:5
    sub_id{i}=['B' num2str(i)];
end


[~, ~, raw]=xlsread([game_name '.xlsx'],'Match Log');


for i=1:5
    subj(i).id=sub_id{i};
end

for i=1:size(raw,1)
    for j=1:size(raw(i,:),2)
        if size(raw{i,j},2)==1 && raw{i,j}>0 
            raw{i,j}=num2str(raw{i,j});
        end
    end
end

eve_line=1;
sub_eve_c(1:5)=1;

while eve_line<size(raw,1)+1
    if strcmp(raw{eve_line,1},'Event #')
        exit_marker(1:5)=0;
    end
    
    if strcmp(raw{eve_line,1},'Type')
        switch raw{eve_line,2}(1)
            case 'L'
                eve_type=1;
            case 'G'
                eve_type=2;
            case 'B'
                eve_type=3;
        end
    end
    
    if strcmp(raw{eve_line,1},'Start Time')
        time_s=fun_time(raw{eve_line,2});
    else if strcmp(raw{eve_line,1},'End Time')
        time_e=fun_time(raw{eve_line,2});
        end
    end

    if strcmp(raw{eve_line,1},'Actors')
        for j=2:size(raw(eve_line,:),2)
            temp_id=strcmp(sub_id(:),raw{eve_line,j});
            if max(temp_id)>0 % is a player
                subj(temp_id).event(sub_eve_c(temp_id)).start=time_s;
                subj(temp_id).event(sub_eve_c(temp_id)).end=time_e;
                subj(temp_id).event(sub_eve_c(temp_id)).type=eve_type;
                sub_eve_c(temp_id)=sub_eve_c(temp_id)+1;
            end
        end
    end

    if strcmp(raw{eve_line,1},'Join')
        for j=2:size(raw(eve_line,:),2)
            temp_id=strcmp(sub_id(:),raw{eve_line,j});
            if max(temp_id)==0 && size(raw{eve_line,j},2)>3   
                time_join=fun_time(raw{eve_line,j});
                if time_join>time_e
                    disp(['time error: line ' num2str(eve_line)]);
                end
            end
        end
        for j=2:size(raw(eve_line,:),2)
            temp_id=strcmp(sub_id(:),raw{eve_line,j});
%                     time_join=fun_time(raw{eve_line,end});
            if max(temp_id)>0 % is a player
                if  exit_marker(temp_id)==0
                    sub_eve_c(temp_id)=sub_eve_c(temp_id)-1;
                else
                    subj(temp_id).event(sub_eve_c(temp_id)).type=eve_type;
                end
                subj(temp_id).event(sub_eve_c(temp_id)).start=time_join;       
                subj(temp_id).event(sub_eve_c(temp_id)).end=time_e;
                sub_eve_c(temp_id)=sub_eve_c(temp_id)+1;
            end   
        end
    end


    if strcmp(raw{eve_line,1},'Exit')
        temp_id=strcmp(sub_id(:),raw{eve_line,2});
        time_exit=fun_time(raw{eve_line,3});
        if time_exit>time_e
            disp(['time error: line ' num2str(eve_line)]);
        end
        if max(temp_id)>0 % is a player
            sub_eve_c(temp_id)=sub_eve_c(temp_id)-1;
            subj(temp_id).event(sub_eve_c(temp_id)).end=time_exit;          
            exit_marker(temp_id)=1;
            sub_eve_c(temp_id)=sub_eve_c(temp_id)+1;
        end
    end

    if strcmp(raw{eve_line,1},'Kill')
        temp_id=strcmp(sub_id(:),raw{eve_line,3});
        time_killed=fun_time(raw{eve_line,4});
        if time_killed>time_e
            disp(['time error: line ' num2str(eve_line)]);
        end
        if max(temp_id)>0 % is a player
            exit_marker(temp_id)=1;
            sub_eve_c(temp_id)=sub_eve_c(temp_id)-1;
            subj(temp_id).event(sub_eve_c(temp_id)).end=time_killed;        
            sub_eve_c(temp_id)=sub_eve_c(temp_id)+1;
        end
    end

    eve_line=eve_line+1;
end   


for i=1:5
    
    for j=1:size(subj(1,i).event,2)
    summary(i).data(j,1)=subj(1,i).event(1,j).type;
    summary(i).data(j,2)=subj(1,i).event(1,j).start;
    summary(i).data(j,3)=subj(1,i).event(1,j).end;
    summary(i).data(j,4)=summary(i).data(j,3)-summary(i).data(j,2);
    
    end
end


Subject_Event{flag}.data=subj;

save('Subject_Event','Subject_Event');