#!/bin/bash
# delete the project and start over
mysql -hhallddb -ufarmer farming2 -e "drop table sim1; drop table sim1Job"
jproj.pl sim1 create
jproj.pl sim1 populate 9001 10
