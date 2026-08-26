function rtables=rvdas_tables(databasesource,username,password,view)
%RVDAS_TABLES list all RVDAS tables in a database
%
%   rtables = RVDAS_TABLES (datasource,username,password,view)
% 
%   Lists all RVDAS tables in a database. Defaults to SDA database. If on 
%   SDA, you should specify a view, to restrict the list of sensors to 
%   those in use on the cruise in question.
%
%   The datasource should be the same as the one you set with your ODBC
%   (refer to documentation). Currently I have saved the database source as
%   "rvdas"
%
%   This is a reasonably lengthy script to run; probably best not to do so
%   more than a few times per cruise, e.g. if the database has changed. You
%   should save the resulting table in a file "rtables_[cruise name].mat". 
%   E.g. :
%
%   >> rtables=rvdas_tables('ram.discovery.local','','rvdas','DY158');
%   >> save ../rtables_dy158 rtables
%
%   version 1.0 - 20220818 - Povl Abrahamsen, SD020 - initial version
%   version 1.1 - 20230109 - Povl Abrahamsen, DY158 - added documentation
%   version 2.0 - 20231124 - Kat Turner, SD033 - updated to use ODBC and
%       created documentation
%   version 2.1 - 20240721 - Povl Abrahamsen, SD041 - updated to use native
%       Matlab postgresql interface


if nargin<1 || isempty(databasesource)
    databasesource='rvdas';
end
if nargin<2
    username='';
end
if nargin<3
    password='';
end

% set up the connection
conn = postgresql(databasesource, username, password);

% select all available variable names. For a view select only those matching
% the cruise number, e.g. "sd033_%"
if nargin>3
    query=sprintf(['SELECT table_name FROM INFORMATION_SCHEMA.TABLES '...
        'WHERE table_name LIKE ''%s_%%'''], view)
    table_list=fetch(conn, query);
else
    table_list=fetch(conn, 'SELECT table_name FROM INFORMATION_SCHEMA.TABLES');
end

% remove these variable names
tables=setdiff(table_list.table_name,{'logta','spatial_ref_sys'});

% in the file rtables save the view and the database source
rtables.server_info=struct('databasesource',databasesource,...
    'username',username,'password',password);
if nargin>3
    rtables.server_info.view=view;
end
for n=1:length(tables)
    if nargin>3 && ~startsWith(tables{n},[view,'_'])
        continue;
    end

    query = sprintf(['SELECT column_name, data_type '...
        'FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name = ''%s'' '...
        'ORDER BY ordinal_position ASC;'],tables{n});
    table_fields = fetch(conn, query);
    % first three fields are "time","sensorid", and "messageid".
    % last fields are all flags (one per variable)
    % rtables.(tables{n})={table_fields.column_name{4:(height(table_fields)/2+1.5)}};
    rtables.(tables{n})={table_fields.column_name{4:(height(table_fields))}};
end

conn.close();
