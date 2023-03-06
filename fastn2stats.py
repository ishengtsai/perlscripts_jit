#!/usr/bin/env python3


# Passing argument
#https://docs.python.org/3.3/library/argparse.html
import argparse
from collections import Counter
import statistics
import re

import gzip

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
#parser.add_argument('--detailed',  help='reports further stats like N50, N90', action="store_true")
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

fastqGZpattern = [ re.compile('\.fq.gz$') ,
                 re.compile('\.fastq.gz$') ]


# default is fasta
seqfileformat = 'fasta'
#if (any(regex.search(filename) for regex in fastapattern)):
#    print ('is fasta!')
if (any(regex.search(filename) for regex in fastqpattern)):
    print (filename, 'is fastq!')
    seqfileformat = 'fastq'
elif (any(regex.search(filename) for regex in fastqGZpattern)):
    print (filename, 'is fastq gzipped!')
    seqfileformat = 'fastqGZ'
else:
    print ('Assume fasta')



# assign variables
seqlength = Counter()
totallength = 0 
maxlen = 0
minlen = 0 
cumseqnum = 0
numN = 0


if seqfileformat == 'fastqGZ':
    with gzip.open(filename, "rt") as fastn_file:
    
        for (title, sequence, quality) in FastqGeneralIterator(  fastn_file  ):
            seqlen = len(sequence)
            totallength += seqlen

            #Number of Ns
            numN += sequence.count('N')
            numN += sequence.count('n')

            seqlength[seqlen] += 1
            
            if minlen == 0:
                minlen = seqlen
            if minlen > seqlen:
                minlen = seqlen
            if maxlen <= seqlen:
                maxlen = seqlen
                
            cumseqnum += 1


else:    
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
                seqlength[ seqlen ] += 1

                #Number of Ns
                numN += seq_record.seq.count('N')
                numN += seq_record.seq.count('n')


                
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
                seqlength[seqlen] += 1

                #Number of Ns
                numN += sequence.count('N')
                numN += sequence.count('n')

                
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

# print out N50 , N90 etc                
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


# Now display stats
print ("Total seq len:" , totallength , "Total seq num:", cumseqnum, "longest:" , maxlen, "minimum:", minlen , "NumNs:", numN)
print ("N50:", GenomeBoundary['N50'] , ' bp ; ', "L50:", GenomeBoundary['L50'] , " ;" ,  "N90:", GenomeBoundary['N90'] , ' bp; ', "L90:", GenomeBoundary['L90'] )
print ("Mean:", '%.1f' % seqmeanlen  , 'bp ; ', "Median:", '%.1f' % seqmedianlen , 'bp')
print (filename, totallength, cumseqnum, '%.1f' % (seqmeanlen / 1000) , '%.1f' % (maxlen /1000), '%.1f' % (GenomeBoundary['N50'] / 1000) , GenomeBoundary['L50'], '%.1f' % (GenomeBoundary['N90'] / 1000) , GenomeBoundary['L90'] , numN , sep='\t')
print (filename,  '%.3f' % ( totallength / 1000000000 ), cumseqnum, '%.1f' % (seqmeanlen / 1000) , '%.1f' % (maxlen /1000), '%.1f' % (GenomeBoundary['N50'] / 1000) , GenomeBoundary['L50'], '%.1f' % (GenomeBoundary['N90'] / 1000), GenomeBoundary['L90'] , '%.1f' % (numN /1000) , sep='\t')

    
if args.nanohist:
    print ('Plotting histogram')
    out_png = args.nanohist + '.hist.png'
    bins = np.arange(0, 100000, 1000)
    plt.hist( allreadlen, bins=bins, alpha=0.5 , color="#3F5D7D")
    plt.title(args.nanohist)
    plt.xlim(0,80000)
    
    xlabeltext = 'Read len (bp); total=' + '%.3f' % ( totallength / 1000000000 )  + 'Gb ; N50=' +  str(GenomeBoundary['N50']) + 'bp ; Longest=' + str(maxlen)
    plt.xlabel(xlabeltext, fontsize=12)
    plt.ylabel("Frequency")
    plt.axvline(GenomeBoundary['N50'], color='b', linestyle='dashed', linewidth=2)
    
    plt.savefig(out_png, dpi=150)
    print (out_png, 'produced!')
    
    
if args.genomesize:
    coverage = totallength / args.genomesize / 1000000
    print ('coverage: %.2f' % coverage , 'X')
    
