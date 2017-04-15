#!/usr/bin/env python3

import argparse
import re


import pandas as pd
import numpy as np

import operator
from collections import OrderedDict, Counter
from pprint import pprint

# Some help for the script
parser = argparse.ArgumentParser(description='Read formatted out and convert to Anna\'s gff format ')

parser.add_argument('--out', required=True)


# start parsing input
args=parser.parse_args()



geneLines = []


# first read gff file
inFile = open(args.out,"r")

fw_gff = open( args.out +'.gff', 'w')


'''
Original

   SW   perc perc perc  query                    position in query        matching       repeat           position in repeat
score   div. del. ins.  sequence                 begin  end      (left)   repeat         class/family   begin  end    (left)  ID

  2020 12.46 0.97 0.97 1_STRLTR 350 657 (88632985) + Sr2 LINE 3 310 (3602) m_b1s001i0 *clean*
  277 16.07 5.36 0.00 1_STRLTR 656 711 (88632931) + Sr2 LINE 3854 3912 (0) m_b1s001i1 *clean*
  1005 27.37 3.86 0.00 1_STRLTR 770 1054 (88632588) C Penelope PLE (475) 2199 1904 m_b1s001i2 *clean*
  2791 6.91 0.77 0.25 1_STRLTR 1044 1435 (88632207) C Sinbad LTR (5732) 394 1 m_b1s001i3 *clean*
  1276 26.76 0.87 0.87 1_STRLTR 1435 1777 (88631865) C Penelope PLE (760) 1914 1572 m_b1s001i4 *clean*
  1174 22.03 0.00 0.00 1_STRLTR 2120 2355 (88631287) + Penelope PLE 2380 2615 (59) m_b1s001i5 *clean*

'''

print ("Now start parsing maker gtf files..\n")

# Right most position of exon to calculate intron

repeatcount= 1

# Read gff file
for line in inFile:

        if not re.search('^\s+\d+', line):
                continue


        
        
        line = line.rstrip()
        r= line.split()

        # ignore single exon hints!
        #if r[6] == '.':
        #        continue
        
        r[8] = re.sub('C', '-', r[8])
        
        #print(r)
        print(r[4], r[10], 'repeat_region', r[5], r[6], r[1], r[8], '.', 'Parent=Repeat' + str(repeatcount) + ';Family=' + r[9] ,  sep='\t', file=fw_gff)
        repeatcount += 1

        
                
inFile.close()
fw_gff.close()


print ( args.out + '.gff' , 'is printed! All done!') 




