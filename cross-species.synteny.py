import sys
from Bio import SeqIO




import fileinput

# assign files from arguments
file1 = sys.argv[1]
file2 = sys.argv[4]
file3 = sys.argv[3]
file4 = sys.argv[2] # groups.single.freq

sp34_celegans_ONEone = open(file3 + "sp34_celegans.one-one.freq", 'w')



species = open(file1, 'r')
groups_single_freq = open(file4, "r")

for line_species in species:
	line_species1 = line_species.split("\t")	

for line_fileinput in groups_single_freq:
	line_fileinput = line_fileinput.strip()
	line_fileinput1 = line_fileinput.split(":")
	line_fileinput2 = (line_fileinput1[1].strip()).split("\t")
	#print line_fileinput2
	#print line_fileinput2[0]
	#print line_fileinput2[3]
	if line_fileinput2[0]=="1" and line_fileinput2[3]=="1":
		sp34_celegans_ONEone.write(line_fileinput)
		sp34_celegans_ONEone.write("\n")

fileinput.close()
sp34_celegans_ONEone.close()



sp34_celegans_ONEone_anchors = open(file3 + "sp34_celegans.one-one", 'w')
sp34_celegans = open(file2, 'r')
for line_sp34_celegans in sp34_celegans:
	line_sp34_celegans = line_sp34_celegans.strip()
	line_sp34_celegans1 = line_sp34_celegans.split(":")
	line_sp34_celegans2 = line_sp34_celegans1[0].strip()
	#print "wow\n"
	#print line_sp34_celegans2

	groups_singleton = open(file3, 'r')


	for line_groups_singleton in groups_singleton:
		line_groups_singleton = line_groups_singleton.strip()
		line_groups_singleton1 = line_groups_singleton.split(":")
		line_groups_singleton2 = line_groups_singleton1[0].strip()
		if line_sp34_celegans2 == line_groups_singleton2:
			#print line_groups_singleton2
			sp34_celegans_ONEone_anchors.write(line_groups_singleton)
			sp34_celegans_ONEone_anchors.write("\n")
			break
	groups_singleton.close()

sp34_celegans.close()
sp34_celegans_ONEone_anchors.close()

print "all done!!! " , file3 +"sp34_celegans.one-one.freq and " , file3 + "sp34_celegans.one-one produced!\n" 






