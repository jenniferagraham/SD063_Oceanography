function export_track_to_gpx(skip)
%EXPORT_TRACK_TO_GPX  Export best navigation to a GPX file
%   EXPORT_TRACK_TO_GPX([skip])
%   
%   Exports the best navigation stream, reduces the number of points by a 
%   factor of "skip", and writes out a GPX file named [cruisename].gpx
%
%   GPX files are XML files commonly used to interchange GPS data, and are
%   supported by many navigation or geotagging programs.
%
%   version 1.0 - 20120425 - Povl Abrahamsen, JR272A - initial version
%     "jcr_track_to_gpx.m" that loaded track from SCS
%   version 1.1 - 20230109 - Povl Abrahamsen, DY158 - adapted for RVDAS

if nargin<1
    skip=1;
end

set_underway_params

nav=load(fullfile('..',[cruisename,'_nav',...
    nav_sensor_sets(nav_sensor_set_best).file_add,'_30s_ave.mat']),...
    'time','latitude','longitude');

nav=cutstruct(nav,1:skip:length(nav.time));
nav=cutstruct(nav,~isnan(nav.longitude));


docNode=com.mathworks.xml.XMLUtils.createDocument('gpx');
gpx=docNode.getDocumentElement;
gpx.setAttribute('version','1.1');
gpx.setAttribute('creator','Povl Abrahamsen - in Matlab');
gpx.setAttribute('xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
gpx.setAttribute('xmlns','http://www.topographix.com/GPX/1/1');
gpx.setAttribute('xsi:schemaLocation','http://www.topographix.com/GPX/1/1 http://www.topographix.com/GPX/1/1/gpx.xsd');

track=docNode.createElement('trk');
track.setAttribute('name',cruisename);
gpx.appendChild(track);

cruise_seg=docNode.createElement('trkseg');
track.appendChild(cruise_seg);

for n=1:length(nav.time)
    trkpt=docNode.createElement('trkpt');
    trkpt.setAttribute('lat',sprintf('%.5f',nav.latitude(n)));
    trkpt.setAttribute('lon',sprintf('%.5f',nav.longitude(n)));
    
    ptdate=docNode.createElement('time');
    ptdatetext=docNode.createTextNode(datestr(nav.time(n),'yyyy-mm-ddTHH:MM:SSZ'));
    ptdate.appendChild(ptdatetext);
    trkpt.appendChild(ptdate);    
    
    cruise_seg.appendChild(trkpt);
end

xmlwrite(fullfile('..',[lower(cruisename),'.gpx']),docNode);
