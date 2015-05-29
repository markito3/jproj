#!/bin/bash
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table detcom_02; drop table detcom_02Job"
jproj.pl detcom_02 create
jproj.pl detcom_02 populate 9301 1
jproj.pl detcom_02 populate 9302 1
jproj.pl detcom_02 populate 9303 1
jproj.pl detcom_02 populate 9304 1
jproj.pl detcom_02 populate 9305 1
jproj.pl detcom_02 populate 9306 1
jproj.pl detcom_02 populate 9311 1
jproj.pl detcom_02 populate 9312 1
jproj.pl detcom_02 populate 9313 1
jproj.pl detcom_02 populate 9314 1
jproj.pl detcom_02 populate 9315 1
jproj.pl detcom_02 populate 9316 1
