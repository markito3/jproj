#!/bin/sh
# delete the project and start over
swif cancel -delete -workflow dc_03_2_sim
mysql -hhallddb -ufarmer farming -e "drop table dc_03_2_sim, dc_03_2_simJob"
jproj.pl dc_03_2_sim create
jproj.pl dc_03_2_sim populate 9200 10
