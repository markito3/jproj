#!/usr/bin/env perl

use XML::Parser;

$project = $ARGV[0];

my $p = new XML::Parser(Style=>'Stream');

#$p->parsefile($ARGV[0]);
$p->parse(STDIN);

exit;

sub StartTag {
    my ($expat, $eltype) = @_;
    #print "eltype = $eltype\n";
    if ($eltype eq 'attempt') {
	$in_attempt = 1;
    } elsif ($eltype eq 'job_id') {
	$get_job_id = 1;
    } elsif ($eltype eq 'auger_id') {
	$get_auger_id = 1;
    }
}

sub EndTag {
    my ($expat, $eltype) = @_;
    if ($eltype eq 'attempt') {
	$in_attempt = 0;
    } elsif ($eltype eq 'job_id') {
	$get_job_id = 0;
    } elsif ($eltype eq 'auger_id') {
	$get_auger_id = 0;
	print "insert into ${project}Job set jobId = $job_id, augerId = $auger_id;\n";
    }
}

sub Text {
    my $text = $_;
    if ($in_attempt) {
	if ($get_job_id) {
	    chomp $text;
	    $job_id = $text;
	    #print "job_id = $job_id\n";
	} elsif ($get_auger_id) {
	    chomp $text;
	    $auger_id = $text;
	    #print "auger_id = $auger_id\n";
	}
    }
    return;
}
