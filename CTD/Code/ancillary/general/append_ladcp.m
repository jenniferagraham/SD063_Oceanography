function ctd_ladcp=append_ladcp(ctds,ladcp_fname)

for n=1:length(ctds)
    new_rec=ctds(n);
    try
        if iscell(ladcp_fname)
            if length(ladcp_fname)<=1 || isempty(new_rec.cast)
                narg=length(find(ladcp_fname{1}=='%'));
                ladcp_data=load(sprintf(ladcp_fname{1},repmat(new_rec.station,narg,1)),'dr');
            else
                narg=length(find(ladcp_fname{2}=='%'));
                ladcp_data=load(sprintf(ladcp_fname{2},repmat(new_rec.station,narg-1,1),new_rec.cast),'dr');
            end
        else
            narg=length(find(ladcp_fname=='%'));
            ladcp_data=load(sprintf(ladcp_fname,repmat(new_rec.station,narg,1)),'dr');
        end
        % checks:
        thedist=m_lldist([new_rec.lon ladcp_data.dr.lon],[new_rec.lat ladcp_data.dr.lat]);
        if thedist>1
            warning('Distance between CTD and LADCP for station %d > 1 km - %.1f km',...
                new_rec.station,thedist);
        end
        thediff=abs(new_rec.date-datenum(ladcp_data.dr.date));
        if thediff>(2./24)
            warning('Time difference between CTD and LADCP for station %d > 2 hours - %.0f minutes',...
                new_rec.station,thediff*24*60);
        end
        new_rec.ladcp_u=interp1(ladcp_data.dr.p,ladcp_data.dr.u,new_rec.press,'linear');
        new_rec.ladcp_v=interp1(ladcp_data.dr.p,ladcp_data.dr.v,new_rec.press,'linear');
    catch
        warning('Could not match LADCP for station %d',new_rec.station);
        new_rec.ladcp_u=nan(size(new_rec.press));
        new_rec.ladcp_v=new_rec.ladcp_u;
    end
    ctd_ladcp(n)=new_rec;
end

