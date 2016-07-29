#!/usr/bin/env perl

# load perl modules

use DBI;
use XML::Simple;
use Data::Dumper;

# output file directory
$jsub_file_path = "/tmp";

if ($#ARGV == -1) {
    print_usage();
    exit 0;
}

$project = $ARGV[0];
$action = $ARGV[1];

read_project_parameters();

# connect to the database
$host = 'hallddb.jlab.org';
$user = 'farmer';
$password = '';
$database = 'farming2';

#print "Connecting to $user\@$host, using $database.\n";
$dbh_db = DBI->connect("DBI:mysql:$database:$host", $user, $password);
if (defined $dbh_db) {
    #print "Connection successful\n";
} else {
    die "Could not connect to the database server, exiting.\n";
}

if ($action eq 'create') {
    create();
} elsif ($action eq 'populate') {
    populate();
} elsif ($action eq 'add') {
    add();
} elsif ($action eq 'drop') {
    drop();
} elsif ($action eq 'update') {
    update();
} elsif ($action eq 'update_output') {
    update_output();
} elsif ($action eq 'update_silo') {
    update_silo();
} elsif ($action eq 'update_cache') {
    update_cache();
} elsif ($action eq 'run') {
    run();
} elsif ($action eq 'pause') {
    pause();
} elsif ($action eq 'unsubmit') {
    unsubmit();
} elsif ($action eq 'jput') {
    jput();
} elsif ($action eq 'jcache') {
    jcache();
} elsif ($action eq 'status') {
    status();
} elsif ($action eq 'update_auger') {
    update_auger();
} else {
    print "jproj error: $action is not a valid action\n";
}

#print "disconnecting from server\n";
$rc = $dbh_db->disconnect;

exit;

sub create {
    print "starting create\n";
    if ($ARGV[2]) {
	die "arguments to create action no longer allowed, use the populate action";
    }
    $sql = 
"CREATE TABLE $project (
  run int(11) NOT NULL default '0',
  file int(11) NOT NULL default '0',
  jobId int(11),
  added tinyint(4) NOT NULL default '0',
  output tinyint(4) NOT NULL default '0',
  jput_submitted tinyint(4) NOT NULL default '0',
  silo tinyint(4) NOT NULL default '0',
  jcache_submitted tinyint(4) NOT NULL default '0',
  cache tinyint(4) NOT NULL default '0',
  mod_time timestamp NOT NULL,
  PRIMARY KEY  (run,file)
) ENGINE=MyISAM;";
    make_query($dbh_db, \$sth);
    $sql = 
"CREATE TABLE ${project}Job (
  `augerId` int(11) DEFAULT NULL,
  `jobId` int(11) DEFAULT NULL,
  `timeChange` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `username` varchar(64) DEFAULT NULL,
  `project` varchar(64) DEFAULT NULL,
  `name` varchar(64) DEFAULT NULL,
  `queue` varchar(64) DEFAULT NULL,
  `hostname` varchar(64) DEFAULT NULL,
  `nodeTags` varchar(64) DEFAULT NULL,
  `coresRequested` int(11) DEFAULT NULL,
  `memoryRequested` int(11) DEFAULT NULL,
  `status` varchar(64) DEFAULT NULL,
  `exitCode` int(11) DEFAULT NULL,
  `result` varchar(64) DEFAULT NULL,
  `timeSubmitted` datetime DEFAULT NULL,
  `timeDependency` datetime DEFAULT NULL,
  `timePending` datetime DEFAULT NULL,
  `timeStagingIn` datetime DEFAULT NULL,
  `timeActive` datetime DEFAULT NULL,
  `timeStagingOut` datetime DEFAULT NULL,
  `timeComplete` datetime DEFAULT NULL,
  `walltime` varchar(8) DEFAULT NULL,
  `cput` varchar(8) DEFAULT NULL,
  `mem` varchar(64) DEFAULT NULL,
  `vmem` varchar(64) DEFAULT NULL,
  `script` varchar(1024) DEFAULT NULL,
  `files` varchar(1024) DEFAULT NULL,
  `error` varchar(1024) DEFAULT NULL,
  PRIMARY KEY (`augerId`)
) ENGINE=MyISAM;";

    make_query($dbh_db, \$sth);
