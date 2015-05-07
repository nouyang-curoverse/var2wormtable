#!/bin/bash
INPUTCOLLECTION=$1
INDIR=$TASK_KEEPMOUNT/$INPUTCOLLECTION
OUTDIR=$(pwd)
outfile=mergedvcf.vcf

#create header and write to outfile
echo indir $INDIR
FILES="$INDIR"/*.vcf
echo number of VCF files:  ${#FILES[@]}

for file in "$INDIR"/*.vcf; do
echo $file
cat $file | sed '/^#CHROM/q' > $OUTDIR/$outfile
break 1
done

#drop headers on all files and concatenate to outfile
for file in "$INDIR"/*.vcf; do
echo $file
cat $file | sed '1,/^#CHROM/d' >> $OUTDIR/$outfile
done
