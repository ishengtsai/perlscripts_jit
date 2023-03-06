#!/usr/bin/perl -w
use strict;
#use diagnostics;



my $largest = 0;
my $contig = '';


if (@ARGV != 3) {
    print "$0 mitoZ_Mol.cds sequence.txt marker \n" ; 
    exit ;
}


my $filenameA = $ARGV[0] ;
my $filenameB = $ARGV[1] ;
my $marker = $ARGV[2] ; 


my %fasta = () ;
my %fasta_subject = () ;

my $fasta_len = 0 ; 

open OUT, ">", "$marker.qrymod.cds.fa" or die "daosdpasodpa\n" ; 

open (IN, "$filenameA") or die "oops!\n" ;
my $read_name = '' ;
my $read_seq = '' ;
while (<IN>) {
	    if (/^>\S+\;(\S+)\;len/) {
		$read_name = $1 ;
		$read_seq = "" ;
		
		while (<IN>) {
		    
		    if (/^>\S+\;(\S+)\;len/) {
			$fasta_len = length($read_seq) ; 
			$fasta{$read_name} = $read_seq ; 
			$read_name = $1 ;
			$read_seq = "" ;
		    }
		    else {
			chomp ;
			$read_seq .= $_ ;
		    }
		}
	    }
	}
close(IN) ;
$fasta{$read_name} = $read_seq ;

