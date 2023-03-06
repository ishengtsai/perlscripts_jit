
REF=$1
READS=$2
CPU=$3
MAPPER=$4

RACONBIN=/home/ijt/bin/racon-v1.3.1/build/bin/racon

# Minimap
minimap2 -ax $MAPPER -t$CPU $REF $READS  1> reads.sam 2> minimap.err

# Racon first round
$RACONBIN -t $CPU $READS reads.sam $REF 1> consensus.1stround.fa  2>1st.err


# Racon second round
minimap2 -ax $MAPPER -t$CPU consensus.1stround.fa $READS  1> reads2.sam 2> minimap.err 
$RACONBIN -t $CPU $READS reads2.sam consensus.1stround.fa 1> consensus.2ndround.fa  2>2nd.err 

# Racon third round
minimap2 -ax $MAPPER -t$CPU consensus.2ndround.fa $READS  1> reads3.sam 2> minimap.err 
$RACONBIN -t $CPU $READS reads3.sam consensus.2ndround.fa 1> consensus.3rdround.fa  2>3rd.err 

# Racon 4th round
minimap2 -ax $MAPPER -t$CPU consensus.3rdround.fa $READS  1> reads4.sam 2> minimap.err
$RACONBIN -t $CPU $READS reads4.sam consensus.3rdround.fa 1> consensus.4thround.fa  2>4th.err

# Racon 5th round
minimap2 -ax $MAPPER -t$CPU consensus.4thround.fa $READS  1> reads5.sam 2> minimap.err
$RACONBIN -t $CPU $READS reads5.sam consensus.4thround.fa 1> consensus.5thround.fa  2>5th.err
