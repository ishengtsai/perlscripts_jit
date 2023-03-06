#!/usr/bin/perl -w
use strict;

use Bio::SeqIO;

if (@ARGV != 2) {    die "USAGE: gb2embl.pl infile outfile   \n"; }

my $seqio = Bio::SeqIO->new('-format' => 'genbank', '-file' => "$ARGV[0]");
my $seqout = new Bio::SeqIO('-format' => 'embl', '-file' => ">$ARGV[1]");
while( my $seq = $seqio->next_seq) {
    $seqout->write_seq($seq)
}
