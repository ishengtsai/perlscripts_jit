import sys
import fileinput
import getopt

from collections import defaultdict

# assign files from arguments
file1 = sys.argv[1]

# two species : Species1 being the query, and Species2 being the reference
species1 = sys.argv[2]
species2 = sys.argv[3]


# output file
outputfilename = species1 + "." + species2 + ".1x1.anchors"
fileout = open(outputfilename, 'w')

#open first file
print ("Opening ", file1, " ...")


count = 1

# save everything into a set
for line in open(file1):
    #print (line, end="")
    lineset = line.split()
    
    # remove first item , which is group_1:
    lineset.pop(0) ; 

    #print ("line: " + str(count)  )

    # create an empty defaultdict

    genedictionary = defaultdict(list)
    # And append gene into each species
    for chunk in lineset:
        species,gene = chunk.split("|")
        genedictionary[species].append(gene)
    
    #print ( genedictionary.items() )

    for species in genedictionary.keys():
        # various ways here to show lists in python
        numgenes = str (len (genedictionary[species]) )
        #print ("Species:" + species + " has: " + numgenes )
        #print ("Species:" + species + " has: " + " " .join(genedictionary[species]) )


    if ( len (genedictionary[species1]) == 1 and len (genedictionary[species2])== 1 ):
        #print ( "" .join(genedictionary[species1]) + "\t" + "" . join(genedictionary[species2]) + "\t2000" )
        result = "" .join(genedictionary[species1]) + "\t" + "" . join(genedictionary[species2]) + "\t2000\n"
        fileout.write(result)


    #count += 1
    #if count == 10000:
    #    break




print ("all done!\n" + outputfilename + " produced!")



