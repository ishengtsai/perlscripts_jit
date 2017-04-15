import sys
from Bio import SeqIO


import fileinput

'''
try:
  # open file stream
  file = open(file_name, "w")
except IOError:
  print "There was an error writing to", file_name
  sys.exit()
'''

try:
  file1 = open(sys.argv[1], "r")
except IOError:
  print "There was an error reading from", sys.argv[1]
  sys.exit()

try:
  file2 = open(sys.argv[2], "r")
except IOError:
  print "There was an error reading from", sys.argv[2]
  sys.exit()

try:
  file3 = open(sys.argv[3], "r")
except IOError:
  print "There was an error reading from", sys.argv[3]
  sys.exit()


genes = []

for line in file1:
	line = line.strip()
	line = line.split("\t")
	genes.append(line[3])

for line2 in file2:
	line2 = line2.strip()
	line2 = line2.split("\t")
	genes.append(line2[3])

for line3 in file3:
	tmp = line3
	line3 = line3.strip()
	line3 = line3.split("\t")

#	if (line3[0].split("."))[0] in genes and line3[1] in genes:
        if (line3[0] in genes and line3[1] in genes):
		print tmp,


file1.close()
file2.close()
file3.close()





