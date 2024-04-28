#!/bin/bash
apt-get upgrade && apt-get update

wget -O astrometry.net-0.94.tar.gz "https://github.com/dstndstn/astrometry.net/releases/download/0.94/astrometry.net-0.94.tar.gz"
wget -O sextractor-2.28.0.tar.gz "https://github.com/astromatic/sextractor/archive/refs/tags/2.28.0.tar.gz"
wget -O scamp-2.10.0.tar.gz "https://github.com/astromatic/scamp/archive/refs/tags/v2.10.0.tar.gz"
wget -O swarp-2.41.5.tar.gz "https://github.com/astromatic/swarp/archive/refs/tags/2.41.5.tar.gz"
wget -O psfex-3.24.2.tar.gz "https://github.com/astromatic/psfex/archive/refs/tags/3.24.2.tar.gz"
wget -O hotpants-5.1.11.tar.gz https://github.com/Astro-Lee/hotpants/releases/download/v5.1.11/hotpants-5.1.11.tar.gz

tar -zxvf astrometry.net-0.94.tar.gz
tar -zxvf sextractor-2.28.0.tar.gz
tar -zxvf scamp-2.10.0.tar.gz
tar -zxvf swarp-2.41.5.tar.gz
tar -zxvf psfex-3.24.2.tar.gz
tar -zxvf hotpants-5.1.11.tar.gz

#astrometry.net
sudo apt install -y build-essential curl git file pkg-config swig \
       libcairo2-dev libnetpbm10-dev netpbm libpng-dev libjpeg-dev \
       zlib1g-dev libbz2-dev libcfitsio-dev wcslib-dev \
       python3 python3-pip python3-dev \
       python3-numpy python3-scipy python3-pil

cd astrometry.net-0.94
./configure && make -j$(nproc) && make -j$(nproc) py && make -j$(nproc) extra && sudo make install

#sextractor
sudo apt install -y libatlas-base-dev libfftw3-dev
./autogen.sh && ./configure && make -j$(nproc) && sudo make install

#scamp
./autogen.sh && ./configure && make -j$(nproc) && sudo make install

#swarp
./autogen.sh && ./configure && make -j$(nproc) && sudo make install

#psfex
sudo apt install -y libplplot-dev libpthread-stubs0-dev
./autogen.sh && ./configure LDFLAGS='-pthread' && make -j4 && sudo make install

# hotpants
