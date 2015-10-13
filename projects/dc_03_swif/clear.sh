#!/bin/sh
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table dc_03_swif, dc_03_swifJob"
jproj.pl dc_03_swif create
jproj.pl dc_03_swif update
