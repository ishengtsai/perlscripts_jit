#!/usr/bin/perl -w
use strict;



if (@ARGV != 1) {
    print "$0 gff \n" ; 
	exit ;
}

my $file = shift @ARGV;



open (IN, "$file") or die "oops!\n" ;
open OUT, ">", "$file.augustus.train.gff" or die "ooops\n" ; 
open OUT2, ">", "$file.augustus.hints.gff" or die "ooops\n" ;


## read in the cufflink annotations

my $id = '' ; 

while (<IN>) {
	
    chomp ; 
    my @r = split /\s+/, ; 

    if ( $r[2] eq 'exon' && $r[8] =~ /Parent=(\S+):mRNA\l/ ) {

	my $id = $1 ; 
	print OUT "$r[0]\tembl\tCDS\t$r[3]\t$r[4]\t1000\t$r[6]\t.\ttranscript_id \"$id\"\n" ; 
	print OUT2 "$r[0]\tmanual\tCDS\t$r[3]\t$r[4]\t.\t$r[6]\t.\tpri=5\;src=M\n" ; 


    }
}
close(IN); 

print "all done! $file.augustus.train.gff and $file.augustus.hints.gff generated !\n" ; 
