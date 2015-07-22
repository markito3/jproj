#!/usr/bin/env perl

# load perl modules
use DBI;

# connect to the database
$host = 'halldweb1.jlab.org';
$user = 'farmer';
$password = '';
$database = 'farming';

#print "Connecting to $user\@$host, using $database.\n";
$dbh_db = DBI->connect("DBI:mysql:$database:$host", $user, $password);
if (defined $dbh_db) {
#    print "Connection successful\n";
} else {
    die "Could not connect to the database server, exiting.\n";
}

$table = "dc_02Job";
$incr = 15.0;
$i0 = 26*24*60/$incr;
for ($i = $i0; $i >= 0; $i--) {
    $delta = -$i*$incr;
    if ($i%100 == 0) {
	$delta_hours = $delta/60;
	print STDERR "i = $i, time = $delta_hours hours\n";
    }
    $sql = "select date_add(now(), interval $delta minute);";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    $date = $row[0];
    $sql = "select sum(1) from dc_02Job where (status = 'active' and timeStagingIn < \"$date\") OR (status = 'done' and timeStagingIn < \"$date\" and timeComplete > \"$date\");";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    $running = $row[0];
    if ($running) {
	$days = $delta/60.0/24.0;
	print "$days $running\n";
    }
}
exit;

sub make_query {    

    my($dbh, $sth_ref) = @_;
#    print "sql = $sql\n";
    $$sth_ref = $dbh->prepare($sql)
        or die "Can't prepare $sql: $dbh->errstr\n";
    
    $rv = $$sth_ref->execute
        or die "Can't execute the query $sql\n error: $sth->errstr\n";
    
    return 0;

}

