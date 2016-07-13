#!/bin/bash
# delete the project and start over
swif cancel -workflow sim1_1 -delete
mysql -hhallddb -ufarmer farming2 -e "drop table sim1_1; drop table sim1_1Job"
jproj.pl sim1_1 create
