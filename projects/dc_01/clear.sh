#/bin/sh
# delete the project and start over
mysql -hhalldweb1 -ufarmer farming -e "drop table dc_01"
../../scripts/jproj.pl dc_01 create 10
