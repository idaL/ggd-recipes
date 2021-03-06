#!/bin/bash
## Much of this is taken from bioconda: https://github.com/bioconda/bioconda-utils/blob/master/.circleci/setup.sh

set -exo pipefail 

WORKSPACE=$(pwd)

# Set path
echo "export PATH=$WORKSPACE/anaconda/bin:$PATH" >> $BASH_ENV
source $BASH_ENV

# setup conda and dependencies 
if [[ ! -d $WORKSPACE/anaconda ]]; then
    mkdir -p $WORKSPACE


    # step 1: download and install anaconda
    if [[ $OSTYPE == darwin* ]]; then
        tag="MacOSX"
        tag2="darwin"
    elif [[ $OSTYPE == linux* ]]; then
        tag="Linux"
        tag2="linux"
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi

    curl -O https://repo.continuum.io/miniconda/Miniconda3-latest-$tag-x86_64.sh
    sudo bash Miniconda3-latest-$tag-x86_64.sh -b -p $WORKSPACE/anaconda/
    sudo chown -R $USER $WORKSPACE/anaconda/

    mkdir -p $WORKSPACE/anaconda/conda-bld/$tag-64


    # step 2: setup channels
    conda config --system --add channels defaults
    conda config --system --add channels bioconda
    conda config --system --add channels conda-forge
    conda config --system --add channels ggd-genomics

    
    # step 3: install ggd requirements 
    conda install -y --file requirements.txt 


    # step 4: install requirments from git repos
    ## Install bioconda-utils
    curl -s https://raw.githubusercontent.com/bioconda/bioconda-common/master/common.sh > .circleci/bioconda-common.sh
    source .circleci/bioconda-common.sh
    conda install -y --file https://raw.githubusercontent.com/bioconda/bioconda-utils/$BIOCONDA_UTILS_TAG/bioconda_utils/bioconda_utils-requirements.txt
    pip install git+https://github.com/bioconda/bioconda-utils.git@$BIOCONDA_UTILS_TAG
    ## Install ggd-cli
    pip install -U git+git://github.com/gogetdata/ggd-cli 


    # step 5: cleanup
    conda clean -y --all


    # step 6: download conda_build_config.yaml from conda_forge and put into conda root (Required for using bioconda-utils build)
    cur=`pwd`
    CONDA_ROOT=$(conda info --root)
    cd $CONDA_ROOT
    curl -O https://raw.githubusercontent.com/conda-forge/conda-forge-pinning-feedstock/master/recipe/conda_build_config.yaml
    cd $cur


    # step 7: set up local channels
    # Add local channel as highest priority
    conda index $WORKSPACE/anaconda/conda-bld/
    conda config --system --add channels file://$WORKSPACE/anaconda/conda-bld
fi

conda config --get

ls $WORKSPACE/anaconda/conda-bld
ls $WORKSPACE/anaconda/conda-bld/noarch

