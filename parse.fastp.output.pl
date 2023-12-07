#!/usr/bin/perl

use strict;
use warnings ;
use JSON::Parse 'read_json';


print "$0\n reading json files...\n" ;

my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
        print "$0 genome.size.inMb \n\n" ;
        exit ;
}


my $genomesize = $ARGV[0];
$genomesize = $genomesize * 1000000 ; 


my @dirs = grep { -d } glob '*';
push (@dirs, ".") ; 

my @features = ( 'total_reads', 'total_bases', 'q20_bases', 'q30_bases',  'q20_rate', 'q30_rate', 'read1_mean_length', 'read2_mean_length',  'gc_content',   ) ; 

print "directory\tSample\t" ; 
foreach (@features) {
    print "$_\t" ; 
}
foreach (@features) {
    print "$_\t" ;
}
print "Coverage\n" ; 

foreach my $directory (@dirs) {

    opendir (DIR, $directory) or die $!;

    while (my $file = readdir(DIR)) {

	next unless $file =~ /.json/ ;
	#    print "$file!!!\n" ;

	my $sample = '' ;
	if ($file =~ /(\S+).json$/ )  {
	    $sample = $1 ; 
	}
	
	print "$directory\t$sample\t";
	
	my $p = read_json ( "$directory/$file" );

	
	foreach my $stats ( @features ) {
	    print  $p->{summary}->{before_filtering}->{$stats} . "\t" ; 
	}
	
	foreach my $stats ( @features ) {
            print  $p->{summary}->{after_filtering}->{$stats} . "\t" ;
        }	


	my $total_bases = $p->{summary}->{before_filtering}->{'total_bases'} ;
	my $coverage = sprintf("%.3f", $total_bases / $genomesize) ; 
	
	print "$coverage\n" ;
	
    }

}


#my $filename = 'F3_RT.json' ; 

#my $p = read_json ($filename );


#        "summary": {
#                "before_filtering": {
#                        "total_reads":842039912,
#                        "total_bases":127148026712,
#                        "q20_bases":123409652224,
#                        "q30_bases":117156557528,
#                        "q20_rate":0.970598,
#                        "q30_rate":0.921419,
#                        "read1_mean_length":151,
#                        "read2_mean_length":151,
#                        "gc_content":0.378985


#print "$p{'Summary'}" ; 

#my $yes = $p->{summary}->{before_filtering}->{total_reads} ; 

#print "$yes\n" ; 

#foreach my $yeeee ( keys %yes ) {
#    print "$yeeee\n" ; 
#}


#print keys % {$p->{summary}->{before_filtering}->{total_reads} }; 
