rvdas_sda=databaseConnectionOptions('native','postgresql');
rvdas_sda.DataSourceName='rvdas';
rvdas_sda.DatabaseName='marine_sda';
rvdas_sda.Server='sdl-pgdb-read.sda.bas.ac.uk';

% chai3Loh3aem1va
status=testConnection(rvdas_sda,'rvdas_ro', '9Gb3QG3dLUZ7gRJXegQf');

saveAsDataSource(rvdas_sda)
listDataSources

rtables = rvdas_tables("rvdas", 'rvdas_ro', '9Gb3QG3dLUZ7gRJXegQf', "sd046");
save ../rtables_sd046 rtables