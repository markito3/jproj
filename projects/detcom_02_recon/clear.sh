#!/bin/bash
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table detcom_02_recon; drop table detcom_02_reconJob"
jproj.pl detcom_02_recon create

jproj.pl detcom_02_recon populate 9301 10
jproj.pl detcom_02_recon populate 9302 10
jproj.pl detcom_02_recon populate 9303 10
jproj.pl detcom_02_recon populate 9304 10
jproj.pl detcom_02_recon populate 9305 10
jproj.pl detcom_02_recon populate 9306 10
jproj.pl detcom_02_recon populate 9311 10
jproj.pl detcom_02_recon populate 9312 10
jproj.pl detcom_02_recon populate 9313 10
jproj.pl detcom_02_recon populate 9314 10
jproj.pl detcom_02_recon populate 9315 10
jproj.pl detcom_02_recon populate 9316 10

jproj.pl detcom_02_recon populate 9301 90
jproj.pl detcom_02_recon populate 9302 90
jproj.pl detcom_02_recon populate 9303 90
jproj.pl detcom_02_recon populate 9304 90
jproj.pl detcom_02_recon populate 9305 90
jproj.pl detcom_02_recon populate 9306 90
jproj.pl detcom_02_recon populate 9311 90
jproj.pl detcom_02_recon populate 9312 90
jproj.pl detcom_02_recon populate 9313 90
jproj.pl detcom_02_recon populate 9314 90
jproj.pl detcom_02_recon populate 9315 90
jproj.pl detcom_02_recon populate 9316 90

jproj.pl detcom_02_recon populate 9301 900
jproj.pl detcom_02_recon populate 9305 900
jproj.pl detcom_02_recon populate 9306 900
jproj.pl detcom_02_recon populate 9311 900
jproj.pl detcom_02_recon populate 9315 900
jproj.pl detcom_02_recon populate 9316 900

jproj.pl detcom_02_recon populate 9301 1000
jproj.pl detcom_02_recon populate 9305 1000
jproj.pl detcom_02_recon populate 9306 1000
jproj.pl detcom_02_recon populate 9311 1000
jproj.pl detcom_02_recon populate 9315 1000
jproj.pl detcom_02_recon populate 9316 1000

jproj.pl detcom_02_recon populate 9301 1000
jproj.pl detcom_02_recon populate 9305 1000
jproj.pl detcom_02_recon populate 9306 1000
jproj.pl detcom_02_recon populate 9311 1000
jproj.pl detcom_02_recon populate 9315 1000
jproj.pl detcom_02_recon populate 9316 1000

jproj.pl detcom_02_recon populate 9301 1000
jproj.pl detcom_02_recon populate 9305 1000
jproj.pl detcom_02_recon populate 9306 1000
jproj.pl detcom_02_recon populate 9311 1000
jproj.pl detcom_02_recon populate 9315 1000
jproj.pl detcom_02_recon populate 9316 1000

jproj.pl detcom_02_recon populate 9301 1000
jproj.pl detcom_02_recon populate 9305 1000
jproj.pl detcom_02_recon populate 9306 1000
jproj.pl detcom_02_recon populate 9311 1000
jproj.pl detcom_02_recon populate 9315 1000
jproj.pl detcom_02_recon populate 9316 1000
