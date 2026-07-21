function ctds=merge_bodc_netcdf_ctds(ctd_path,metadata_file,cruisename)

ctd_files=dir(fullfile(ctd_path,'*.qxf'));

fid=fopen(metadata_file,'rt');
data=textscan(fid,'%f%f%f%s%s%d%*d%*d%*s%*s%*s%*s','headerlines',14,'delimiter',',');
fclose(fid);

for n=1:length(data{1})
    
    new_ctd=load_bodc_ctd_exchange_netcdf(fullfile(ctd_path,ctd_files(n).name));
    new_ctd.cruise=cruisename;
    new_ctd.station=data{1}(n);
    new_ctd.lat=data{2}(n);
    new_ctd.lon=data{3}(n);
    new_ctd.date=datenum([data{4}{n},' ',data{5}{n}],'yyyy-mm-dd HH:MM');
    new_ctd.botdepth=data{6}(n);
    if new_ctd.botdepth==-99
        new_ctd.botdepth=-999;
    end
    try
        ctds(n)=new_ctd;
    catch
        missing_fields_a=setdiff(fieldnames(ctds),fieldnames(new_ctd));
        missing_fields_b=setdiff(fieldnames(new_ctd),fieldnames(ctds));
        for m=1:length(missing_fields_a)
            if endsWith(missing_fields_a{m},'_flag')
                new_ctd.(missing_fields_a{m})=repmat('N',size(new_ctd.press)); % N = null value
            else
                new_ctd.(missing_fields_a{m})=nan(size(new_ctd.press));
            end
        end
        for m=1:length(missing_fields_b)
            if endsWith(missing_fields_b{m},'_flag')
                ctds(n-1).(missing_fields_b{m})=repmat('N',size(ctds(n-1).press)); % N = null value
            else
                ctds(n-1).(missing_fields_b{m})=nan(size(ctds(n-1).press));
            end
        end
        ctds(n)=new_ctd;
    end
    
end