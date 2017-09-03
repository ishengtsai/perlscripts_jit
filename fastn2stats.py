#!/usr/bin/env python3


# Passing argument
#https://docs.python.org/3.3/library/argparse.html
import argparse
from collections import Counter
import statistics
import re

from Bio import SeqIO
from Bio.SeqIO.QualityIO import FastqGeneralIterator

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

import numpy as np



#https://stackoverflow.com/questions/33203645/how-to-plot-a-histogram-using-matplotlib-in-python-with-a-list-of-data
#%matplotlib inline
#x = np.random.normal(size = 1000)
#plt.hist(x, normed=True, bins=30)
#plt.ylabel('Probability');
# Some good tip here:
#https://stackoverflow.com/questions/19436789/biopython-seqio-to-pandas-dataframe
# much faster:
#http://biopython.org/DIST/docs/api/Bio.SeqIO-module.html


parser = argparse.ArgumentParser(description='Calculate stats for fastq or fastn, requires Biopython')
parser.add_argument('--fastn', required=True, help='input fasta or fastq file name')
parser.add_argument('--detailed',  help='reports further stats like N50, N90', action="store_true")
parser.add_argument('--nanohist',  help='Plot histogram for nanopore reads with parameter as title')
parser.add_argument('--genomesize',  help='report additional depth of coverage if this option is given', type=int)

args = parser.parse_args()

#print (args.detailed)
#print (args.genomesize)


filename = args.fastn
print ('filename is ' , filename)

#fastapattern = [ re.compile('\.fa$') ,
#                 re.compile('\.fasta$')  ]
fastqpattern = [ re.compile('\.fq$') ,
                 re.compile('\.fastq$') ]

# default is fasta
seqfileformat = 'fasta'
#if (any(regex.search(filename) for regex in fastapattern)):
#    print ('is fasta!')
if (any(regex.search(filename) for regex in fastqpattern)):
    print (filename, 'is fastq!')
    seqfileformat = 'fastq'
else:
    print ('can not determine fasta or fastq; assume fasta')



# assign variables
seqlength = Counter()
totallength = 0 
maxlen = 0
minlen = 0 
cumseqnum = 0





# store sequence length in counter
with open(filename) as fastn_file: # Will close handle cleanly
    identifiers = []
    #lengths = []

    if seqfileformat == 'fasta':
        for seq_record in SeqIO.parse(fastn_file, seqfileformat):  # (generator)
            #print (seq_record.id , "\t", len(seq_record.seq))
            #identifiers.append(seq_record.id)
            seqlen = len(seq_record.seq)
            totallength += seqlen
            
            if args.detailed is not None:
                seqlength[ seqlen ] += 1
            if minlen == 0:
                minlen = seqlen
            if minlen > seqlen:
                minlen = seqlen
            if maxlen <= seqlen:
                maxlen = seqlen
            
            cumseqnum += 1 

                
    elif seqfileformat == 'fastq':

        for (title, sequence, quality) in FastqGeneralIterator(fastn_file):
            seqlen = len(sequence)
            totallength += seqlen

            if args.detailed :
                seqlength[seqlen] += 1
            if minlen == 0:
                minlen = seqlen
            if minlen > seqlen:
                minlen = seqlen
            if maxlen <= seqlen:
                maxlen = seqlen
            
            cumseqnum += 1
            
#print(seqlength)


# element does the job
# https://docs.python.org/3/library/collections.html#collections.Counter

# Now display stats
print ("Total seq len:" , totallength , "Total seq num:", cumseqnum, "largest:" , maxlen, "minimum:", minlen)


# print out N50 , N90 etc                
if args.detailed:

    cumseqnum = 0
    cumlen = 0 
    GenomeBoundary = {}
    
    #mean
    seqmeanlen = statistics.mean(seqlength.elements())
    seqmedianlen = statistics.median(seqlength.elements())
    allreadlen = sorted(seqlength.elements(), reverse=True )
    
    for seqlen in allreadlen:
        cumseqnum += 1
        cumlen += seqlen
        if cumlen >= totallength * 0.5 and 'N50'not in GenomeBoundary:
            GenomeBoundary['N50'] = seqlen
            GenomeBoundary['L50'] =cumseqnum
        if cumlen >= totallength * 0.9 and 'N90'not in GenomeBoundary:
            GenomeBoundary['N90'] =seqlen
            GenomeBoundary['L90'] =cumseqnum
    
    print ("N50:", GenomeBoundary['N50'] , 'bp')
    print ("N90:", GenomeBoundary['N90'] , 'bp')
    print ("L50:", GenomeBoundary['L50'] )
    print ("L90:", GenomeBoundary['L90'] )
    print ("Mean:", seqmeanlen  , 'bp')
    print ("Median:", seqmedianlen , 'bp' )


    if args.nanohist:
        print ('here!')
        out_png = args.nanohist + '.hist.png'
        bins = np.arange(0, 50000, 1000)
        plt.hist( allreadlen, bins=bins, alpha=0.5 )
        plt.title(args.nanohist)
        plt.xlim(0,30000)

        xlabeltext = "Read len (bp), total=" + str(totallength) + 'bp ; N50=' +  str(GenomeBoundary['N50']) , 'bp'
        plt.xlabel(xlabeltext)
        plt.ylabel("Frequency")
        plt.axvline(GenomeBoundary['N50'], color='b', linestyle='dashed', linewidth=2)

        plt.savefig(out_png, dpi=150)
        print (out_png, 'produced!')
    
    
if args.genomesize:
    coverage = totallength / args.genomesize / 1000000
    print ('coverage: %.2f' % coverage , 'X')
    
