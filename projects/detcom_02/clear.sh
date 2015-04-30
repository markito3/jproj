#/bin/sh
# delete the project and start over
mysql -hhalldweb1 -ufarmer farming -e "drop table detcom_02; drop table detcom_02Job"
../../scripts/jproj.pl detcom_02 create
../../scripts/jproj.pl detcom_02 update
