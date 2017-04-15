import sys
import fileinput
import getopt

from collections import defaultdict

# assign files from arguments
file1 = sys.argv[1]
specieslist = sys.argv[2].split(",")



# output file
outputfilename = file1 + ".matrix"
fileout = open(outputfilename, 'w')

#open first file
print ("Opening ", file1, " ...")


count = 1

#print header
header = "Group"

for speciesname in specieslist:
    header += "\t" + speciesname
fileout.write(header + "\n" )

# save everything into a set
for line in open(file1):
    #print (line, end="")
    lineset = line.split()
    
    # remove first item , which is group_1:
    result = lineset.pop(0) ; 
    

    #print ("line: " + str(count)  )

    # create an empty defaultdict

    genedictionary = defaultdict(list)
    # And append gene into each species
    for chunk in lineset:
        species,gene = chunk.split("|")
        genedictionary[species].append(gene)
    
    #print ( genedictionary.items() )


    
    for species in specieslist:
        if species in genedictionary.keys():
            numgenes = str (len (genedictionary[species]) )
            #print ("\t" + numgenes, end="")
            result += ("\t" + numgenes)
        else:
            #print ("\t0", end="")
            result += ("\t0")


    fileout.write(result + "\n")

    count += 1
    if count == 10:
        break




print ("all done!\n" + outputfilename + " produced!")



