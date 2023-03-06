#!/usr/bin/perl -w
use strict;




my $largest = 0;
my $contig = '';


if (@ARGV != 1) {
	print "$0 fasta\n\n" ;
	exit ;
}

my $filenameA = $ARGV[0];

my %assembly = () ; 

open (IN, "$filenameA") or die "oops!\n" ;

	my $read_name = '' ;
	my $read_seq = '' ;

	while (<IN>) {
	    if (/^>(\S+)/) {
		$read_name = $1 ;
		$read_seq = "" ;
		$read_name =~ s/\#/\./gi ; 
		
		while (<IN>) {

			if (/^>(\S+)/) {
			    
			    print "$read_name\n" ; 

			    
			    $assembly{$read_name} = $read_seq ; 
			    


			    $read_name = $1 ;
			    $read_seq = "" ;
			    $read_name =~ s/\#/\./gi ;


			}
			else {
			    chomp ;
			    $read_seq .= $_ ;
			}


		}

	    }
	}

close(IN) ;

$assembly{$read_name} = $read_seq ;
print "$read_name\n\n\n" ;


$assembly{'AOLT.scaffold0001.C'} = $assembly{'tig00002785'} ;


#1       708171  9358    717333  708171  707976  99.97   7110532 717333  9.96    98.70   AOLT.scaffold0002       tig00000164
$assembly{'AOLT.scaffold0002.C'} = substr($assembly{'tig00000164'}, 0, 9357) . $assembly{"AOLT.scaffold0002"} ; 

#1       2474826 16817   2491144 2474826 2474328 99.97   5374114 2491144 46.05   99.32   AOLT.scaffold0003       tig00002786
$assembly{'AOLT.scaffold0003.C'} = substr($assembly{'tig00002786'}, 0, 16816) .  $assembly{"AOLT.scaffold0003"} ;


#1       3939492 24040   3962575 3939492 3938536 99.97   3939523 3962575 100.00  99.39   AOLT.scaffold0004       tig00000014
$assembly{'AOLT.scaffold0004.C'} =  $assembly{"tig00000014"} ;


#1       3893005 29313   3921378 3893005 3892066 99.97   3896608 3921380 99.91   99.25   AOLT.scaffold0005       tig00000016
$assembly{'AOLT.scaffold0005.C'} =  substr($assembly{'tig00000016'}, 0, 29312) .   $assembly{"AOLT.scaffold0005"} ;

#1       3561020 3559935 1       3561020 3559935 99.96   3561026 3591186 100.00  99.13   AOLT.scaffold0006       tig00000031
$assembly{'AOLT.scaffold0006.C'} =  $assembly{"tig00000031"} ;

#1       2060282 26312   2085999 2060282 2059688 99.96   3060273 2085999 67.32   98.74   AOLT.scaffold0007       tig00000097
$assembly{'AOLT.scaffold0007.C'} = substr($assembly{'tig00000097'}, 0, 26311) . $assembly{"AOLT.scaffold0007"} ;

#1       2069162 15824   2084486 2069162 2068663 99.97   2910264 2084486 71.10   99.24   AOLT.scaffold0008       tig00000087
$assembly{'AOLT.scaffold0008.C'} = substr($assembly{'tig00000087'}, 0, 15823) . $assembly{"AOLT.scaffold0008"} ;


#$assembly{'AOLT.scaffold0009.C'} = substr($assembly{'tig00000128'}, 0, 947) . $assembly{"AOLT.scaffold0009"} ; 


					  

delete $assembly{"AOLT.scaffold0001"} ;
delete $assembly{"AOLT.scaffold0002"} ;
delete $assembly{"AOLT.scaffold0003"} ;
delete $assembly{"AOLT.scaffold0004"} ;
delete $assembly{"AOLT.scaffold0005"} ;
delete $assembly{"AOLT.scaffold0006"} ;
delete $assembly{"AOLT.scaffold0007"} ;
delete $assembly{"AOLT.scaffold0008"} ;
#delete $assembly{"AOLT.scaffold0009"} ;


   

open OUT, ">", "$filenameA.mergedManually.fa" or die "doasdpaopds\n" ; 

for my $name (sort keys %assembly ) {
    if ( $name =~ /AOLT/ ) {
	print OUT ">$name\n" ; 
	print OUT "$assembly{$name}\n" ; 
    }
}

print "$filenameA.mergedManually.fa printed!\n" ; 


sub revcomp {
    my $dna = shift;
    my $revcomp = reverse($dna);

    $revcomp =~ tr/ACGTacgt/TGCAtgca/;

    return $revcomp;
}
