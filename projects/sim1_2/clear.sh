#!/bin/bash
# delete the project and start over
swif cancel -workflow sim1_2 -delete
mysql -hhallddb -ufarmer farming2 -e "drop table sim1_2; drop table sim1_2Job"
jproj.pl sim1_2 create
