function ctds=load_woce_ctds(ctddir)
ctdfiles=dir(fullfile(ctddir,'*_ct1.csv'));
if isempty(ctdfiles)
    error('No CTD files found')
end

for n=1:length(ctdfiles)
    fname=fullfile(ctddir,ctdfiles(n).name);
    ctd=load_woce_ctd_exchange(fname);
%     ctd.cruise=cruisename;
    ctds(n)=ctd;
end

