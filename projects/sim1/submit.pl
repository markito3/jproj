#!/usr/bin/env perl

use DBI;
$user = "farmer";
$password = "";
$database = "farming";
$hostname = "hallddb.jlab.org";

$dbh = DBI->connect("DBI:mysql:$database:$hostname", $user, $password);

$jobtable = "sim1Job";

$sql = "select count(*) from sim1Job where status = 'PENDING'";
make_query($dbh, \$sth);
@row = $sth->fetchrow_array;
$npending = $row[0];
print "number of pending jobs = $npending\n";
if ($npending < 1000) {
    system "jproj.pl sim1 submit 1000\n";
}
exit;
#
# make a query
#
sub make_query {    

    my($dbh, $sth_ref) = @_;
    $$sth_ref = $dbh->prepare($sql)
        or die "Can't prepare $sql: $dbh->errstr\n";
    
    $rv = $$sth_ref->execute
        or die "Can't execute the query $sql\n error: $sth->errstr\n";
    
    return 0;
}
#
# end of file
#
