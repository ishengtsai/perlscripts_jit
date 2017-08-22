#!/usr/bin/perl -w
use strict;

use YAML::XS 'LoadFile';
use feature 'say';





my $largest = 0;
my $contig = '';




if (@ARGV != 1) {
    print "$0 summary.yaml\n" ; 
    exit ;
}

my $filenameA = $ARGV[0];


my $data = LoadFile($filenameA);

print $data ;

print $data->{'All reads'} ;


#for (keys %{$data->{'All reads'}}) {
#    say "$_: $data->{'All reads'}->{$_}";
#}

my $totalgigabases = $data->{'All reads'}->{'total.gigabases'} ;
my $N50len = $data->{'All reads'}->{'N50.length'} ;
my $maxlen = $data->{'All reads'}->{'max.length'} ; 



print "Total\tN50len\t\n" ;

print "$totalgigabases\t$N50len\n" ; 


