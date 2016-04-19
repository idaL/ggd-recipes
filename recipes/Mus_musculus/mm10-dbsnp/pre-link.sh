#!/bin/bash
set -eo pipefail

# converted from: ../cloudbiolinux/ggd-recipes/mm10/dbsnp.yaml

mkdir -p $PREFIX/share/ggd/Mus_musculus/mm10/ && cd $PREFIX/share/ggd/Mus_musculus/mm10/

baseurl=https://s3.amazonaws.com/biodata/variants/mm10-dbSNP-2013-09-12.vcf.gz
mkdir -p variation
cd variation
wget -c -N $baseurl
wget -c -N $baseurl.tbi

