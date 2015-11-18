#!/bin/sh
# delete the project and start over
swif cancel -delete -workflow dc_03_2_recon
mysql -hhallddb -ufarmer farming -e "drop table dc_03_2_recon, dc_03_2_reconJob"
jproj.pl dc_03_2_recon create
jproj.pl dc_03_2_recon update
