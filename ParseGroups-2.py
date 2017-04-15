import sys
from Bio import SeqIO



import fileinput

# assign files from arguments
file1 = sys.argv[1]


target = open(file1 + ".single.freq", 'w')
title = open(file1 + ".title_groups.single.freq", 'w')

print "producing ", file1 + ".single.freq\n" 
print "producing ", file1 + ".title_groups.single.freq\n" 

# Need to change here
species = ['Sp34', 'c_angaria', 'c_japonica', 'c_elegans', 'c_briggsae', 'c_remanei', 'c_brenneri', 'n_americanus']

count_specie = 0
for specie in species:
	count_specie = count_specie + 1
	if count_specie == len(species):
		title.write("%s\n" %specie)
	else:
		title.write("%s\t" %specie)
title.close()


for line in open(file1):
	content = []
	#print "line: "
	#print line
	#print "split by ':' "
	line1=line.split(":")
	#print "line1[0]: %s" %line1[0]
	target.write(line1[0])
	target.write(":\t")
	#print "line1[1]: "
	#print line1[1]
	line2=line1[1]
	#print "split by ' ' "
	line3=line2.split()
	#print "line3: "
	#print line3
	#print "\n"
	#print "split by '|' "
	for x in line3:
		content.append(x.split("|")[0])
	#print content
	#print "\n"
	result_dict = dict( [ (i, content.count(i)) for i in set(content) ] )
	#print "result_dict: "
	#print result_dict
	#print "\n"
	#print "print the value: "
	#print result_dict.get("Sp34")
	#print "\n"
	count_specie = 0
	for specie in species:
		count_specie = count_specie + 1
		if count_specie == len(species):
			if specie in result_dict:
				target.write("%d\n" %result_dict.get(specie))
			else:
				target.write("0\n")
		else:
			if specie in result_dict:
				target.write("%d\t" %result_dict.get(specie))
			else:
				target.write("0\t")

fileinput.close()
target.close()

