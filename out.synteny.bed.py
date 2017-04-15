import sys
from Bio import SeqIO



try:
  file3 = open(sys.argv[3], "r")
except IOError:
  print "There was an error reading from", sys.argv[3]
  sys.exit()


for line3 in file3:
	line3 = line3.strip()
	line3 = line3.split("\t")

	try:
		file1 = open(sys.argv[1], "r")
	except IOError:
		print "There was an error reading from", sys.argv[1]
		sys.exit()

	for line1 in file1:
		line1 = line1.strip()
		line1 = line1.split("\t")
		#if (line3[0].split("."))[0] == line1[3]:
                if line3[1] == line1[3]:
			print line1[0]+"\t"+line1[1]+"\t"+line1[2]+"\t",
	file1.close()

	try:
		file2 = open(sys.argv[2], "r")
	except IOError:
		print "There was an error reading from", sys.argv[2]
		sys.exit()

	for line2 in file2:
		line2 = line2.strip()
		line2 = line2.split("\t")
		if line3[1] == line2[3]:
			print line2[0]+":"+line2[1]
	file2.close()
	
file3.close()