# create new swif workflow
    $command = "swif create -workflow $project";
    print "jproj.pl create: command = $command\n";
    system $command;
}

sub populate {

    $run_number = $ARGV[2];
    $number_of_files = $ARGV[3];
    $sql = "select max(file) from $project where run = $run_number";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    $file_number_found = $row[0];
    if ($file_number_found) {
	print "populate: max file number found = $file_number_found\n";
    } else {
	print "populate: no files found\n";
    }
    if ($number_of_files ne '') {
	print "populate: $number_of_files additional files requested\n";
	for ($findex = $file_number_found + 1; $findex <= $file_number_found + $number_of_files; $findex++) {
	    $file_number = $findex;
	    $sql = "INSERT INTO $project SET run = $run_number, file = $file_number, added=0";
	    make_query($dbh_db, \$sth);
	}
    } else {
	print "populate: no files requested\n";
    }
}

sub update {

    chomp $inputFilePattern;
    print "inputFilePattern = $inputFilePattern\n";
    @token = split(/\//, $inputFilePattern);
    $name = $token[$#token];
    $name_escaped = $name;
    $name_escaped =~ s/\*/\\\*/g;
    @token2 = split(/$name_escaped/, $inputFilePattern);
    $dir = @token2[0];
    #print "dir = /$dir/, name = /$name/\n";
    @token3 = split(/\*/, $name);
    $prerun = $token3[0];
    $separator = $token3[1];
    $postfile = $token3[2];
    #print "prerun = /$prerun/, separator =  /$separator/, postfile = /$postfile/\n";
    $file_number_requested = $ARGV[2];
    if ($file_number_requested ne '') {
	print "file number requested = $file_number_requested\n";
    }
    open(FIND, "find $dir -maxdepth 1 -name \"$name\" |");
    while ($file = <FIND>) {
	chomp $file;
	#print "file = $file\n";
	@field = split(/$dir/, $file);
	$this_name = $field[1];
	#print "this_name = $this_name\n";
	@token4 = split(/$prerun/, $this_name);
	$this_name = $token4[1];
	#print "this_name = $this_name\n";
	if ($postfile) {
	    @token5 = split(/$postfile/, $this_name);
	    $this_name = @token5[0];
	}
	#print "this_name = $this_name\n";
	@token6 = split(/$separator/, $this_name);
	$run = $token6[0];
	$file_number = $token6[1];
	if ($file_number_requested eq '' || $file_number_requested == $file_number) {
	    $sql = "SELECT * FROM $project WHERE run = $run and $file_number = file";
	    make_query($dbh_db, \$sth);
	    $nrow = 0;
	    while ($hashref = $sth->fetchrow_hashref) {
		$nrow++;
	    }
	    if ($nrow == 0) {
		print "new run: $run, file: $file_number\n";
		$sql = "INSERT INTO $project SET run=$run, file = $file_number, added=0";
		make_query($dbh_db, \$sth);
	    } elsif ($nrow > 1) {
		die "error too many entries for run $run"; 
	    }
	}
    }
    close(FIND);

}

sub update_output {
    $pattern_run_only = $ARGV[2];
    if ($pattern_run_only ne '') {
	print "file pattern will include only run number\n";
    }
    $sql = "SELECT run, file FROM $project WHERE added = 1 AND output = 0 order by run, file";
    make_query($dbh_db, \$sth);
    $nprocessed = 0;
    $nfound = 0;
    $rf_separator = '_';
    while (@row = $sth->fetchrow_array) {
	$run = sprintf($run_format, $row[0]);
	$file = sprintf($file_format, $row[1]);
	if ($pattern_run_only) {
	    $file_pattern = $run;
	} else {
	    $file_pattern = $run . $rf_separator . $file;
	}
	open(FIND, "find $outputFileDir -maxdepth 1 -name \*$file_pattern\* |");
	$nfile = 0;
	while ($filefound = <FIND>) {
	    $filename = $filefound; # for use outside loop
	    $nfile++;
	}
	close(FIND);
	chomp $filename;
	$output = 0;
	if ($nfile == 1) {
	    if (-f $filename) {
		$output = 1;
		$nfound++;
	    } else {
		print "removing dead link: $filename\n";
		unlink $filename;
	    }
	} elsif ($nfile > 1) {
	    print "Run $run File $file has more than one output files\n";
	}
	$sql = "UPDATE $project SET output = $output WHERE run=$run and file=$file";
	make_query($dbh_db, \$sth2);
	$nprocessed++;
	if ($nprocessed%100 == 0) {
	    print "last pattern = $file_pattern, processed = $nprocessed, found = $nfound\n";
	}
    }
    print "last pattern = $file_pattern, processed = $nprocessed, found = $nfound\n";
}

sub update_silo {
    $pattern_run_only = $ARGV[3];
    if ($pattern_run_only ne '') {
	print "file pattern will include only run number\n";
    }
    $sql = "SELECT run, file FROM $project WHERE jput_submitted = 1 AND silo = 0 order by run, file\;";
    make_query($dbh_db, \$sth);
    $nprocessed = 0;
    $nfound = 0;
    while (@row = $sth->fetchrow_array) {
	$run = sprintf($run_format, $row[0]);
	$file = sprintf($file_format, $row[1]);
	if ($pattern_run_only) {
	    $file_pattern = $run;
	} else {
	    $file_pattern = $run . '_' . $file;
	}
	open(FIND, "find $tapeFileDir -maxdepth 1 -name \*$file_pattern\* |");
	$nfile = 0;
	while ($filefound = <FIND>) {
	    $filename = $filefound; # for use outside loop
	    $nfile++;
	}
	close(FIND);
	chomp $filename;
	$silo = 0;
	if ($nfile == 1) {
	    if (-f $filename) {
		$silo = 1;
		$nfound++;
	    }
	} elsif ($nfile > 1) {
	    print "Run $run File $file has more than one output files\n";
	}
	$sql = "UPDATE $project SET silo = $silo WHERE run=$run and file=$file";
	make_query($dbh_db, \$sth2);
	$nprocessed++;
	if ($nprocessed%100 == 0) {
	    print "last pattern = $file_pattern, processed = $nprocessed, found = $nfound\n";
	}
    }
    print "last pattern = $file_pattern, processed = $nprocessed, found = $nfound\n";
}

sub update_cache {
    $pattern_run_only = $ARGV[2];
    if ($pattern_run_only ne '') {
	print "file pattern will include only run number\n";
    }
    $sql = "SELECT run, file FROM $project WHERE jcache_submitted = 1 AND cache = 0";
    make_query($dbh_db, \$sth);
    $nprocessed = 0;
    $nfound = 0;
    $cache_dir = "/cache" . $tapeFileDir;
    while (@row = $sth->fetchrow_array) {
	$run = sprintf("%05d", $row[0]);
	$file = sprintf("%07d", $row[1]);
	if ($pattern_run_only) {
	    $file_pattern = $run;
	} else {
	    $file_pattern = $run . '_' . $file;
	}
	open(FIND, "find $cache_dir -maxdepth 1 -name \*$file_pattern\* |");
	$nfile = 0;
	while ($filefound = <FIND>) {
	    $filename = $filefound; # for use outside loop
	    $nfile++;
	}
	close(FIND);
	chomp $filename;
	$cache = 0;
	if ($nfile == 1) {
	    if (-f $filename) {
		$cache = 1;
		$nfound++;
	    }
	} elsif ($nfile > 1) {
	    print "Run $run File $file has more than one output files\n";
	}
	$sql = "UPDATE $project SET cache = $cache WHERE run=$run and file=$file";
	make_query($dbh_db, \$sth2);
	$nprocessed++;
	if ($nprocessed%100 == 0) {
	    print "last pattern = $file_pattern, processed = $nprocessed, found = $nfound\n";
	}
    }
    print "last pattern = $file_pattern, processed = $nprocessed, found = $nfound\n";
}

sub add {
    $limit = $ARGV[2];
    $run_choice = $ARGV[3];
    if ($limit == 0 or $limit eq '') {
	$limit = 1000000;
    }
    print "limit = $limit\n";

    if ($run_choice) {
	$sql = "SELECT run, file FROM $project WHERE added=0 AND run=$run_choice limit $limit";
    } else {
	$sql = "SELECT run, file FROM $project WHERE added=0 limit $limit";
    }
    make_query($dbh_db, \$sth);
    $i = 0;
    while (@row = $sth->fetchrow_array) {
	$run_array[$i] = $row[0];
	$file_array[$i] = $row[1];
	$i++;
    }
    $j = 0;
    while ($j < $i && $j < $limit) {
	$run_this = $run_array[$j];
	$file_this = $file_array[$j];
	printf ">>>adding run $run_this file $file_this<<<\n";
	$jobId = add_one($run_this, $file_this);
	$sql = "UPDATE $project SET jobId = $jobId, added = 1 where run=$run_this AND file=$file_this";
	make_query($dbh_db, \$sth);
	$j++;
    }
}

sub add_one {
    my($run_in, $file_in) = @_;
    my $job_id = "job index undefined";
    $run = sprintf($run_format, $run_in);
    $file = sprintf($file_format, $file_in);
    $jsub_file = "$jsub_file_path/${project}_${run}_${file}.jsub";
    open(JSUB, ">$jsub_file");
    $jsub_file_template = "$project.jsub";
    if (-e $jsub_file_template) {
	open(JSUB_TEMPLATE, "$jsub_file_template");
	while ($line = <JSUB_TEMPLATE>) {
	    if ($line =~ /INPUT_FILES:/) {
		$line = "INPUT_FILES: " . $inputFilePattern . "\n";
		$line =~ s/\*/{run_number}/;
		$line =~ s/\*/{file_number}/;
	    }
	    $line =~ s/{project}/$project/g;
	    $line =~ s/{run_number}/$run/g;
	    $line =~ s/{file_number}/$file/g;
	    print JSUB $line;
	}
	close(JSUB);
	close(JSUB_TEMPLATE);
	$command_swif = "swif add-jsub -workflow $project -script $jsub_file";
	$command = "$command_swif | perl -n -e \'if (/id\\s+= /) {split \" = \"; print \$_\[1\];}\'";
	#print "jproj.pl add: command = $command_swif\n";
	$job_id = `$command`;
	#print "job_id = $job_id\n";
    } else {
	die "error: jsub file template $jsub_file_template does not exist";
    }
    return $job_id;
}

sub unsubmit {
    $run = $ARGV[2];
    $file = $ARGV[3];
    print "run = $run, file = $file\n";
    $sql = "SELECT added FROM $project WHERE run = $run AND file = $file";
    make_query($dbh_db, \$sth);
    $added = 0;
    $nrow = 0;
    while (@column = $sth->fetchrow_array) {
	$nrow++;
	$added = $column[0];
    }
    if ($nrow > 1) {die "more than one entry for run/file";}
    if ($added != 1) {die "job never added or run/file does not exist";}
    $sql = "UPDATE $project SET added = 0 WHERE run = $run AND file = $file";
    make_query($dbh_db, \$sth);
}

sub jput {
    $pattern_run_only = $ARGV[2];
    $nfile_max = $ARGV[3];
    if ($tapeFileDir !~ /\/$/) {
	$tapeFileDir .= '/';     # add trailing "/"
    }
    if ($pattern_run_only) {
	print "file pattern will include only run number\n";
    }
    $sql = "SELECT run, file FROM $project WHERE added = 1 AND output = 1 AND jput_submitted = 0 order by run, file";
    if ($nfile_max) {
	$sql .= " limit $nfile_max"
    }
    make_query($dbh_db, \$sth);
    $nfile = 0;
    while (@column = $sth->fetchrow_array) {
	if ($nfile%100 == 0) {
	    if ($nfile != 0) {
		jput_it();
	    }
	    $command = "cd $outputFileDir ; jput";
	}
	$run = sprintf("%05d", $column[0]);
	$file = sprintf("%07d", $column[1]);
	if ($pattern_run_only) {
	    $file_pattern = $run;
	} else {
	    $file_pattern = $run . '_' . $file;
	}
	$command .= " \*$file_pattern\*";
	$sql = "UPDATE $project SET jput_submitted = 1 WHERE run = $run AND file = $file";
	make_query($dbh_db, \$sth2);
	$nfile++;
    }
    if ($nfile > 0) {
	jput_it();
    }
    print "jput $nfile files\n";
}

sub jput_it {
# called from multiple places, whenever $sql is ready to finish and ship
    $command .= " $tapeFileDir";
    print "jproj.pl jput: command = $command\n";
    system $command;
}

sub jcache {
    $pattern_run_only = $ARGV[2];
    if ($pattern_run_only ne '') {
	print "file pattern will include only run number\n";
    }
    $sql = "SELECT run, file FROM $project WHERE added = 1 AND silo = 1 AND jcache_submitted = 0";
    make_query($dbh_db, \$sth);
    $nfile = 0;
    while (@column = $sth->fetchrow_array) {
	if ($nfile%100 == 0) {
	    if ($nfile != 0) {
		jcache_it();
	    }
	    $command = "jcache submit halld";
	}
	$run = sprintf("%05d", $column[0]);
	$file = sprintf("%07d", $column[1]);
	if ($pattern_run_only) {
	    $file_pattern = $run;
	} else {
	    $file_pattern = $run . '_' . $file;
	}
	$command .= " $tapeFileDir/\*$file_pattern\*";
	$sql = "UPDATE $project SET jcache_submitted = 1 WHERE run = $run AND file = $file";
	make_query($dbh_db, \$sth2);
	$nfile++;
    }
    jcache_it();
}

sub jcache_it {
    system $command;
}

sub drop {
    $sql = "drop table $project, ${project}Job";
    make_query($dbh_db, \$sth);
    system "swif cancel $project";
}

sub run {
    $job_limit = $ARGV[2];
    $command = "swif run $project";
    if ($job_limit) {
	$command = $command . " -joblimit $job_limit";
    }
    print "jproj.pl info: $command\n";
    system $command;
}

sub pause {
    $command = "swif pause $project";
    print "jproj.pl info: $command\n";
    system $command;
}

sub status {

    $sql = "select count(*) from $project;";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    print "total = $row[0]\n";

    $sql = "select count(*) from $project where added = 1;";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    print "added = $row[0]\n";

    $sql = "select count(*) from $project where output = 1;";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    print "output = $row[0]\n";

    $sql = "select count(*) from $project where jput_submitted = 1;";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    print "jput_submitted = $row[0]\n";

    $sql = "select count(*) from $project where silo = 1;";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    print "silo = $row[0]\n";

    $sql = "select count(*) from $project where jcache_submitted = 1;";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    print "jcache_submitted = $row[0]\n";

    $sql = "select count(*) from $project where cache = 1;";
    make_query($dbh_db, \$sth);
    @row = $sth->fetchrow_array;
    print "cache = $row[0]\n";

    $sth->finish();

    $command = "swif status $project";
    print "jproj.pl info: $command\n";
    system $command;

}

sub read_project_parameters {
    $debug_xml = 0;
    # slurp in the xml file
    $ref = XMLin("${project}.jproj", KeyAttr=>[]);
    # dump it to the screen for debugging only
    if ($debug_xml) {print Dumper($ref);}
    $runDigits = $ref->{digits}->{run};
    $fileDigits = $ref->{digits}->{file};
    $run_format = "%0${runDigits}d";
    $file_format = "%0${fileDigits}d";
    $inputFilePattern = $ref->{inputFilePattern};
    $outputFileDir = $ref->{outputFileDir};
    $tapeFileDir = $ref->{tapeFileDir};
    if ($debug_xml) {
	print "inputFilePattern = $inputFilePattern\n";
	print "outputFileDir = $outputFileDir\n";
	print "tapeFileDir = $tapeFileDir\n";
    }
    return;
}

sub update_auger {
    $temp_file = "/tmp/jproj_${project}_auger.xml";
    system("rm -fv $temp_file");
    system("swif status -workflow=$project -jobs -display=xml > $temp_file");
#    open the file and parse it

    my $debug_xml = 0;
    # slurp in the xml file
    my $ref = XMLin($temp_file, KeyAttr=>[], ForceArray => ['attempt']);
    # dump it to the screen for debugging only
    if ($debug_xml) {
	print "====== begin dump =========\n";
	print Dumper($ref);
	print "====== end dump =========\n";
    }
#    add each entry indiscriminantly and give up if an error occurs because auger id should be a primary key
    my $jobs = $ref->{jobs}; # hash reference
    my $job = $jobs->{job}; # array reference
    my @jobarray = @$job; # array
    if ($debug_xml) {my $l = $#jobarray + 1; print "njobs = ", $l, "\n";}
    $jobtable = $project . "Job";
    for ($i = 0; $i <= $#jobarray; $i++) {
	%thisjobhash = %{$jobarray[$i]};
	$attempts = $thisjobhash{attempts};
	$attempt = $attempts->{attempt};
	my $jobid = $thisjobhash{id};
	if ($debug_xml) {print " thisjobhash{name} = ", $thisjobhash{name}, " jobid = ", $jobid, "\n";}
	foreach $this_attempt_element (@$attempt) {
	    $augerid = $this_attempt_element->{auger_id};
	    if ($debug_xml) {print " attempt augerid = ", $augerid, "\n";}
	    $sql = "SELECT count(*) from $jobtable where augerId = $augerid;";
	    make_query($dbh_db, \$sth);
	    my $count = $sth->fetchrow_array();
	    if ($debug_xml) {print "count = $count\n";}
	    $sth->finish;
	    if (! $count) {
		print "found new attempt, jobid = ", $jobid, ", augerid = ", $augerid, "\n";
		$sql = "INSERT into $jobtable set jobId = $jobid, augerId = $augerid;";
		if ($debug_xml) {print $sql, "\n";}
		make_query($dbh_db, \$sth);
	    }
	}
    }
#    my $attempts = $job[0]{attempts}; 
    $ref=>
    return;
}

sub make_query {    

    my($dbh, $sth_ref) = @_;
    $$sth_ref = $dbh->prepare($sql)
        or die "Can't prepare $sql: $dbh->errstr\n";
    
    $rv = $$sth_ref->execute
	or die "Can't execute the query $sql\n error: $sth->errstr\n";
    
    return 0;

}

sub print_usage {
    print <<EOM;
jproj.pl: manages a JLab batch farm project

usage:

jproj.pl <project> <action> <arg1> <arg2> ...

actions:

create
    Note: creates database tables only
 
populate
    arg1: run number
    arg2: number of files to add for this run
    Note: use populate action only if project is not driven by input data
          files, "update" action will then never be necessary for this project

update
    arg1: file number to use; if omitted all file numbers will be used

add : add jobs to the workflow

update_auger : get auger ids for added jobs

update_output
    arg1: if present and non-zero, use only run number in file pattern search

update_silo
    arg1: mss directory
    arg2: if present and non-zero, use only run number in file pattern search

update_cache
    arg1: if present and non-zero, use only run number in file pattern search

run : run the workflow
    arg1: if present and non-zero, sets job limit, number of jobs to attempt
          before pausing

pause : pause the workflow

unsubmit
    arg1: run number
    arg2: file number

jput
    arg1: if present and non-zero, use only run number in file pattern for jput
    arg2: if present and non-zero, jput at most this many files

jcache
    arg1: if present and non-zero, use only run number in file pattern for jcache
EOM
}
