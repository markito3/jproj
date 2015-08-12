#!/bin/bash
# delete the project and start over
mysql -hhallddb -ufarmer farming -e "drop table detcom_02_recon; drop table detcom_02_reconJob"
jproj.pl detcom_02_recon create
jproj.pl detcom_02_recon update
mysql -hhallddb -ufarmer farming -e "delete from detcom_02_recon where run > 9310"
