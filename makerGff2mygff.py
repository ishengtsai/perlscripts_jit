#!/usr/bin/env python3

import argparse
import re


import pandas as pd
import operator
from collections import OrderedDict, Counter
from pprint import pprint

from Bio import SeqIO

import subprocess



# Some help for the script
parser = argparse.ArgumentParser(description='Converts maker gff to my own custom gff with a specified ID, also does some summary statistics' + '\nNote: still some problem parsing Transdecoder\'s output')

parser.add_argument('--gff', required=True)
parser.add_argument('--proteinfile', required=True)
parser.add_argument('--transcriptfile', required=True)
parser.add_argument('--speciesprefix', required=True)
parser.add_argument('--excludescaffolds', required=True)


# start parsing input
args=parser.parse_args()
species = args.speciesprefix

# read excluded scaffolds file
excludeFile = open(args.excludescaffolds,"r")

# use set as unique values
excludeScaffolds = set()

# Read gff file
for line in excludeFile:
        line = line.rstrip()
        excludeScaffolds.add(line) 
        
excludeFile.close()
        

# first read maker file
gffFile = open(args.gff,"r")


        


# invoke two dictionaries and some variables
geneLines = []

LinesinGene = {}
LinesinCDS= {}

geneName = ''

# flags to check how many isoforms
isoformNum = {}

#Open some files to print out stuff
fw_gff = open(species+'.gff', 'w')
fw_gtf = open(species+'.gtf', 'w')
fw_rawgff = open(species+'.raw.gff', 'w')


print ("Now start parsing maker gff files..\n")

# Read gff file
for line in gffFile:

        #print ("here", line)

        
        # Skip commented lines and fasta file afterwards
        if re.search('^\#', line):
                continue
        if re.search('^\>', line):
                break
        # sometimes we have weird lines like this here: skip
        #   .5.0.639;Parent=Weevil.scaffold0003:hit:85732:4.5.0.639;Target=snap_masked-Weevil.scaffold0003-abinit-gene-639.27-mRNA-1 293 297 +;Gap=M5
        if re.search('^\.', line):
                continue
        


        
        line = line.rstrip()
        r= line.split()
        r[3] = int(r[3])
        r[4] = int(r[4])

        #skip if found in contaminated scaffolds
        if r[0] in excludeScaffolds:
                continue

        
        # skip if start greater than end
        if r[3] > r[4]:
                print ("erm......", r[3], r[4], line)
                continue

        
        # Now need to reference from this section
        # http://www.ebi.ac.uk/~marco/2016_python_course/2-Advanced_data_structures-and-file-parsing.html

        if len(r) < 2:
                print(r)
                break


        #print("has it got here?", r)


        
        if r[1] in "maker":
                # Need to convert numbers into int type! for sorting numerically later
                r[3] = int(r[3])
                
                #print("here!!!", r)

                if r[2] == "gene":
                        #print(r[8])

                        # Match the gene name
                        geneName = re.search('ID=(\S+)\;Name', r[8]).group(1)

                        # Put the scaffold name, start coord and gene name into a list of lists
                        # geneLines.append([r[0],int(r[3]),geneName])

                        # Another way:
                        # Ordered dictionary
                        # http://www.ebi.ac.uk/~marco/2016_python_course/2-Advanced_data_structures-and-file-parsing.html
                        line_dict = OrderedDict({
                                "seqid":r[0], 
                                "start":r[3],
                                "genename":geneName })
                        geneLines.append(line_dict)

                        LinesinGene[geneName] = [line]

                #Append the lines as list (string is not mutable)

                # For my own analysis, I really just need mRNA and CDS for now. so skip everything else
                if ( r[2] in [ 'mRNA'] ):

                        # Only one isoform here!
                        if re.search('-mRNA-1;', line):                        
                                LinesinGene[geneName ].append(line)
                                
                                
                        if r[2] == 'mRNA':
                                if not geneName in isoformNum:
                                        isoformNum[geneName] = 1
                                else:
                                        print("alternative isoform:", geneName)
                                        isoformNum[geneName] += 1

                # Actually, since we are going to sort the CDS, it's easier to put them into a separate block
                # And because we are going to sort, make it list of list
                if r[2] == 'CDS':
                        # But we also want one isoform only
                        if re.search('-mRNA-1:cds', line):
                                if not geneName in LinesinCDS:
                                        LinesinCDS[geneName] = [r]
                                else:
                                        LinesinCDS[geneName].append(r)


        r[3] = str(r[3])
        r[4] = str(r[4])
        print(*r[0:9], sep="\t", file=fw_rawgff)

        # to convert it back to integar ; so later it's also sorted numerically
        r[3] = int(r[3])
        r[4] = int(r[4])
        

# use bedtools to sort
fw_rawgff.close()
print('sorting raw gff...')

# Still buggy
#fw_rawDeleteWronggff = open( species+ '.raw2.gff' , "w")
#bedtoolsPriorcommand = ["awk '$5>$4 {print $_}' " , species+'.raw.gff' ]
#subprocess.call(fw_rawDeleteWronggff, stdout=fw_rawDeleteWronggff)


fw_rawsortedgff = open( species+ '.raw.sorted.gff' , "w")
bedtoolscommand =  ['bedtools', 'sort',  '-i',  species+'.raw.gff'  ] 
print('run: ' , bedtoolscommand ) 
subprocess.call(bedtoolscommand, stdout=fw_rawsortedgff)


        


# Now start parsing


# Sort by seqid then start
df = pd.DataFrame(geneLines)
dfsorted = df.sort_values(by=["seqid","start"], ascending=[True,True] )
print('\nSorted df:\n', dfsorted.head())
#print(dfsorted.head())


