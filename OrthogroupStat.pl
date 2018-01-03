#!/usr/bin/perl
use strict;

=example
OG0001070: Bmala|WBGene00222351 Celeg|WBGene00015629 Aceyl|ANCCEY_12834 Asuum|GS_22023 Asuum|GS_05072 Aceyl|ANCCEY_04694 Bxylo|BXY_1710600 Asuum|GS_02781 Aceyl|ANCCEY_04695 Celeg|WBGene00004960 Asuum|GS_11868
=cut

my $orthofinder_out_dir= $ARGV[0];
my $result_file= $ARGV[1];

my $group_file= "$orthofinder_out_dir/OrthologousGroups.txt";
my %table= ();
my %all_species= ();
open A, "< $group_file" or die;
while (my $line=<A>){
    $line=~/^(\w+)\:/;
    my $group= $1;
    my @species= $line=~/\s+([^\s\|]+)\|/g;
    map {$all_species{$_}= 1;} @species;
    $table{$group}= {};
    map {$table{$group}->{$_}+= 1;} @species;
}
close A;

my @unique_species= sort{$a cmp $b} keys %all_species;
open OUT, ">> $result_file" or die;
print OUT join "\t", ('group', @unique_species);
foreach my $group (sort {$a cmp $b} keys %table){
    print OUT "\n$group";
    map {print OUT "\t", $table{$group}->{$_} || 0;} @unique_species;
}
close OUT;
