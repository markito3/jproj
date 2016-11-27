#!/bin/sh
# delete the project and start over
exists=`swif list | grep workflow_name | perl -n -e 'chomp; @t = split(/= /); print $t[1], "\n";'`
echo exists = $exists
if [ "test" = $exists ]
    then
    swif cancel test -delete
fi
mysql -hhallddb -ufarmer farming3 -e "drop table test; drop table testJob; drop table testOutput; drop table testOutputType"
jproj.pl test create
