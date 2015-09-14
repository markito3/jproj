#!/bin/bash
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table detcom_02_1; drop table detcom_02_1Job"
jproj.pl detcom_02_1 create
jproj.pl detcom_02_1 populate 9306 5000
