#!/usr/bin/env perl

use CGI;                             # load CGI routines
use DBI;
$user = "farmer";
$password = "";
$database = "farming";
$hostname = "hallddb.jlab.org";
$method = "GET";

$dbh = DBI->connect("DBI:mysql:$database:$hostname", $user, $password);

$q = new CGI;                        # create new CGI object
$title = "Farm Project Status";
print
    $q->header,
    $q->start_html($title), # start the HTML
    $q->h1($title),         # level 1 header
    "\n";

GetInputParameters();

if (! $button) {
    MakeProjectSelectPage();
} else {
    MakeJobListingPage();
}

exit;

sub MakeProjectSelectPage {
$sql = "show tables";
make_query($dbh, \$sth);
@projects = ();
$i = 0;
while (@row = $sth->fetchrow_array) {
    $project_this = $row[0];
    #print "project = $project_this\n";
    if ($project_this !~ /Job$/ && $project_this !~ /aux$/) {$projects[$i++] = $project_this;}
}
#print @projects;

print $q->startform(-method=>$method),
    'Project:',
    $q->popup_menu(-name=>'project', -values=>[ 'select a project', @projects ]),
    $q->submit(-name=>'button', -value=>'Display Jobs'),
    '<br>';
}

sub MakeJobListingPage {

$jobtable = $project . "Job";

$subtitle = "Jobs for project " . $project;
print $q->h2($subtitle);

print
    "<table border>\n",
    "<tr><th>id</th><th>jobId</th><th>run</th><th>file</th><th>timeSubmitted</th><th>timeActive</th><th>timeComplete</th><th>cput</th><th>hostname</th><th>status</th><th>result</th></tr>\n";

$sql = "select id, jobId, run, file, timeSubmitted, timeActive, timeComplete, cput, hostname, status, result from $jobtable order by run, file, jobId";
make_query($dbh, \$sth);
while (@row = $sth->fetchrow_array) {
    print "<tr>";
    for ($i = 0; $i <= $#row; $i++) {
	print "<td>$row[$i]</td>";
    }
    print "</tr>\n";
}
print "</table>\n";

print $q->end_html;                  # end the HTML
    
print "\n";
}

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
################################################################

sub GetInputParameters {
    @names = $q->param;
    foreach $in (0 .. $#names) {
        eval "\$$names[$in] = \$q->param('$names[$in]')";
#       print STDERR "param $in: $names[$in] = ${$names[$in]}\n"; 
    }
}

#################################################################
#
# end of file
#
