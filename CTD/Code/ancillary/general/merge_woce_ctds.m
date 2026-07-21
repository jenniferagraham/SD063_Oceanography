function ctds=merge_woce_ctds(ctd_path,bottle_file)

%% load bottle data

bottle_data=load_woce_bottle_exchange(bottle_file);
bottle_fields=fieldnames(bottle_data);

%% load CTD data

ctd_files=dir(fullfile(ctd_path,'*_ct1.csv'));

for n=1:length(ctd_files)
    new_ctd=load_woce_ctd_exchange(fullfile(ctd_path,ctd_files(n).name));
    
    %match bottles!
    ourbottles=find(strcmp(new_ctd.cruise,bottle_data.cruise) & ...
        (new_ctd.station==bottle_data.station) & ...
        (new_ctd.cast==bottle_data.cast));
    
    for m=1:length(bottle_fields)
        if any(strcmp(bottle_fields{m},{'cruise','sectionname','station','cast'}))
            continue;
        end
        if isstr(bottle_data.(bottle_fields{m}))
            new_ctd.bottles.(bottle_fields{m})=bottle_data.(bottle_fields{m});
        else
            new_ctd.bottles.(bottle_fields{m})=bottle_data.(bottle_fields{m})(ourbottles);
        end
    end
    
    %overwrite cruise:
%     new_ctd.cruise='RB0501';
    try
        ctds(n)=new_ctd;
    catch
        %a new field?
        newfields=setdiff(fieldnames(new_ctd),fieldnames(ctds));
        if length(newfields)>0
            for m=1:length(newfields)
                if strfind(newfields{m},'_unit')
                    for o=1:n-1
                        ctds(o).(newfields{m})=new_ctd.(newfields{m});
                    end
                elseif strfind(newfields{m},'_flag')
                    for o=1:n-1
                        ctds(o).(newfields{m})=repmat(uint8(9),size(ctds(o).press));
                    end
                else
                    for o=1:n-1
                        ctds(o).(newfields{m})=nan(size(ctds(o).press));
                    end
                end
            end
        else %field missing from this CTD
            newfields=setdiff(fieldnames(ctds),fieldnames(new_ctd));
           for m=1:length(newfields)
                if strfind(newfields{m},'_unit')
                    new_ctd.(newfields{m})=ctds(1).(newfields{m});
                elseif strfind(newfields{m},'_flag')
                    new_ctd.(newfields{m})=repmat(uint8(9),size(new_ctd.press));
                else
                    new_ctd.(newfields{m})=nan(size(new_ctd.press));
                end
            end
        end
        ctds(n)=new_ctd;
    end
end