#!/usr/bin/env perl

sub help{
    print "help!\n";
}

# load perl modules
use DBI;
use Getopt::Std;
use DateTime;
use DateTime::Format::MySQL;
use DateTime::Format::Duration;

# process options

getopts('p:b:e:i:h');
$project = $opt_p;
$time_begin = $opt_b; # sql date-time format
$time_end = $opt_e; # sql date-time format
$increment = $opt_i; # in minutes
$help = $opt_h;

if ($help) {
    help();
    exit 0;
}

# connect to the database
$host = 'hallddb.jlab.org';
$user = 'farmer';
$password = '';
$database = 'farming2';

#print "Connecting to $user\@$host, using $database.\n";
$dbh_db = DBI->connect("DBI:mysql:$database:$host", $user, $password);
if (defined $dbh_db) {
#    print "Connection successful\n";
} else {
    die "Could not connect to the database server, exiting.\n";
}

$dt_beg = DateTime::Format::MySQL->parse_datetime($time_begin);
$dt_end = DateTime::Format::MySQL->parse_datetime($time_end);
print STDERR "begin: ", $dt_beg->datetime, " end: ", $dt_end->datetime, "\n";
$dur = $dt_end - $dt_beg;
$durfmt = DateTime::Format::Duration->new(pattern => '%s');

print STDERR "duration: ", $durfmt->format_duration($dur), " seconds \n";
$increment_s = $increment*60;
$n = $durfmt->format_duration($dur)/$increment_s;

$table = $project . "Job";

for ($i = 0; $i < $n; $i++) {
    $dt = $dt_beg + $durfmt->parse_duration($i*$increment_s);
    $ymd = $dt->ymd; $hms = $dt->hms;
    $date = "$ymd $hms";
    if ($i%100 == 0) {
	$delta_hours = $delta/60;
	print STDERR "i = $i, time = $date\n";
    }
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
    print "$i $date $dependent $pending $running\n";
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