# Now the list of genes
geneNameordered = dfsorted['genename']
print('\n\n\nFirst 10 sorted genes:\n' , geneNameordered.head(10))


# Some summary statistics
geneTotal = len(isoformNum)
isoformTotal = 0


# Check number of isoforms
# Since it's still in dev version, break the script when more than one isoform is found!
for gene, isoforms in isoformNum.items():
        isoformTotal += isoforms
        #if isoforms > 1:
        #        print(gene, ' has ', isoforms, ' isoforms!')


print ("\n\nTotal number of genes: ", geneTotal , "\nTotal number of isoforms: " , isoformTotal)
                

NewGeneID = 0 




old2newGene = {}


#Time to print out new gff                
print ("\n\nNow sorting out genes!\n\n")
for gene in geneNameordered:
        NewGeneID += 100
        ThisGeneID = species + '_{:0>8}'.format(NewGeneID)
        #print ('Old gene = ' + gene , 
        #       '\tNew gene:', ThisGeneID  )

        # not here
        #old2newGene[gene] = ThisGeneID
        
        for line in LinesinGene[gene]:
                r = line.split('\t')
                #print (r)

                # From python 3.0 , you can use file=xxxx in print function to direct print into file                
                if r[2] == "gene":
                        # 0:8 means 8 is not included
                        print  ('\t'.join(r[0:8]) , '\tID=', ThisGeneID , ';Name=' ,  ThisGeneID, ';' ,  sep='', file=fw_gff)
                if r[2] == "mRNA":
                        print ('\t'.join(r[0:8]) , '\tID=' , ThisGeneID , ':mRNA;Name=', ThisGeneID  ,':mRNA;Parent=', ThisGeneID , ';' , sep='', file=fw_gff)

                        if re.search('Name=(\S+);_AED' , line ):
                                oldmRNA = re.search('Name=(\S+);_AED' ,line ).group(1)
                                #print(oldmRNA)
                                old2newGene[oldmRNA ] = ThisGeneID

        # sort CDS to always increment from 5' to 3'
        #pprint (LinesinCDS[gene])
        #print ('\n\n\n\n')

        #https://docs.python.org/2/howto/sorting.html
        # need to sort numerically ; so need to convert to int!!!!!
        LinesinCDS[gene]  = sorted(LinesinCDS[gene], key = operator.itemgetter(3)  )  # 3 = leftmost coordinate of CDS


        

        
        #pprint (LinesinCDS[gene])
        #print ('\n\n\n\n\n')
        
        CDSnum = 1 ;
        for line in LinesinCDS[gene]:
                line[3] = str(line[3]) # convert to string so can be joined
                line[4] = str(line[4])
                print ('\t'.join(line[0:8]) + '\tID=' + ThisGeneID  + ':mRNA:CDS:' , CDSnum,
                       ';Parent=',  ThisGeneID  , ':mRNA;color=9;' ,sep='', file=fw_gff)
                line[2] = 'exon'
                print ('\t'.join(line[0:8])  + '\t' + 'gene_id' ,  '"' + ThisGeneID + '";'  , 'transcript_id' , '"' +ThisGeneID + ':mRNA";' , 'exon_number', '"' + str(CDSnum) + '";' ,  file=fw_gtf)
                #print ('\t'.join(line[0:8]) + '\t' + 'gene_id' ,  '"' + ThisGeneID + '";'  , 'transcript_id' , '"' +ThisGeneID + ':mRNA";' , 'exon_number', '"' +CDSnum+ '";', file=fw_gtf)
                CDSnum += 1
        

                

fw_gff.close()


#Time to read the protein fasta and replace with the new ID

# first read maker file


print ("Now start parsing maker protein files..\n")

# Read protein file and check again

aaPrinted = {}
transcriptPrinted = {}

fasta_sequences = SeqIO.parse(open(args.proteinfile),'fasta')

with open(species+'.maker.aa.fa', 'w') as fw_protein:
        for fasta in fasta_sequences:
                name, sequence = fasta.id, str(fasta.seq)

                
                print (name)
                
                if name in old2newGene:
                        fasta.id = old2newGene[name]
                        if old2newGene[name] not in aaPrinted:
                                print (name, "->", old2newGene[name]) 
                                SeqIO.write(fasta, fw_protein, "fasta")
                                aaPrinted[ old2newGene[name] ] = '1'
                        

                #new_sequence = some_function(sequence)
                #SeqIO.write
                #write_fasta(out_file)


fasta_sequences = SeqIO.parse(open(args.transcriptfile),'fasta')

with open(species+'.maker.nuc.fa', 'w') as fw_transcript:
        for fasta in fasta_sequences:
                name, sequence = fasta.id, str(fasta.seq)
                print (name)

                if name in old2newGene:
                        fasta.id = old2newGene[name]
                        if old2newGene[name] not in transcriptPrinted:
                                #print (name, "->", old2newGene[name])
                                SeqIO.write(fasta, fw_transcript, "fasta")
                                transcriptPrinted[ old2newGene[name] ] = '1'
                

'''
for line in fr_protein:
        match=re.search('^>(\S+)-mRNA-1', line)
        if match:
                geneName = match.group(1)
                if geneName in old2newGene:
                        print ('>' + old2newGene[geneName]  , file=fw_protein)
                else:
                        print ('Warning! Not consistent between maker gff and maker protein file!')
                        quit()
        else:
                print (line, end='', file=fw_protein)
        
'''


print ("All done! All done!\n\n")



