use strict;

my $contig=shift;

my $num= 5;
my $t="out2";
my $lib="lib2";


print "# Please notice that the lib format did change!\n";


#print "PERL5LIB=\$PERL5LIB:/software/pathogen/external/apps/usr/local/lib/AMOS/; export PERL5LIB\n\n";
print "perl /home/ishengtsai/bin/SSPACE-BASIC-2.0_linux-x86_64/SSPACE_Basic_v2.0.pl -l $lib -n 31 -s $contig -x 0 -k $num -T 8 -b $t.$num;\n";
system("ln -f -s $t.$num.final.scaffolds.fasta final.scaffolds.fasta");

  
