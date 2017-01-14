# Minimap
~/bin/minimap/minimap -t32 ref.fa reads.fq  1> reads.paf 2> minimap.err

# Racon first round
~/bin/racon/bin/racon -t 30 reads.fq reads.paf ref.fa consensus.1stround.fa 1>1st.out 2>1st.err


# Racon second round
~/bin/minimap/minimap -t32 consensus.1stround.fa reads.fq  1> reads2.paf 2> minimap.err 
~/bin/racon/bin/racon -t 30 reads.fq reads2.paf consensus.1stround.fa consensus.2ndround.fa 1>2nd.out 2>2nd.err 

# Racon third round
~/bin/minimap/minimap -t32 consensus.2ndround.fa reads.fq  1> reads3.paf 2> minimap.err 
~/bin/racon/bin/racon -t 30 reads.fq reads3.paf consensus.2ndround.fa consensus.3rdround.fa 1>3rd.out 2>3rd.err 

