#!/bin/bash
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table detcom_02; drop table detcom_02Job"
jproj.pl detcom_02 create
jproj.pl detcom_02 populate 9301 10
jproj.pl detcom_02 populate 9302 10
jproj.pl detcom_02 populate 9303 10
jproj.pl detcom_02 populate 9304 10
jproj.pl detcom_02 populate 9305 10
jproj.pl detcom_02 populate 9306 10
jproj.pl detcom_02 populate 9311 10
jproj.pl detcom_02 populate 9312 10
jproj.pl detcom_02 populate 9313 10
jproj.pl detcom_02 populate 9314 10
jproj.pl detcom_02 populate 9315 10
jproj.pl detcom_02 populate 9316 10
