#!/usr/bin/env perl

# load perl modules
use DBI;

# connect to the database
$host = 'hallddb.jlab.org';
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

$table = "dc_03_reconJob";
$incr = 0.5;
$i0 = 1.2*24*60/$incr;
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
# running
    $sql = "select sum(1) from dc_03_reconJob where (status = 'active' and timeActive < \"$date\") OR (status = 'done' and timeActive < \"$date\" and timeStagingOut > \"$date\");";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    $running = $row[0];
    if (! $running) {$running = 0;}
# dependent
    $sql = "select sum(1) from dc_03_reconJob where (status = 'dependency' and timeDependency < \"$date\") OR (status = 'done' and timeDependency < \"$date\" and timePending > \"$date\");";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    $dependent = $row[0];
    if (! $dependent) {$dependent = 0;}
# pending
    $sql = "select sum(1) from dc_03_reconJob where (status = 'pending' and timePending < \"$date\") OR (status = 'done' and timePending < \"$date\" and timeStagingIn > \"$date\");";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    $pending = $row[0];
    if (! $pending) {$pending = 0;}
#
    $days = $delta/60.0/24.0;
    print "$days $dependent $pending $running\n";
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

