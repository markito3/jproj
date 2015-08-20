select 'total', count(*) from detcom_02_recon;
select 'submitted', count(*) from detcom_02_recon where submitted = 1;
select 'output', count(*) from detcom_02_recon where output = 1;
select 'jput_submitted', count(*) from detcom_02_recon where jput_submitted = 1;
select 'silo', count(*) from detcom_02_recon where silo = 1;
select 'jcache_submitted', count(*) from detcom_02_recon where jcache_submitted = 1;
select 'cache', count(*) from detcom_02_recon where cache = 1;
