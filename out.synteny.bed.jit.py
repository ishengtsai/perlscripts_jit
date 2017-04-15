import sys
import fileinput
import getopt



# assign files from arguments
file1 = sys.argv[1]
file2 = sys.argv[2]
file3 = sys.argv[3]

# output file
fileout = open(sys.argv[4], 'w')


# dict for species1 and species2
species1_gene_coords = dict()
species2_gene_coords = dict()


#open first file
print ("Opening ", file1, " ...")

# save everything into a set
for line in open(file1):
    #print (line, end="")
    set1 = line.split()

    # species1 dictionary: query
    # We need something like Sp34.scaff0093  104828  110052
    species1_gene_coords[set1[3]] = set1[0] + "\t" + set1[1] + "\t" + set1[2]

print (len(species1_gene_coords) , " genes collected in " , file1)


# Repeat for file 2
file1 = sys.argv[2]
print ("Opening ", file2, " ...")

# save everything into a set
for line in open(file2):
    #print (line, end="")
    set1 = line.split()

    # species 2 dictionary: reference
    # We need something like CHROMOSOME_IV:13868788
    species2_gene_coords[set1[3]] = set1[0] + ":" + set1[1]

print (len(species2_gene_coords) , " genes collected in " , file2)



# Now, open the gene pairs file to do parsing
for line in open(file3):
    set1 = line.split()

    #print (set1[0])
    # is first and second gene in both dictionary?
    if ( set1[0] in species1_gene_coords.keys() and set1[1] in species2_gene_coords.keys()  ):
        result = species1_gene_coords[ set1[0] ] + "\t" + species2_gene_coords[ set1[1] ]  + "\n"
        fileout.write (result)

print ( "all done! ", fileout.name ," produced!")


