#!/bin/bash
set -e

# This script is used to build and install the following software:
sextractor_version=2.28.0
scamp_version=2.10.0
swarp_version=2.41.5
psfex_version=3.24.2
hotpants_version=5.1.11
astrometry_net_version=0.94

# Current working directory
CWD=$(pwd)

# download source code
wget --no-check-certificate -O "sextractor-${sextractor_version}.tar.gz" "https://github.com/astromatic/sextractor/archive/refs/tags/${sextractor_version}.tar.gz"
wget --no-check-certificate -O "scamp-${scamp_version}.tar.gz" "https://github.com/astromatic/scamp/archive/refs/tags/v${scamp_version}.tar.gz"
wget --no-check-certificate -O "swarp-${swarp_version}.tar.gz" "https://github.com/astromatic/swarp/archive/refs/tags/${swarp_version}.tar.gz"
wget --no-check-certificate -O "psfex-${psfex_version}.tar.gz" "https://github.com/astromatic/psfex/archive/refs/tags/${psfex_version}.tar.gz"
wget --no-check-certificate -O "hotpants-${hotpants_version}.tar.gz" "https://github.com/Astro-Lee/hotpants/archive/refs/tags/${hotpants_version}.tar.gz"
wget --no-check-certificate -O "astrometry.net-${astrometry_net_version}.tar.gz" "https://github.com/dstndstn/astrometry.net/archive/refs/tags/${astrometry_net_version}.tar.gz"

# extract
tar -zxvf sextractor-${sextractor_version}.tar.gz
tar -zxvf scamp-${scamp_version}.tar.gz
tar -zxvf swarp-${swarp_version}.tar.gz
tar -zxvf psfex-${psfex_version}.tar.gz
tar -zxvf hotpants-${hotpants_version}.tar.gz
tar -zxvf astrometry.net-${astrometry_net_version}.tar.gz

# install sextractor
cd ${CWD}/sextractor-${sextractor_version} && ./autogen.sh && ./configure && make -j$(nproc) && make install

# install scamp
cd ${CWD}/scamp-${scamp_version} && ./autogen.sh && ./configure && make -j$(nproc) && make install

# install swarp
cd ${CWD}/swarp-${swarp_version} && ./autogen.sh && ./configure && make -j$(nproc) && make install

# install psfex
cd ${CWD}/psfex-${psfex_version} && ./autogen.sh && ./configure LDFLAGS='-pthread' && make -j$(nproc) && make install

# install hotpants
cd ${CWD}/hotpants-${hotpants_version} && make -j$(nproc) && make install

# # install Astrometry.Net
eval "$(/opt/miniconda3/bin/conda shell.bash hook)" && \
cd ${CWD}/astrometry.net-${astrometry_net_version} && ./configure && make -j$(nproc) && make -j$(nproc) py && make -j$(nproc) extra && make install

# https://astrometry.net/doc/build-index.html
# http://astrometry.net/doc/readme.html#getting-index-files
# http://data.astrometry.net/
# download index files to /usr/local/astrometry/data OR
# make install-indexes

tee -a ~/.bashrc <<'EOF'
export PATH=${PATH}:/usr/local/astrometry/bin
EOF
source ~/.bashrc

# test
sex --version
scamp --version
swarp --version
psfex --version
echo Astrometry.Net version $(solve-field --version)
hotpants

# clean up
# cd ${CWD} && rm -rf astrometry.net-* sextractor-* scamp-* swarp-* psfex-* hotpants-*