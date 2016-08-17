#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 2) {
    print "$0 contig_len_file N80\n" ; 
    exit ;
}

my $file = shift ; 




open (IN, "$file") or die "can't openfile: $!\n" ; 

my @scaffold_len = () ; 

while (<IN>) {


    chomp; 
    my @r = split /\s+/, $_ ; 
    push(@scaffold_len, $r[1] ) ; 

}
close(IN) ; 


my %cel_len = () ; 

for (my $i = 0 ; $i < 15072434 ; $i++ ) {
    $cel_len{'1'}{$i}++ ; 
}
for (my$i = 0 ; $i < 15279421 ; $i++ ) {
    $cel_len{'2'}{$i}++ ;
}
for (my$i = 0 ; $i < 13783801 ; $i++ ) {
    $cel_len{'3'}{$i}++ ;
}
for (my$i = 0 ; $i < 17493829 ; $i++ ) {
    $cel_len{'4'}{$i}++ ;
}
for (my$i = 0 ; $i < 20924180 ; $i++ ) {
    $cel_len{'5'}{$i}++ ;
}
for (my$i = 0 ; $i < 17718942 ; $i++ ) {
    $cel_len{'6'}{$i}++ ;
}


foreach my $piece_len ( @scaffold_len ) {

    


}


