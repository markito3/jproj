select 'total', count(*) from dc_03_sim;
select 'submitted', count(*) from dc_03_sim where submitted = 1;
select 'output', count(*) from dc_03_sim where output = 1;
select 'jput_submitted', count(*) from dc_03_sim where jput_submitted = 1;
select 'silo', count(*) from dc_03_sim where silo = 1;
select 'jcache_submitted', count(*) from dc_03_sim where jcache_submitted = 1;
select 'cache', count(*) from dc_03_sim where cache = 1;
