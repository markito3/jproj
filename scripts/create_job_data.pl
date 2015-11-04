#!/usr/bin/env perl

# load perl modules
use DBI;

# connect to the database
$host = 'halldweb1.jlab.org';
$user = 'farmer';
$password = '';
$database = 'farming2';

print "Connecting to $user\@$host, using $database.\n";
$dbh_db = DBI->connect("DBI:mysql:$database:$host", $user, $password);
if (defined $dbh_db) {
    print "Connection successful\n";
} else {
    die "Could not connect to the database server, exiting.\n";
}

open(OUTPUT, "> job_data.txt");
$sql = "select run, cput, vmem from dc_02Job;";
print "sql = $sql\n";
make_query($dbh_db, \$sth);
$count = 0;
while (@row = $sth->fetchrow_array) {
    $count++;
    $run = $row[0];
    $cput = $row[1];
    $vmem = $row[2];
    $length = length($cput);
    if ($length == 8) {
	@t0 = split(/:/, $cput);
	$hours = $t0[0];
	$minutes = $t0[1];
	$seconds = $t0[2];
	$hours_float = $hours + $minutes/60.0 + $seconds/3600.0;
	@t1 = split(/kb/, $vmem);
	$vmem_float = $t1[0]/1.0e6;
	if ($count%1000 == 0) {
	    print "$count $run $cput $hours $minutes $seconds $hours_float $vmem $vmem_float\n";
	}
	print OUTPUT "$run $hours_float $vmem_float\n";
    }
}
close(OUTPUT);
print "end count = $count\n";

exit;

sub make_query {    

    my($dbh, $sth_ref) = @_;
    $$sth_ref = $dbh->prepare($sql)
        or die "Can't prepare $sql: $dbh->errstr\n";
    
    $rv = $$sth_ref->execute
        or die "Can't execute the query $sql\n error: $sth->errstr\n";
    
    return 0;

}
