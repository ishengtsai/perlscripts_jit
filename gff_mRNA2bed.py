import sys
from Bio import SeqIO


import fileinput
import re

fileout = open(sys.argv[2], 'w')


for line in fileinput.input():
	line1 = []
	line1 = line.split("\t")

        #mRNA is better
	if line1[2]=="mRNA":
		fileout.write ("%s\t" %line1[0])
		fileout.write ("%s\t" %line1[3])
		fileout.write ("%s\t" %line1[4])

                #search for words following :mRNA
                gene_name = re.match('ID=(.+):mRNA;Name', line1[8])
                fileout.write ( gene_name.group(1) )
                fileout.write ("\t1000\t")
                fileout.write ("%s\n" %line1[6])
                


		#line2 = []
		#line2 = line1[8].split(";")
		#line2 = line2[0].split("=")
		#fileout.write ("%s\t" %line2[1])
		#fileout.write ("1000\t")
		#fileout.write ("%s\n" %line1[6])
fileout.close()






