#!/bin/bash
set -e
set -u
set -o pipefail


# Arguments
# -project The project name given to init_project.sh
# -chipID ID for the pulldown file
# -inputID ID for input file
# -ID the ID common to chip and input
PROJECT=$2
chipID=$4
inputID=$6
humanID=$8

# Go to the project directory
cd ~/latte/mint/${PROJECT}

# Create appropriate file names
bowtie2Bam=./analysis/bowtie2_bams/${chipID}_pulldown_aligned.bam
bowtie2InputBam=./analysis/bowtie2_bams/${inputID}_pulldown_aligned.bam
macsPrefix=${humanID}_pulldown_macs2
macsNarrowpeak=./analysis/macs_peaks/${humanID}_pulldown_macs2_peaks.narrowPeak
macsTmp=./analysis/macs_peaks/${humanID}_pulldown_macs2_peaks_tmp.narrowPeak
bowtie2InputBedgraph=./analysis/pulldown_coverages/${inputID}_pulldown_zero.bdg
macsBigbed=./analysis/summary/${PROJECT}_hub/hg19/${humanID}_pulldown_macs2_peaks.bb

# MACS2 to call peaks
macs2 callpeak -t $bowtie2Bam -c $bowtie2InputBam -f BAM -g hs --outdir ./analysis/macs_peaks -n $macsPrefix

# Determine region of zero input coverage for classification
bedtools genomecov -bga -ibam $bowtie2InputBam -g ~/latte/Homo_sapiens/chromInfo_hg19.txt | grep -w '0$' > $bowtie2InputBedgraph

# Visualization in UCSC Genome Browser

    sort -T . -k1,1 -k2,2n $macsNarrowpeak | awk -v OFS="\t" '$5 > 1000 { print $1, $2, $3, $4, "1000", $6, $7, $8, $9, $10 } $5 <= 1000 { print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10 }' > $macsTmp

    # Convert to bigBed
    # The *.as file apparently needs to be in the same folder as the files being converted
    bedToBigBed -type=bed6+4 -as=narrowPeak.as $macsTmp ~/latte/Homo_sapiens/chromInfo_hg19.txt $macsBigbed
    rm $macsTmp