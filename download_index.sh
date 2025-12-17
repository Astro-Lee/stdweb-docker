#!/usr/bin/env bash
set -e

# https://astrometry.net/doc/build-index.html
# http://astrometry.net/doc/readme.html#getting-index-files
# http://data.astrometry.net/
# download index files to /usr/local/astrometry/data OR

# index-5201-*
for ((i=0; i<48; i++)); do
    I=$(printf %02i $i)
    wget https://portal.nersc.gov/project/cosmo/temp/dstn/index-5200/LITE/index-5201-$I.fits
done

# index-5203-*
for ((i=0; i<48; i++)); do
    I=$(printf %02i $i)
    wget https://portal.nersc.gov/project/cosmo/temp/dstn/index-5200/LITE/index-5203-$I.fits
done

# index-5205-*
for ((i=0; i<48; i++)); do
    I=$(printf %02i $i)
    wget https://portal.nersc.gov/project/cosmo/temp/dstn/index-5200/LITE/index-5205-$I.fits
done
