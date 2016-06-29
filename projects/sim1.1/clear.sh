#!/bin/bash
# delete the project and start over
swif cancel -workflow sim1.1 -delete
mysql -hhallddb -ufarmer farming2 -e "drop table sim1.1; drop table sim1.1Job"
jproj.pl sim1.1 create
jproj.pl sim1.1 populate 10000 1000
