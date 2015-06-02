#!/bin/sh
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table dc_03_recon, dc_03_reconJob"
jproj.pl dc_03_recon create
jproj.pl dc_03_recon update
