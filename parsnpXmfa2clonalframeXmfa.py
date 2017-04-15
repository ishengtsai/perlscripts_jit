#!/usr/bin/env python3

import argparse
import re


import pandas as pd
import numpy as np

import operator
from collections import OrderedDict, Counter
from pprint import pprint

# Some help for the script
parser = argparse.ArgumentParser(description='Converts parsnp xmfa to clonalframeML xmfa')

parser.add_argument('--xmfa', required=True)


# start parsing input
args=parser.parse_args()



geneLines = []


# first read gff file
xmfaFile = open(args.xmfa,"r")




print ("Now start parsing parsnp  xmfa files..\n")

seq_index = ''
seq_name = '' 
seq_dict = {}

fw_xmfa = open(args.xmfa+'.new.xmfa', 'w')

# Read gff file
for line in xmfaFile:


        if ( re.search('##SequenceIndex (\d+)', line)  ):
                seq_index  = re.search('##SequenceIndex (\d+)', line).group(1)
                #print('Sequence Index = ', seq_index)

        if ( re.search('##SequenceFile (\S+)', line)  ):
                seq_name  = re.search('##SequenceFile (\S+)', line).group(1)
                print('Sequence Index = ', seq_index, ' Sequence File =', seq_name )
                seq_dict[ seq_index ] = seq_name 


                

        if ( re.search('^>', line) ):
                new_header =  re.search('^>(\d+):(\d+-\d+). ([-+])' , line )
                
                print( '>' , seq_dict[new_header.group(1)], sep='', file=fw_xmfa)
                #print( new_header.group() , seq_dict[new_header.group(1)], file=fw_xmfa)
                
                #http://stackoverflow.com/questions/10025881/how-to-do-regex-replace-in-python-using-dictionary-values-where-key-is-another
                #new_header =  re.sub('^>(\d+):',lambda x:  '>{}:'.format( seq_dict[x.group(1)] ),  line)
                #print(new_header, end='', file=fw_xmfa)

        else:
                print(line, end='', file=fw_xmfa)


fw_xmfa.close()
xmfaFile.close()

print ('All done!\n\n')
