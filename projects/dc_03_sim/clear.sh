#/bin/sh
# delete the project and start over
mysql -hhalldweb1 -ufarmer farming -e "drop table dc_03_sim"
../../scripts/jproj.pl dc_03_sim create
../../scripts/jproj.pl dc_03_sim update
