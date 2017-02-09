#!/usr/bin/env perl

use DBI;

$project = "sim1_2_1";

# connect to the database
$host = 'hallddb.jlab.org';
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

open(RUNS, "/work/halld/home/gxproj3/rp2016-02-runs_events");
while (<RUNS>) {
    chomp;
    @t = split;
    $run = $t[0];
    $events = $t[1];
    $n = $events/300000*0.3;
    $sql = "select count(*) from $project where run = $run;";
    make_query($dbh_db, $sql, \$sth);
    @row = $sth->fetchrow_array;
    $n_added = $row[0];
    $n_togo = $n - $n_added;
    $n_this = int($n_togo*0.25 + 0.5);
    print "#$run $events $n $n_added $n_togo $n_this\n";
    print "jproj.pl sim1_2_1 populate $run $n_this\n";
}
exit;

sub make_query {    

    my($dbh, $sql, $sth_ref) = @_;
    #print "sql = $sql\n";
    $$sth_ref = $dbh->prepare($sql)
        or die "Can't prepare $sql: $dbh->errstr\n";
    
    $rv = $$sth_ref->execute
        or die "Can't execute the query $sql\n error: $sth->errstr\n";
    
    return 0;

}
