#!/usr/bin/env perl

# load perl modules
use DBI;

# connect to the database
$host = 'halldweb1.jlab.org';
$user = 'farmer';
$password = '';
$database = 'farming3';

print "Connecting to $user\@$host, using $database.\n";
$dbh_db = DBI->connect("DBI:mysql:$database:$host", $user, $password);
if (defined $dbh_db) {
    print "Connection successful\n";
} else {
    die "Could not connect to the database server, exiting.\n";
}

open(FIND, "find /work/halld/data_challenge/dc_02/logs -name \*.out|");
while ($file = <FIND>) {
#    print $file;
    chomp $file;
    @tok0 = split(/_/, $file);
#    print "$tok0[4], $tok0[5]\n";
    $runno = $tok0[4];
    @tok1 = split(/\./, $tok0[5]);
#    print "$tok1[0], $tok1[1]\n";
    $fileno = $tok1[0];
    $jobno = $tok1[1];
    if ($jobno) {
	$sql = "SELECT COUNT(*) from dc_02Job WHERE jobId = $jobno";
	make_query($dbh_db, \$sth);
	@row = $sth->fetchrow_array;
	$count = $row[0];
	if ($count == 0) {
	    $sql = "INSERT INTO dc_02Job SET run=$runno, file = $fileno, jobId = $jobno";
#	    print "sql = $sql\n";
	    make_query($dbh_db, \$sth);
	} elsif ($count == 1) {
#	    print "already inserted: $runno, $fileno, $jobno\n";
	} else {
	    die "inserted twice! disaster!";
	}
    } else {
	print "===========================================\n";
	print "= skipping file with undefined job number =\n";
	print "===========================================\n";
	print "file = $file\n";
    }
}
exit;

sub make_query {    

    my($dbh, $sth_ref) = @_;
    $$sth_ref = $dbh->prepare($sql)
        or die "Can't prepare $sql: $dbh->errstr\n";
    
    $rv = $$sth_ref->execute
        or die "Can't execute the query $sql\n error: $sth->errstr\n";
    
    return 0;

}
