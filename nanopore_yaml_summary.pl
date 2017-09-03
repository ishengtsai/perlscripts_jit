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

#print $data ;

#print $data->{'All reads'} ;


#for (keys %{$data->{'All reads'}}) {
#    say "$_: $data->{'All reads'}->{$_}";
#}

my $totalgigabases = $data->{'All reads'}->{'total.gigabases'} ;
my $N50len = $data->{'All reads'}->{'N50.length'} ;
my $maxlen = $data->{'All reads'}->{'max.length'} ; 



print "Total\tN50len\tMaxlen\tMedianQ\t>20kbInGB\t>100kbInGB\tTotalQ10\t20kbInGBQ10\t100kbInGBQ10\n" ;

print "$totalgigabases\t$N50len\t$maxlen\t" .
    $data->{'All reads'}->{'median.q'} . "\t" . 
    $data->{'All reads'}->{'gigabases'}->{'>20kb'} . "\t" .
    $data->{'All reads'}->{'gigabases'}->{'>100kb'} . "\t" .
    $data->{'Reads with Q>10'}->{'total.gigabases'} . "\t" .
    $data->{'Reads with Q>10'}->{'gigabases'}->{'>20kb'} . "\t" .
    $data->{'Reads with Q>10'}->{'gigabases'}->{'>100kb'} . "\t" . 
    "\n" ; 


