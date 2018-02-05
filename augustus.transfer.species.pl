#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
    print "$0 directory_name path.of.config speciesname\n" ;
    exit ;
}

my $directory = shift @ARGV;
my $path = shift @ARGV ; 
my $newspecies = shift @ARGV ; 

opendir (DIR, $directory) or die $!;

my $species_old = '' ; 
if ( $directory =~ /\/species\/(\S+)\/$/ ) {
    $species_old = $1 ; 
}
else {
    $species_old = $directory ; 
}


print "\n\nold species = $species_old\n" ; 
print "new species = $newspecies\n" ; 
print "making directory $path/$newspecies/ \n\n\n" ; 

mkdir "$path/$newspecies/" ; 

while (my $file = readdir(DIR)) {



    if ( $file =~ /$species_old\_(\S+$)/ ) {
	my $filename = $1 ; 

	my $command = "cp $directory/$file $path/$newspecies/$newspecies\_$filename.tmp" ; 
	print "copy: $command\n" ; 
	
	system("$command") ; 

	$command = "sed 's/$species_old/$newspecies/g' $path/$newspecies/$newspecies\_$filename.tmp > $path/$newspecies/$newspecies\_$filename" ; 
	print "$command\n" ; 
	system("$command") ; 

	system("rm $path/$newspecies/$newspecies\_$filename.tmp") ; 

    }
    else {
	next ; 
    }

    print "$file\n";



}
