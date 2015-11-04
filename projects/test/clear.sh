#/bin/sh
# delete the project and start over
swif cancel test -delete
mysql -hhallddb -ufarmer farming -e "drop table test; drop table testJob"
jproj.pl test create
jproj.pl test populate 1234 10
