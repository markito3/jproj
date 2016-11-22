#/bin/sh
# delete the project and start over
swif cancel test -delete
mysql -hhallddb -ufarmer farming3 -e "drop table test; drop table testJob"
jproj.pl test create
