#!/usr/bin/env python3

import argparse
import re


import pandas as pd
import numpy as np

import operator
from collections import OrderedDict, Counter
from pprint import pprint

# Some help for the script
parser = argparse.ArgumentParser(description='Read stringtie gtf and convert to maker EST match gff3 ')

parser.add_argument('--gtf', required=True)


# start parsing input
args=parser.parse_args()



geneLines = []


# first read gff file
gtfFile = open(args.gtf,"r")

fw_gff = open( args.gtf +'.gff', 'w')


'''
Maker:
contig-dpp-500-500      est2genome      expressed_sequence_match        26786   31656   14993   +       .       ID=contig-dpp-500-500:hit:53:3.2.0.0;Name=dpp-mRNA-5
contig-dpp-500-500      est2genome      match_part      26786   26955   14993   +       .       ID=contig-dpp-500-500:hsp:62:3.2.0.0;Parent=contig-dpp-500-500:hit:53:3.2.0.0;Target=dpp-mRNA-5 1 170 +;Gap=M170
contig-dpp-500-500      est2genome      match_part      27104   27985   14993   +       .       ID=contig-dpp-500-500:hsp:63:3.2.0.0;Parent=contig-dpp-500-500:hit:53:3.2.0.0;Target=dpp-mRNA-5 171 1052 +;Gap=M882
contig-dpp-500-500      est2genome      match_part      29709   31656   14993   +       .       ID=contig-dpp-500-500:hsp:64:3.2.0.0;Parent=contig-dpp-500-500:hit:53:3.2.0.0;Target=dpp-mRNA-5 1053 3000 +;Gap=M1948

000000F StringTie       transcript      24358   27249   1000    +       .       gene_id "MSTRG.1"; transcript_id "MSTRG.1.1";
000000F StringTie       exon    24358   24680   1000    +       .       gene_id "MSTRG.1"; transcript_id "MSTRG.1.1"; exon_number "1";
000000F StringTie       exon    24730   24742   1000    +       .       gene_id "MSTRG.1"; transcript_id "MSTRG.1.1"; exon_number "2";
000000F StringTie       exon    24793   25092   1000    +       .       gene_id "MSTRG.1"; transcript_id "MSTRG.1.1"; exon_number "3";
000000F StringTie       exon    25146   25273   1000    +       .       gene_id "MSTRG.1"; transcript_id "MSTRG.1.1"; exon_number "4";
000000F StringTie       exon    25327   26065   1000    +       .       gene_id "MSTRG.1"; transcript_id "MSTRG.1.1"; exon_number "5";
000000F StringTie       exon    26115   27249   1000    +       .       gene_id "MSTRG.1"; transcript_id "MSTRG.1.1"; exon_number "6";

000000F est2genome      expressed_sequence_match        24358   27249   1000    +       ID=MSTRG.1:hit;Name=MSTRG.1
000000F est2genome      match_part      24358   24680   1000    +       ID=MSTRG.1:hsp;Parent=MSTRG.1:hit;Target:MSTRG.1
000000F est2genome      match_part      24730   24742   1000    +       ID=MSTRG.1:hsp;Parent=MSTRG.1:hit;Target:MSTRG.1
000000F est2genome      match_part      24793   25092   1000    +       ID=MSTRG.1:hsp;Parent=MSTRG.1:hit;Target:MSTRG.1
000000F est2genome      match_part      25146   25273   1000    +       ID=MSTRG.1:hsp;Parent=MSTRG.1:hit;Target:MSTRG.1
000000F est2genome      match_part      25327   26065   1000    +       ID=MSTRG.1:hsp;Parent=MSTRG.1:hit;Target:MSTRG.1
000000F est2genome      match_part      26115   27249   1000    +       ID=MSTRG.1:hsp;Parent=MSTRG.1:hit;Target:MSTRG.1
000000F est2genome      expressed_sequence_match        16039   17726   1000    -       ID=MSTRG.2:hit;Name=MSTRG.2
000000F est2genome      match_part      16039   16636   1000    -       ID=MSTRG.2:hsp;Parent=MSTRG.2:hit;Target:MSTRG.2
000000F est2genome      match_part      16690   17726   1000    -       ID=MSTRG.2:hsp;Parent=MSTRG.2:hit;Target:MSTRG.2

#Ignore these:
000000F est2genome      match_part      150032  150363  1000    .       ID=MSTRG.39:hsp;Parent=MSTRG.39:hit;Target:MSTRG.39
000000F est2genome      expressed_sequence_match        129328  132348  1000    -       ID=MSTRG.40:hit;Name=MSTRG.40

'''

print ("Now start parsing maker gtf files..\n")

# Right most position of exon to calculate intron


# Read gff file
for line in gtfFile:

        if re.search('^#', line):
                continue


        
        
        line = line.rstrip()
        r= line.split()

        # ignore single exon hints!
        if r[6] == '.':
                continue
        
        r[1] = 'est2genome'
        r[2] = r[2].replace('transcript', 'expressed_sequence_match')
        r[2] = r[2].replace('exon', 'match_part')

        r.remove('gene_id')
        r.remove('transcript_id')

        r[9] = re.sub('[";]', '', r[9])
        
        final_line = 'ID=' + r[9]
        
        if r[2] == 'expressed_sequence_match':
                final_line += ':hit;Name=' + r[9]
                
        if r[2] == 'match_part':
                r.remove('exon_number')
                final_line += ':hsp;Parent=' + r[9] + ':hit;Target:' + r[9]
        
        #print(r)
        print(*r[0:8], final_line, sep='\t' , file=fw_gff)


        
                
gtfFile.close()
fw_gff.close()


print ( args.gtf + '.gff' , 'is printed! All done!') 

# Now some summary
#pprint(geneLines[0:5])



