#!/bin/bash
INPUTCOLLECTION=$1
INDIR=$TASK_KEEPMOUNT/$INPUTCOLLECTION
OUTDIR=$(pwd)
echo indir~ $INDIR
echo outdir~ $OUTDIR ls~
ls $OUTDIR

vcf2wt $INDIR/mergedvcf.vcf --truncate --quiet -tf $OUTDIR
echo "wormtable of vcf created"
wtadmin add $OUTDIR CHROM+POS
wtadmin add $OUTDIR CHROM+ID
