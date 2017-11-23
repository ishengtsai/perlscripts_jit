
REF=$1
READS=$2
CPU=$3

# Minimap
~/bin/minimap2/minimap2 -x map-ont -t$CPU $REF $READS  1> reads.paf 2> minimap.err

# Racon first round
~/bin/racon/bin/racon -t $CPU $READS reads.paf $REF consensus.1stround.fa 1>1st.out 2>1st.err


# Racon second round
~/bin/minimap2/minimap2 -x map-ont -t$CPU consensus.1stround.fa reads.fq  1> reads2.paf 2> minimap.err 
~/bin/racon/bin/racon -t $CPU $READS reads2.paf consensus.1stround.fa consensus.2ndround.fa 1>2nd.out 2>2nd.err 

# Racon third round
~/bin/minimap2/minimap2 -x map-ont -t$CPU consensus.2ndround.fa reads.fq  1> reads3.paf 2> minimap.err 
~/bin/racon/bin/racon -t $CPU $READS reads3.paf consensus.2ndround.fa consensus.3rdround.fa 1>3rd.out 2>3rd.err 

# Racon 4th round
~/bin/minimap2/minimap2 -x map-ont -t$CPU consensus.3rdround.fa reads.fq  1> reads4.paf 2> minimap.err
~/bin/racon/bin/racon -t $CPU $READS reads4.paf consensus.3rdround.fa consensus.4thround.fa 1>4th.out 2>4th.err

# Racon 5th round
~/bin/minimap2/minimap2 -x map-ont -t$CPU consensus.4thround.fa reads.fq  1> reads5.paf 2> minimap.err
~/bin/racon/bin/racon -t $CPU $READS reads5.paf consensus.4thround.fa consensus.5thround.fa 1>5th.out 2>5th.err
