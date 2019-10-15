Bootstrap: docker
From: ubuntu:16.04

%labels
  maintainer Dominik Handler <Dominik Handler@imba.oeaw.ac.at  
  all tools required for the AnnotationPipeline

%post    
  apt-get update
  apt-get -y install locales
  locale-gen en_US.UTF-8

  export LANG=en_US.UTF-8  
  export LANGUAGE=en_US:en  
  export LC_ALL=en_US.UTF-8  

  mkdir /install

  #install all required tools
  apt-get update
  apt-get -y install parallel wget build-essential bzip2 unzip git-core tar libbz2-dev
      
  #install R
    apt-get update
    apt-get --assume-yes install pandoc libgit2-dev libssl-dev libcurl4-gnutls-dev libxml2-dev xorg-dev libopenblas-dev libcairo2-dev libxt-dev libtiff5-dev openjdk-8-jdk libreadline6-dev libpng-dev

    mkdir -p /install/R
    cd /install/R
    version="3.5.3"
    wget --quiet  http://cran.at.r-project.org/src/base/R-3/R-$version.tar.gz
    tar -xzf R-$version.tar.gz  
    cd R-$version
    ./configure --with-blas=-lopenblas --enable-R-shlib --with-lapack --enable-threads --with-libtiff --with-cairo=yes --with-libpng=yes 

    make
    make install

    #install R-packages  
    R --slave -e 'install.packages(c( "devtools"), repos = "http://cran.wu.ac.at/") '
    R --slave -e 'install.packages(c( "tidyverse", "plotly", "Cairo", "gridExtra"), repos = "http://cran.wu.ac.at/") '
    R --slave -e 'options(unzip = "internal"); devtools::install_github("tidyverse/ggplot2") '
    R --slave -e 'install.packages(c( "cowplot" ), repos = "http://cran.wu.ac.at/") '
    R --slave -e 'install.packages(c( "BiocManager" ), repos = "http://cran.wu.ac.at/") '
    R --slave -e 'library(BiocManager); BiocManager::install("remotes"); BiocManager::install("pachterlab/sleuth@v0.30.0")'
    R --slave -e 'library(BiocManager); BiocManager::install("rhdf5")'
    R --slave -e 'library(BiocManager); BiocManager::install("COMBINE-lab/wasabi")'

  #clean up and make container smaller
    rm -rf /install
   
%environment
  #!/bin/bash
  export LANG=en_US.UTF-8  
  export LANGUAGE=en_US:en  
  export LC_ALL=en_US.UTF-8  

%runscript
  $@

