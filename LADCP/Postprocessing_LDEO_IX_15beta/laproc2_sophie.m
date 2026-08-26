% LADCP data processing
% 
% LDEO Martin Visbeck March 2002
%
% Start Processing the data
%
% first load default parameter you might want to set
%
tic;
default

% check if output files are wanted, open log file
if length(f.res)>1
 if exist([f.res,'.log'])==exist('loadrdi.m')
  eval(['delete ',f.res,'.log'])
 end
 diary([f.res,'.log'])
 diary on
end

% LOAD RDI BB-raw data
%  this is a rather complex set of functions
%  1) load raw data
%  2) merge down-up data
%  3) do some fist order error check
 [d,p]=loadrdi(f,p); 

disp(['==> load data took ',int2str(toc),' seconds'])
toco=toc;


% LOAD CTD data from ascii file
% 
%  get ctd pressure/depth data
%  We provide more than one version to support different file formats
% 
if length(f.ctd)>1
  [d,p]=loadctd(f,d,p);
end

%  Find depth and bottom and surface using ADCP data 
 [d,p]=getdpthi(f,d,p);

% 
% get GPS navigation data from ascii list with time YYYYMMDD HHMMSS
%
if length(f.nav)>1
  [d,p]=loadnav(f,d,p);
else
  d.slon=NaN*d.time_jul;
  d.slat=d.slon;
end

disp(['==> get depth took ',int2str(toc-toco),' seconds'])
toco=toc;

% Plot a summary plot of the raw data
  figure(2), clf
  plotraw(d,p);
  pause(.1)
  if length(f.res)>1
    eval(['print -dpsc ',f.res,'fig2'])
  end

% Compute Super Ensemble from raw data to reduce the dimension
% of the problem
% also
%    1) rotate down and up instrument together
%    2) check bottom track data
%    3) check for large tilt
%    4) compute tilt and heading offset between instruments
% 
   [di,p]=prepinv(f,d,p);

% Reduce scatter by successively removing 1% of the data
%  this already compute a quick inverse solution
if ps.outlier>0
   dino=di;
   lanarrow
end
 
% Second iteration to deal with compass deviation
% experts only ...
if p.deviat>0
   dino=di;
   ladeviat
end
% lanarrow adds streamer to fig 3 started in prepinv, so save now
  eval(['print -dpsc ',f.res,'fig3'])
 
disp(['==> prep inversion took ',int2str(toc-toco),' seconds'])
toco=toc;

% Main invers solution of
%  1) top - bottom velocity profile
%  2) bottom reference profile (if bottom track available)
%  3) down-up cast solution only
 [dr,ps,de]=getinv(f,di,p,ps);

disp(['==> inversion took ',int2str(toc-toco),' seconds'])
toco=toc;

% Compute shear based solution as we used to do it
%  two choices, fisrt us all data
%  second use super ensemble data
if ps.shear>0
 if ps.shear==1
  [ds,dr,ps]=getshear2(d,p,ps,dr);
 else
  [ds,dr,ps]=getshear2(di,p,ps,dr);
 end
end

% Plot final results
% figure(1), clf
% plotinv(dr,di,d,p,ps)
%  eval(['print -dpsc ',f.res,'fig1'])
 
 disp('Now calculating MVBS ... using svcalc4.m');
 [d,p] = svcalc4(d,p);
 
% OUTPUT to files
if length(f.res)>1
  % [d,p] = getdpth(d,p);
  % plot the MVBS and save to ps file...
  plotscat1(f,d,p,d.mvbs);

  % save results to ASCII, MATLAB and NETCD files
  disp(' save results ')
  saveres(p,ps,f,d)
  da=savearch(dr,d,p,ps,f);
  
  % diary off 
  diary off

  % save a protocol
%  saveprot

end

disp(['==> The whole task took ',int2str(toc),' seconds'])

