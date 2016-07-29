#!/bin/bash
# delete the project and start over
swif cancel -workflow sim1_root2tape -delete
mysql -hhallddb -ufarmer farming2 -e "drop table sim1_root2tape; drop table sim1_root2tapeJob"
jproj.pl sim1_root2tape create

