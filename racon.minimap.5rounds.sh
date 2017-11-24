
REF=$1
READS=$2
CPU=$3

# Minimap
~/bin/minimap/minimap -t$CPU $REF $READS  1> reads.paf 2> minimap.err

# Racon first round
~/bin/racon/bin/racon -t $CPU $READS reads.paf $REF consensus.01.fa 1>01.out 2>01.err


# Racon second round
~/bin/minimap/minimap -t$CPU consensus.01.fa $READS  1> reads2.paf 2> minimap.err 
~/bin/racon/bin/racon -t $CPU $READS reads2.paf consensus.01.fa consensus.02.fa 1>02.out 2>02.err 

# Racon third round
~/bin/minimap/minimap -t$CPU consensus.02.fa $READS  1> reads3.paf 2> minimap.err 
~/bin/racon/bin/racon -t $CPU $READS reads3.paf consensus.02.fa consensus.03.fa 1>03.out 2>03.err 

# Racon 4th round
~/bin/minimap/minimap -t$CPU consensus.03.fa $READS  1> reads4.paf 2> minimap.err
~/bin/racon/bin/racon -t $CPU $READS reads4.paf consensus.03.fa consensus.04.fa 1>04.out 2>04.err

# Racon 5th round
~/bin/minimap/minimap -t$CPU consensus.04.fa $READS  1> reads5.paf 2> minimap.err
~/bin/racon/bin/racon -t $CPU $READS reads5.paf consensus.04.fa consensus.05.fa 1>05.out 2>05.err

