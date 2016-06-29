#!/bin/bash
# delete the project and start over
swif cancel -workflow sim1_smeared2tape -delete
mysql -hhallddb -ufarmer farming2 -e "drop table sim1_smeared2tape; drop table sim1_smeared2tapeJob"
jproj.pl sim1_smeared2tape create