open (IN, "$filenameB") or die "oops!\n" ;
$read_name = '' ;
$read_seq = '' ;
while (<IN>) {
            if (/\[gene=(.+)\] \[protein=/) {
                $read_name = $1 ;
                $read_seq = "" ;

                while (<IN>) {

                    if (/\[gene=(.+)\] \[protein=/) {
                        $fasta_len = length($read_seq) ;
                        $fasta_subject{$read_name} = $read_seq ;
                        $read_name = $1 ;
                        $read_seq = "" ;
                    }
                    else {
                        chomp ;
                        $read_seq .= $_ ;
                    }
                }
            }
        }
close(IN) ;
$fasta_subject{$read_name} = $read_seq ;

open TMP, ">", "$marker.tmp.fa" or die "dlas;dllas;d;lsadl;a\n" ; 

if ( $fasta{$marker} && $fasta_subject{$marker} ) {
    print TMP ">query\n$fasta{$marker}\n" ;
    print TMP ">subject\n$fasta_subject{$marker}\n" ; 
}
else {
    print "$marker not present in one of the file!\n" ; die ; 
}
close(TMP) ;

system("mafft $marker.tmp.fa > $marker.tmp.fa.aln") ; 

my %aln = (); 

open (IN, "$marker.tmp.fa.aln") or die "oops!\n" ;
$read_name = '' ;
$read_seq = '' ;
while (<IN>) {
            if (/^>(\S+)/) {
                $read_name = $1 ;
                $read_seq = "" ;

                while (<IN>) {

                    if (/^>(\S+)/) {
                        $fasta_len = length($read_seq) ;
			$aln{$read_name} = $read_seq ;
                        $read_name = $1 ;
			$read_seq = "" ;
                    }
                    else {
                        chomp ;
                        $read_seq .= $_ ;
                    }
                }
            }
	}
close(IN) ;
$aln{$read_name} = $read_seq ;






$fasta_len = length($aln{"query"}) ; 

my $insertion  = 0 ;
my $deletion = 0 ; 

my $query = $aln{"query"} ;
my $subject = $aln{"subject"} ; 




print "Gene: $marker\n" ; 


#The built-in variables @- and @+ hold the start and end positions, respectively, of the last successful match. 
#$-[0] and $+[0] correspond to entire pattern, while $-[N] and $+[N] correspond to the $N ($1, $2, etc.) submatches.@-

while ( $subject =~ /[atcg]-[atcg]/g ) {
    my $pos = pos($subject) ;
    print "$pos which query has extra base\n" ;
    
    $insertion++ ;


    my $sub_start = substr $subject , 0, ($pos-2) ; 
    my $sub_end =substr $subject , ($pos-1) ; 
    my $qry_start = substr $query , 0, ($pos-2) ;
    my $qry_end = substr $query , ($pos-1) ;

    my $sub_left = substr $subject , ($pos-7), 5 ;
    my $sub_right =substr $subject , $pos-1, 5 ;
    my $sub_base = substr $subject, $pos-2, 1 ;
    
    my $qry_left = substr $query , ($pos-7), 5 ;
    my $qry_right = substr $query , $pos-1, 5 ;
    my $qry_base = substr $query, $pos-2, 1 ; 
    
 

    print "INS\t$marker\tsubject\t$sub_left\t$sub_base\t$sub_right\tquery\t$qry_left\t$qry_base\t$qry_right\n" ;
    
    #print "$sub_start\n" ;
    #print "$sub_end\n" ; 
    
    $subject = $sub_start.$sub_end ; 
    $query = $qry_start.$qry_end ;


    
    #die ; 
}

while ( $subject =~ /[atcg]--[atcg]/g ) {
    my $pos = pos($subject) ;
    print "$pos which query has extra 2 bases\n" ;

    $insertion++ ;


    my $sub_start = substr $subject , 0, ($pos-3) ;
    my $sub_end =substr $subject , ($pos-1) ;
    my $qry_start = substr $query , 0, ($pos-3) ;
    my $qry_end = substr $query , ($pos-1) ;

    #print "$sub_start\n" ;
    #print "$sub_end\n" ;

    $subject = $sub_start.$sub_end ;
    $query = $qry_start.$qry_end ;
    #die ;
}


while ( $subject =~ /[atcg]----[atcg]/g ) {
    my $pos = pos($subject) ;
    print "$pos which query has extra 4 bases\n" ;

    $insertion++ ;


    my $sub_start = substr $subject , 0, ($pos-5) ;
    my $sub_end =substr $subject , ($pos-1) ;
    my $qry_start = substr $query , 0, ($pos-5) ;
    my $qry_end = substr $query , ($pos-1) ;

    #print "$sub_start\n" ;
    #print "$sub_end\n" ;

    $subject = $sub_start.$sub_end ;
    $query = $qry_start.$qry_end ;
    #die ;
}



while ( $subject =~ /[atcg]-----[atcg]/g ) {
    my $pos = pos($subject) ;
    print "$pos which query has extra 5 bases\n" ;

    $insertion++ ;


    my $sub_start = substr $subject , 0, ($pos-6) ;
    my $sub_end =substr $subject , ($pos-1) ;
    my $qry_start = substr $query , 0, ($pos-6) ;
    my $qry_end = substr $query , ($pos-1) ;

    #print "$sub_start\n" ;
    #print "$sub_end\n" ;

    $subject = $sub_start.$sub_end ;
    $query = $qry_start.$qry_end ;
    #die ;
}


while ( $query =~ /[atcg]-[atcg]/g ) {
    my $pos = pos($query) ;
    #print "$pos\n" ;

    $deletion++ ;

    my $sub_base = substr $subject , $pos-1, 1 ; 

    my $qry_start = substr $query , 0, ($pos-2) ;
    my $qry_end	= substr $query , ($pos-1) ;

    #print "$qry_start\n" ;
    #print "$qry_end\n" ; 
    #print "$pos\t$sub_base\n" ;


    my $sub_left = substr $subject , ($pos-7), 5 ;
    my $sub_right =substr $subject , $pos-1, 5 ;
     $sub_base = substr $subject, $pos-2, 1 ;

    my $qry_left = substr $query , ($pos-7), 5 ;
    my $qry_right = substr $query , $pos-1, 5 ;
    my $qry_base = substr $query, $pos-2, 1 ;

    print "DEL\t$marker\tsubject\t$sub_left\t$sub_base\t$sub_right\tquery\t$qry_left\t$qry_base\t$qry_right\n" ;


    
    $query = $qry_start. $sub_base.  $qry_end ;
    #die ; 
}

while ( $query =~ /[atcg]--[atcg]/g ) {
    my $pos = pos($query) ;
    #print "$pos\n" ;

    $deletion++ ;

    my $sub_base = substr $subject , $pos-1, 2 ;

    my $qry_start = substr $query , 0, ($pos-3) ;
    my $qry_end = substr $query , ($pos-1) ;

    #print "$qry_start\n" ;
    #print "$qry_end\n" ;
    #print "$pos\t$sub_base\n" ;
    $query = $qry_start. $sub_base.  $qry_end ;
    #die ;
}


while ( $query =~ /[atcg]----[atcg]/g ) {
    my $pos = pos($query) ;
    #print "$pos\n" ;

    $deletion++ ;

    my $sub_base = substr $subject , $pos-1, 4 ;

    my $qry_start = substr $query , 0, ($pos-5) ;
    my $qry_end = substr $query , ($pos-1) ;

    #print "$qry_start\n" ;
    #print "$qry_end\n" ;
    print "$pos\t$sub_base\n" ;
    $query = $qry_start. $sub_base.  $qry_end ;
    #die ;
}





#print "$subject\n" ;

print "num insertions: $insertion\n" ;
print "num deletions: $deletion\n\n\n" ;


# trim alignment gaps in the start
if ( $subject =~ /^-+/ ) {
    $subject =~ s/^-+// ; 
}
if ( $query =~ /^-+/ ) {
    $query =~ s/^-+// ;
}
# trim alignment gaps in the end
if ( $subject =~ /-+$/ ) {
    $subject =~ s/-+$// ;
}
if ( $query =~ /-+$/ ) {
    $query =~ s/-+$// ;
}





print OUT ">$marker.subject\n$subject\n" ; 
print OUT ">$marker.mod\n$query\n" ;  


open OUT2, ">", "$marker.mod.seq" or die "dpsad[paspd[aspda\n" ;
$query =~ s/-//gi ; 
print OUT2 "$query\n" ; 


#system("rm $marker.tmp.fa") ; 
system("transeq -table 5 -frame 1,2,3 -nomethionine -outseq $marker.qrymod.pep.fa $marker.qrymod.cds.fa") ; 


