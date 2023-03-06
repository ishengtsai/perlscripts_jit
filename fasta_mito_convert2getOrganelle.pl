#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


#GetOrganelle looks like this
#>cox1 gene - NC_014848
#>cox2 gene - NC_014848
#>atp8 gene - NC_014848
#>atp6 gene - NC_014848
#>cox3 gene - NC_014848
#>nad3 gene - NC_014848
#>nad5 gene - NC_014848
#>nad4 gene - NC_014848
#>nad4L gene - NC_014848
#>nad1 gene - NC_014848
#>nad2 gene - NC_014848
#>nad6 gene - NC_014848
#>cytb gene - NC_014848
#>rrnL gene - NC_014848
#>rrnS gene - NC_014848

    


if (@ARGV != 2) {
    print "$0 fasta ID \n" ;
	exit ;
}

my $filenameA = $ARGV[0];
my $ID = $ARGV[1] ; 


open (IN, "$filenameA") or die "oops!\n" ;

my $count = 1 ; 

	while (<IN>) {

	    if (/cytochrome b/) {
		print ">cytb gene - $ID\n" ; 
	    }
	    elsif (/NADH dehydrogenase subunit 5/) {
		print ">nad5 gene - $ID\n" ; 
		
	    }
            elsif (/NADH dehydrogenase subunit 3/) {
		print ">nad3 gene - $ID\n" ; 

            }
            elsif (/cytochrome c oxidase subunit III/) {
		print ">cox3 gene - $ID\n" ; 

            }
            elsif (/cytochrome c oxidase subunit II /) {
		print ">cox2 gene - $ID\n" ; 

            }
	    elsif (/ATP synthase F0 subunit 6/ ) {
		print ">atp6 gene - $ID\n" ; 
	    }
            elsif (/NADH dehydrogenase subunit 1/) {
		print ">nad1 gene - $ID\n" ; 

            }
	    elsif (/NADH dehydrogenase subunit 2/) {
		print ">nad2 gene - $ID\n" ; 
	    }
	    elsif (/NADH dehydrogenase subunit 4L/) {
		print ">nad4l gene - $ID\n" ;
            }
	    elsif (/NADH dehydrogenase subunit 4/) {
		print ">nad4 gene - $ID\n" ;
            }
	    elsif (/NADH dehydrogenase subunit 6/) {
		print ">nad6 gene - $ID\n" ;
            }
	    elsif (/cytochrome c oxidase subunit I/) {
		print ">cox1 gene - $ID\n" ;
	    }
	    elsif (/^>/) {

		print "not in any of the regex!!!\n" ;
		print "$_\n\n" ; 
		die ; 


	    }
	    else {
		chomp; 
		if ( $_ eq '' ) {
		
		}
		else {
		    print "$_\n" ;
		}
	    }

	}

close(IN) ;




