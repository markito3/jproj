#/bin/sh
# delete the project and start over
mysql -hhalldweb1 -ufarmer farming -e "drop table test"
../../scripts/jproj.pl dc_02 create 1234 1000
