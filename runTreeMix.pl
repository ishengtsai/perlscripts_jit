#!/usr/bin/perl -w
use strict;
#use diagnostics;



my $largest = 0;
my $contig = '';


if (@ARGV < 3) {
    print "$0 plink.treemix.frq.gz edges iteration root\n" ; 
    exit ;
}

my $random_no =  int(rand(10000));

print "creating and moving to treemix.run.$random_no\n" ; 

mkdir "treemix.run.$random_no" ; 
chdir "treemix.run.$random_no" ;



my $filenameA = $ARGV[0] ;
my $edges = $ARGV[1];
my $iterations = $ARGV[2] ;

my $root ;

if ( $ARGV[3] ) {
    $root = $ARGV[3] ;
    print "root is specified as $root \n" ; 
}

system("cp -a ../$filenameA .") ;


for (my $j = 1 ; $j < $iterations+1 ; $j++ ) {

    $random_no =  int(rand(10000));
    my $k = 1 ;
    $k = 10 if $j == 2 ;
    $k = 50 if $j == 3 ;
    $k = 100 if $j == 4 ;
    $k = 500 if $j == 5 ;
    $k = 1000 if $j == 6 ;
    
    for (my $i = 1 ; $i < $edges+1 ; $i++ ) {
	
	#treemix -i $FILE.treemix.frq.gz -m $i -o $FILE.$i -root TW1 -bootstrap -k 500 -noss > treemix_${i}_log
	my $command ;


	
	if ( $root ) {
	    $command  = "nohup /home/ijt/bin/treemix-1.13/src/treemix -m $i -i $filenameA -o $filenameA.$j.$i.k$k -seed $random_no -k $k  -root $root -noss   1> treemix_$j\_$i\_log & " ;
	}
	else {
	    $command  = "nohup /home/ijt/bin/treemix-1.13/src/treemix -m $i -i $filenameA -o $filenameA.$j.$i.k$k -seed $random_no -k $k -noss 1> treemix_$j\_$i\_log & " ;
	}
	
	print "$command\n" ; 
	system("$command") ; 
	
    }
}

