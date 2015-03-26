#/bin/sh
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table dc_03_sim, dc_03_simJob"
../../scripts/jproj.pl dc_03_sim create 9200 10000
