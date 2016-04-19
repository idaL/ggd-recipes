#!/bin/bash
set -eo pipefail

# converted from: ../cloudbiolinux/ggd-recipes/hg38/clinvar.yaml

mkdir -p $PREFIX/share/ggd/Homo_sapiens/hg38/ && cd $PREFIX/share/ggd/Homo_sapiens/hg38/

baseurl=ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/archive/2015
version=20150330
mkdir -p variation
wget -c -O variation/clinvar-orig.vcf.gz $baseurl/clinvar_$version.vcf.gz
[[ -f variation/clinvar.vcf.gz ]] || zcat variation/clinvar-orig.vcf.gz | sed "s/^\([0-9]\+\)\t/chr\1\t/g" | sed "s/^MT/chrM/g" | sed "s/^X/chrX/g" | sed "s/^Y/chrY/g" | bgzip -c > variation/clinvar.vcf.gz
tabix -f -p vcf variation/clinvar.vcf.gz

