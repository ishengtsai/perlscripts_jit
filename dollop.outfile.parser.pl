#!/usr/bin/perl
use strict;
use warnings;

if (@ARGV != 2) {
    print "$0 dollopoutfile branch\n" ;
    exit ; 
}

my $dollopoutfile = shift ; 
my $branchname = shift ; 


open (IN, "$dollopoutfile") or die "ooops\n" ; 

# reads output from dollop and reports numbers of 0->1 and 1->0 changes per branch
#am I in the big table of state changes!
my $in_table = 0;
my $branch = "";
my $encoding = "";
my %branches;
use Tie::IxHash;
tie %branches, "Tie::IxHash";
while (<IN>) { 
	chomp;
	if ($in_table) { 
		if ($_ ne "") { 
			
			if(! m/yes/ && ! m/no/) {
				# print "^".$_."\n"; 
				my @bits = split(/\s+/);
				while (scalar @bits > 0) { 
					my $thisbit = shift @bits;
					if ($thisbit ne "") { 
						$encoding .= $thisbit;
					}

				}
			} 
			else { 
				if ($branch ne "") { 
					$branches{$branch} = $encoding;
					$encoding = "";
				}
				print "@".$_."\n"; 
				my @bits = split(/\s+/);
				print "READ ".(scalar @bits)." bits\n";
				foreach my $l (@bits) { print "'".$l."'\n"; }
				my $startbr = shift @bits;
				if ($startbr eq "") { $startbr = shift @bits; } 
				my $endbr = shift @bits;
				$branch = $startbr."|".$endbr;
				shift @bits;
				while (scalar @bits > 0) { 
					$encoding .= shift @bits;
				}
			} 
		}
	}
	if (m/means same as in the node below it on tree/) { $in_table = 1; } 
}

$branches{$branch} = $encoding;
print "read info for a total of ".(scalar keys %branches)." branches\n";
print "branch\ttotal_chars\tno_change\tgain\tloss\ttotal\n";

# looks easy to parse!!
foreach my $k (keys %branches) { 
	print $k."\t".(length $branches{$k})."\t";
	my $string = $branches{$k};
	my $dotscount = $string =~ tr/.//;
	my $onecount = $string =~ tr/1//;
	my $zerocount = $string =~ tr/0//;
	print $dotscount."\t".$onecount."\t".$zerocount."\t".($dotscount+$onecount+$zerocount)."\n";


}
print "\n\ncolumns 2 and 6 should be equal, otherwise you don't have binary characeters!\n";


print "\n\nNow parsing number of specific family...\n" ; 


foreach my $k (keys %branches) {

    if ( $k =~ /\d+\|$branchname$/ ) {
	print "found: $k\n" ; 
	
	open GAIN, ">", "branch.$branchname.gain" or die "oooops!\n" ; 
	open LOSS, ">", "branch.$branchname.loss" or die "oooooooops\n" ; 

	my $string = $branches{$k};

	my @family = split(//, $string);

	for (my $i = 0 ; $i < @family ; $i++) {
	    my $familyID = sprintf("%07d", $i) ;
	    $familyID = "OG" . $familyID ; 
	    
	    if ( $family[$i] eq '1' ) {
		print GAIN "$familyID\n" ; 
	    }

            if ( $family[$i] eq'0' ) {
		print LOSS "$familyID\n" ;
            }


	}


    }

}
