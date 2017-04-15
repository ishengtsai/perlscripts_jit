#!/usr/bin/env python3

import argparse
import re


import pandas as pd
import numpy as np

import operator
from collections import OrderedDict, Counter
from pprint import pprint

# Some help for the script
parser = argparse.ArgumentParser(description='Read gff of my own format and calculate  summary statistics')

parser.add_argument('--gff', required=True)


# start parsing input
args=parser.parse_args()



geneLines = []


# first read gff file
gffFile = open(args.gff,"r")



print ("Now start parsing maker gff files..\n")

# Right most position of exon to calculate intron
previousIntron3pos = 0

# Read gff file
for line in gffFile:

        line = line.rstrip()
        r= line.split()
        
        # Need to convert numbers into int type! for sorting numerically later
        r[3] = int(r[3])
        r[4] = int(r[4])        

        
        if r[2] == "gene":
                
                geneName = re.search('ID=(\S+)\;Name', r[8]).group(1)
                #print('geneName is', geneName)

                line_dict = OrderedDict({
                        "type": 'gene',
                        "seqid":r[0],
                        "length": r[4]-r[3]+1,
                        "genename":geneName })
                geneLines.append(line_dict)
                
                # df append is so much slower, put in list first
                #dfGene.append( {'Name': geneName, 'scaffold': r[0], 'start': r[3], 'end': r[4] } , ignore_index=True )

        
                
        if r[2] == 'CDS':
                geneName, CDSnum = re.search('ID=(\S+):(\d+)\;Parent', r[8]).group(1,2)
                #print(geneName , CDSnum)

                line_dict = OrderedDict({
                        "type": 'CDS',
                        "seqid":r[0],
                        "length": r[4]-r[3]+1,
                        "genename":geneName+CDSnum })
                geneLines.append(line_dict)
                
                        
                # calculate intron
                if int(CDSnum) > 1:
                        intronName = re.sub('CDS','intron',geneName)
                        intronLen = r[3] - previousIntron3pos + 1
                        line_dict = OrderedDict({
                                "type": 'intron',
                                "seqid":r[0],
                                "length": intronLen,
                                "genename":intronName+  str( int(CDSnum) -1  ) })
                        geneLines.append(line_dict)

                previousIntron3pos = r[4] 

                        
                
gffFile.close()


# Now some summary
#pprint(geneLines[0:5])



# invoke  data frame
df = pd.DataFrame(geneLines)

print('\n\n\nDataframe:\n' ,  df.head(20))


#Start parsing different sum and category based on
print ('\n\nSummary statistics:\n')


# Group by
# http://www.shanelynn.ie/summarising-aggregation-and-grouping-data-in-python-pandas/
# http://bconnelly.net/2013/10/summarizing-data-in-python-with-pandas/
dfGroup = df.groupby('type')
indexInoutput = ['gene', 'CDS', 'intron']

# Calculate individual results
# http://www.shanelynn.ie/summarising-aggregation-and-grouping-data-in-python-pandas/
# http://bconnelly.net/2013/10/summarizing-data-in-python-with-pandas/
# https://docs.scipy.org/doc/numpy/reference/routines.statistics.html
result = dfGroup['length'].agg([np.sum, np.median, np.amin, np.amax, np.ptp ]  )

# Reindex  using order I want
indexInoutput = ['gene', 'CDS', 'intron']
#print ('Ordered:\n\n', result.reindex(indexInoutput))


# This is what I want:
# Reorder tables: http://nikgrozev.com/2015/07/01/reshaping-in-pandas-pivot-pivot-table-stack-and-unstack-explained-with-pictures/
print('Ordered, unstacked and transposed:\n', result.reindex(indexInoutput).transpose().unstack())

print ('\nValues in different format to copy and paste:\n' )

resultforcopyandpaste = [ str(s) for s in result.reindex(indexInoutput).transpose().unstack().values.tolist() ]
print ('\n'.join(resultforcopyandpaste) )
print ('\n')
print ('\t'.join(resultforcopyandpaste) )




