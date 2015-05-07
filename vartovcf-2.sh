#!/bin/bash
# this operates on collection with a lot of var files in it
INPUTCOLLECTION=$1
timestamp() {
      date
      free -m
  }

DIR=$HOME
OUTDIR=$(pwd)
echo OUTDIR $OUTDIR
INDIR=$TASK_KEEPMOUNT/$INPUTCOLLECTION
cd $INDIR

FILES=(*.tsv.bz2) #hu132B5C.tsv.bz2
echo number of tsv.bz2 files:  ${#FILES[@]}

for FILE in $FILES; do
        timestamp
        echo "starting new file: "
        echo $(pwd) $FILE
        shortfilename=$(basename "$FILE" .tsv.bz2) #hu132B5C
        mkdir $DIR/$shortfilename
        mkdir $DIR/$shortfilename/ASM
        DIR2=($DIR/$shortfilename)
        echo $shortfilename "unzipping..."
        bzip2 -dcvk $INDIR/$FILE > $DIR/$(basename "$DIR/$FILE" .bz2) #hu132B5C.tsv
        echo "done unzipping" $shortfilename
        head -n 13 $DIR/$(basename "$DIR/$FILE" .bz2) > $DIR2/ASM/masterVarBeta-$shortfilename.tsv #grab the header lines
        grep -E "chr(13|17)" $DIR/$(basename "$DIR/$FILE" .bz2) >> $DIR2/ASM/masterVarBeta-$shortfilename.tsv
        cp $INDIR/$FILE $DIR2/ASM/var-$shortfilename.tsv.bz2 #cgatools also needs the tsv.bz2
        echo "chr 13 and 17 extracted into tsv aka var format" 
        /home/nrw/local/bin/cgatools mkvcf --beta --genome-root $DIR2 --source-names masterVar --reference /home/nrw/data/ref/build37.crr --output $OUTDIR/$shortfilename.vcf --field-names GT
        echo "chr13&17 vcf created"
        rm $DIR/$(basename "$DIR/$FILE" .bz2) #because the tsv file is huge and useless
        rm -r $DIR2
        echo "files cleaned up for " $FILE
done
