#!/usr/bin/env perl

use strict;
use warnings;




my $PI = `echo $$` ;    chomp($PI) ;


eval { 
    require "warnings.pm" ;

} or do {
    my $error = $@ ; 
    die "daopdpoapdaod\n" ; 

};


eval { require "Parallel/ForkManager.pm" };
if ($@) {
    die "hmmmmmm something went wrong!\n" ; 
}

#unless ($@) {
#  $got_ForkManager = 1;
#  Parallel::ForkManager->import();
#}
