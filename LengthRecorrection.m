function time_index=LengthRecorrection(time_index,len,fs)

        
        if len==ceil(len)
                    
                    lag_adjust=round(length(time_index)/fs);
                    time_index=time_index(1):time_index(1)+lag_adjust*fs-1;
                else
                    
                    lag_adjust=round(10*length(time_index)/fs);
                    time_index=time_index(1):time_index(1)+lag_adjust/10*fs-1;
        end