#!/usr/bin/env perl

# load perl modules

use DBI;

# output file directory
$jsub_file_path = "/tmp";

if ($#ARGV == -1) {
    print_usage();
    exit 0;
}

$project = $ARGV[0];
$action = $ARGV[1];

# connect to the database
$host = 'halldweb1.jlab.org';
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

if ($action eq 'create') {
    create();
} elsif ($action eq 'update') {
    update();
} elsif ($action eq 'update_output') {
    update_output();
} elsif ($action eq 'update_silo') {
    update_silo();
} elsif ($action eq 'update_cache') {
    update_cache();
} elsif ($action eq 'submit') {
    submit();
} elsif ($action eq 'unsubmit') {
    unsubmit();
} elsif ($action eq 'jput') {
    jput();
} elsif ($action eq 'jcache') {
    jcache();
} else {
    print "no valid action requested\n";
}

print "disconnecting from server\n";
$rc = $dbh_db->disconnect;

sub create {
    $sql = 
"CREATE TABLE $project (
  run int(11) NOT NULL default '0',
  file mediumint(9) NOT NULL default '0',
  submitted tinyint(4) NOT NULL default '0',
  output tinyint(4) NOT NULL default '0',
  jput_submitted tinyint(4) NOT NULL default '0',
  silo tinyint(4) NOT NULL default '0',
  jcache_submitted tinyint(4) NOT NULL default '0',
  cache tinyint(4) NOT NULL default '0',
  mod_time timestamp(14) NOT NULL,
  PRIMARY KEY  (run,file)
) TYPE=MyISAM;";
    make_query($dbh_db, \$sth);
    $number_of_files = $ARGV[2];
    if ($number_of_files ne '') {
	print "create: $number_of_files runs requested\n";
	for ($findex = 1; $findex <= $number_of_files; $findex++) {
	    $file_number = $findex;
	    $sql = "INSERT INTO $project SET run=9000, file = $file_number, submitted=0"; # hard wired run number!
	    make_query($dbh_db, \$sth);
    }
    } else{
	print "create: no runs requested\n";
    }
}

sub update {

    open(CONFIG, "${project}.jproj");
    $input_string = <CONFIG>;
    chomp $input_string;
#    print "$input_string\n";
    @token = split(/\//, $input_string);
    $name = $token[$#token];
    $name_escaped = $name;
    $name_escaped =~ s/\*/\\\*/g;
    @token2 = split(/$name_escaped/, $input_string);
    $dir = @token2[0];
#    print "$dir $name\n";
    @token3 = split(/\*/, $name);
    $prerun = $token3[0];
    $separator = $token3[1];
    $postfile = $token3[2];
#    print "$prerun $separator $postfile\n";
    $file_number_requested = $ARGV[2];
    if ($file_number_requested ne '') {
	print "file number requested = $file_number_requested\n";
    }
    open(FIND, "find $dir -maxdepth 1 -name \"$name\" |");
    while ($file = <FIND>) {
	chomp $file;
#	print "file = $file\n";
	@field = split(/$dir/, $file);
	$this_name = $field[1];
#	print "this_name = $this_name\n";
	@token4 = split(/$prerun/, $this_name);
	$this_name = $token4[1];
#	print "this_name = $this_name\n";
	if ($postfile) {
	    @token5 = split(/$postfile/, $this_name);
	    $this_name = @token5[0];
	}
#	print "this_name = $this_name\n";
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
		$sql = "INSERT INTO $project SET run=$run, file = $file_number, submitted=0";
		make_query($dbh_db, \$sth);
	    } elsif ($nrow > 1) {
		die "error too many entries for run $run"; 
	    }
	}
    }
    close(FIND);

}

