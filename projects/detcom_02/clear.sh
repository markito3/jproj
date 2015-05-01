#/bin/sh
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table detcom_02; drop table detcom_02Job"
jproj.pl detcom_02 create
jproj.pl detcom_02 populate 9301 3
jproj.pl detcom_02 populate 9302 3
jproj.pl detcom_02 populate 9303 3
jproj.pl detcom_02 populate 9304 3
jproj.pl detcom_02 populate 9305 3
jproj.pl detcom_02 populate 9306 3
jproj.pl detcom_02 populate 9311 3
jproj.pl detcom_02 populate 9312 3
jproj.pl detcom_02 populate 9313 3
jproj.pl detcom_02 populate 9314 3
jproj.pl detcom_02 populate 9315 3
jproj.pl detcom_02 populate 9316 3
