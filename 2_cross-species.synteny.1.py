import sys
from Bio import SeqIO

import fileinput

file1 = sys.argv[1] # sp34_celegans.one-one

sp34_celegans_ONEone_anchors = open("Sp34.CEL_WS248.1x1.anchors", 'w')



sp34_celegans = open(file1, 'r')
for line in sp34_celegans:
		line = line.strip()
		line1 = line.split(":")
		line2 = (line1[1].strip()).split(" ")
		gene_c = []
		gene_s = []
		for x in line2:
			if "Sp34" in x:
				gene_s = x.split("|")
				#print "wow-1: "
				#print gene_s[1]
			elif "c_elegans" in x:
				#print x
				gene_c = x.split("|")
				#print gene_c[1]
		sp34_celegans_ONEone_anchors.write("%s\t" %gene_s[1])
		sp34_celegans_ONEone_anchors.write("%s\t" %gene_c[1])
		sp34_celegans_ONEone_anchors.write("2000\n")

sp34_celegans_ONEone_anchors.close()		


print "done! Sp34.CEL_WS248.1x1.anchors produced!\n" 

