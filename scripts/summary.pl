#!/usr/bin/env perl

use DBI;

if ($#ARGV == -1) {
    print_usage();
    exit 1;
}

$project = $ARGV[0];

# connect to the database

$host = 'hallddb.jlab.org';
$user = 'farmer';
$password = '';
$database = 'farming';
print "Connecting to $user\@$host, using $database.\n";
$dbh_db = DBI->connect("DBI:mysql:$database:$host", $user, $password);
if (defined $dbh_db) {
    print "Connection successful\n";
} else {
    die "Could not connect to the database server, exiting.\n";
}

$sql = "select count(*) from $project;";
make_query($dbh_db, \$sth, $sql);
@row = $sth->fetchrow_array;
print "total = $row[0]\n";

$sql = "select count(*) from $project where submitted = 1;";
make_query($dbh_db, \$sth, $sql);
@row = $sth->fetchrow_array;
print "submitted = $row[0]\n";

$sql = "select count(*) from $project where output = 1;";
make_query($dbh_db, \$sth, $sql);
@row = $sth->fetchrow_array;
print "output = $row[0]\n";

$sql = "select count(*) from $project where jput_submitted = 1;";
make_query($dbh_db, \$sth, $sql);
@row = $sth->fetchrow_array;
print "jput_submitted = $row[0]\n";

$sql = "select count(*) from $project where silo = 1;";
make_query($dbh_db, \$sth, $sql);
@row = $sth->fetchrow_array;
print "silo = $row[0]\n";

$sql = "select count(*) from $project where jcache_submitted = 1;";
make_query($dbh_db, \$sth, $sql);
@row = $sth->fetchrow_array;
print "jcache_submitted = $row[0]\n";

$sql = "select count(*) from $project where cache = 1;";
make_query($dbh_db, \$sth, $sql);
@row = $sth->fetchrow_array;
print "cache = $row[0]\n";

exit;

sub make_query {    
    my($dbh, $sth_ref, $sql) = @_;
    $$sth_ref = $dbh->prepare($sql)
        or die "Can't prepare $sql: $dbh->errstr\n";
    $rv = $$sth_ref->execute
        or die "Can't execute the query $sql\n error: $sth->errstr\n";
    return 0;
}

sub print_usage {
    print <<EOM;
summary.pl: print a summary of project status

usage:

summary.pl <project>

EOM
}