sub update_output {
    $output_dir = $ARGV[2];
    $pattern_run_only = $ARGV[3];
    if ($pattern_run_only ne '') {
	print "file pattern will include only run number\n";
    }
    $sql = "SELECT run, file FROM $project";
    make_query($dbh_db, \$sth);
    $nprocessed = 0;
    $nfound = 0;
    while (@row = $sth->fetchrow_array) {
	$run = sprintf("%05d", $row[0]);
	$file = sprintf("%02d", $row[1]);
	if ($pattern_run_only) {
	    $file_pattern = $run;
	} else {
	    $file_pattern = $run . '_' . $file;
	}
	open(FIND, "find $output_dir -maxdepth 1 -name \*$file_pattern\* |");
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
    $silo_dir = $ARGV[2];
    $pattern_run_only = $ARGV[3];
    if ($pattern_run_only ne '') {
	print "file pattern will include only run number\n";
    }
    $sql = "SELECT run, file FROM $project";
    make_query($dbh_db, \$sth);
    $nprocessed = 0;
    $nfound = 0;
    while (@row = $sth->fetchrow_array) {
	$run = sprintf("%05d", $row[0]);
	$file = sprintf("%02d", $row[1]);
	if ($pattern_run_only) {
	    $file_pattern = $run;
	} else {
	    $file_pattern = $run . '_' . $file;
	}
	open(FIND, "find $silo_dir -maxdepth 1 -name \*$file_pattern\* |");
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
    $cache_dir = $ARGV[2];
    $pattern_run_only = $ARGV[3];
    if ($pattern_run_only ne '') {
	print "file pattern will include only run number\n";
    }
    $sql = "SELECT run, file FROM $project";
    make_query($dbh_db, \$sth);
    $nprocessed = 0;
    $nfound = 0;
    while (@row = $sth->fetchrow_array) {
	$run = sprintf("%05d", $row[0]);
	$file = sprintf("%02d", $row[1]);
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

sub submit {
    $limit = $ARGV[2];
    if ($limit == 0 or $limit eq '') {
	$limit = 1000000;
    }
    print "limit = $limit\n";

    $sql = "SELECT run, file FROM $project WHERE submitted=0 order by run, file limit $limit";
    make_query($dbh_db, \$sth);
    $i = 0;
    while (@row = $sth->fetchrow_array) {
	$run_array[$i] = $row[0];
	$file_array[$i] = $row[1];
	$i++;
    }
    for ($j = 0; $j < $i; $j++) {
	$run_this = $run_array[$j];
	$file_this = $file_array[$j];
	printf ">>>submitting run $run_this file $file_this<<<\n";
	submit_one($run_this, $file_this);
	$sql = "UPDATE $project SET submitted=1 WHERE run=$run_this and file=$file_this";
	make_query($dbh_db, \$sth);
    }
}

sub submit_one {
    my($run_in, $file_in) = @_;
    $run = sprintf("%05d", $run_in);
    $file = sprintf("%07d", $file_in);
    $jsub_file = "$jsub_file_path/${project}_${run}_${file}.jsub";
    open(JSUB, ">$jsub_file");
    $jsub_file_template = "$project.jsub";
    if (-e $jsub_file_template) {
	open(JSUB_TEMPLATE, "$jsub_file_template");
	while ($line = <JSUB_TEMPLATE>) {
	    $line =~ s/{project}/$project/g;
	    $line =~ s/{run_number}/$run/g;
	    $line =~ s/{file_number}/$file/g;
	    print JSUB $line;
	}
	close(JSUB);
	close(JSUB_TEMPLATE);
	$submit_command = "jsub $jsub_file";
	system "$submit_command\n";
    } else {
	die "error: jsub file template $jsub_file_template does not exist";
    }
}

sub unsubmit {
    $run = $ARGV[2];
    $file = $ARGV[3];
    print "run = $run, file = $file\n";
    $sql = "SELECT submitted FROM $project WHERE run = $run AND file = $file";
    make_query($dbh_db, \$sth);
    $submitted = 0;
    $nrow = 0;
    while (@column = $sth->fetchrow_array) {
	$nrow++;
	$submitted = $column[0];
    }
    if ($nrow > 1) {die "more than one entry for run/file";}
    if ($submitted != 1) {die "job never submitted or run/file does not exist";}
    $sql = "UPDATE $project SET submitted = 0 WHERE run = $run AND file = $file";
    make_query($dbh_db, \$sth);
}

sub jput {
    $output_dir = $ARGV[2];
    $silo_dir = $ARGV[3];
    if ($silo_dir !~ /\/$/) {
	$silo_dir .= '/';     # add trailing "/"
    }
    $pattern_run_only = $ARGV[4];
    if ($pattern_run_only ne '') {
	print "file pattern will include only run number\n";
    }
    $sql = "SELECT run, file FROM $project WHERE submitted = 1 AND output = 1 AND jput_submitted = 0";
    make_query($dbh_db, \$sth);
    $nfile = 0;
    while (@column = $sth->fetchrow_array) {
	if ($nfile%100 == 0) {
	    if ($nfile != 0) {
		jput_it();
	    }
	    $command = "cd $output_dir ; jput";
	}
	$run = sprintf("%05d", $column[0]);
	$file = sprintf("%02d", $column[1]);
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
    jput_it();
}

sub jput_it {
    $command .= " $silo_dir";
    system $command;
}

sub jcache {
    $silo_dir = $ARGV[2];
    $pattern_run_only = $ARGV[3];
    if ($pattern_run_only ne '') {
	print "file pattern will include only run number\n";
    }
    $sql = "SELECT run, file FROM $project WHERE submitted = 1 AND silo = 1 AND jcache_submitted = 0";
    make_query($dbh_db, \$sth);
    $nfile = 0;
    while (@column = $sth->fetchrow_array) {
	if ($nfile%100 == 0) {
	    if ($nfile != 0) {
		jcache_it();
	    }
	    $command = "jcache -g primex";
	}
	$run = sprintf("%05d", $column[0]);
	$file = sprintf("%02d", $column[1]);
	if ($pattern_run_only) {
	    $file_pattern = $run;
	} else {
	    $file_pattern = $run . '_' . $file;
	}
	$command .= " $silo_dir/\*$file_pattern\*";
	$sql = "UPDATE $project SET jcache_submitted = 1 WHERE run = $run AND file = $file";
	make_query($dbh_db, \$sth2);
	$nfile++;
    }
    jcache_it();
}

sub jcache_it {
    system $command;
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
    arg1: number of runs in the project, use only if project is not driven by
          input data files, "update" action will never be necessary for this
          project

update
    arg1: file number to use; if omitted all file numbers will be used

update_output
    arg1: output link directory
    arg2: if present and non-zero, use only run number in file pattern search

update_silo
    arg1: mss directory
    arg2: if present and non-zero, use only run number in file pattern search

update_cache
    arg1: cache directory
    arg2: if present and non-zero, use only run number in file pattern search

submit
    arg1: limit on number of submissions

unsubmit
    arg1: run number
    arg2: file number

jput
    arg1: output link directory
    arg2: mss directory
    arg3: if present and non-zero, use only run number in file pattern for jput

jcache
    arg1: mss directory
    arg2: if present and non-zero, use only run number in file pattern for jcache
EOM
}
