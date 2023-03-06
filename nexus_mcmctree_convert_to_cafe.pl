#!/usr/bin/perl -w
use strict;







if (@ARGV != 1) {
    print "$0 Mycena.divergenceFINAL.nexus.tree\n" ; 
	exit ;
}

my $file = shift ; 
my $NODEname = shift ; 



open (IN, $file) or die "dadakjdadjklad\n" ; 

open OUT, ">", "$file.Myr.tree" or die "daoidapdoapdo\n" ; 
open OUT2, ">", "$file.cafeModel.tree" or die "daoidapdoapdo\n" ;



my $tree = <IN> ;
chomp($tree) ; 
my $modifytree = $tree; 
my $modifytree2 = $tree;


print "$tree\n" ; 

my @matches = $tree =~ /\:(\d\.\d+)/g;



foreach my $match (@matches) {
    #print "$match\n" ; 
    my $newmatch = sprintf("%.3f", $match * 100);
    #$newmatch = int($newmatch + 0.5);
    #print "$match\t$newmatch\n" ; 

    $modifytree =~ s/\:$match/\:$newmatch/ ; 

}

$modifytree =~ s/_[a-zA-Z0-9_]+//g ; 

$modifytree2 =~ s/[a-zA-Z0-9_]+\:\d\.\d+/1/g;
$modifytree2 =~ s/\:\d\.\d+/1/g;




print "\n\n\n$file.Myr.tree produced!\n" ; 
print "modified tree (in Myr): $modifytree\n" ;
print OUT "$modifytree\n" ; 

print "\n\ncafe model produced! in $file.cafeModel.tree\n" ; 
print "modified tree 2: $modifytree2\n" ; 
print OUT2 "$modifytree2\n" ;
