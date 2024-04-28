FROM ubuntu:latest

MAINTAINER Rui-Zhi Li <liruizhi@ynao.ac.cn>

#设置编码
ENV LANG C.UTF-8
# 设置默认时区
ENV TZ=Asia/Shanghai

ENV GIT_SSL_NO_VERIFY=1

# dependencies
RUN apt update \
&& apt upgrade -y \
&& apt install --no-install-recommends -y git wget vim gcc make \
autoconf automake libtool \
libcfitsio-dev libfftw3-dev libatlas-base-dev \
libjpeg-dev wcslib-dev libcairo2-dev swig libnetpbm10-dev netpbm libpng-dev zlib1g-dev libbz2-dev libcurl4-gnutls-dev file pkg-config \
&& apt clean

RUN wget --no-check-certificate "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(uname -m).sh" \
&& sh Miniconda3-latest-Linux-$(uname -m).sh -bfu -p /opt/miniconda3 \
&& rm Miniconda3-latest-Linux-$(uname -m).sh \
&& eval "$(/opt/miniconda3/bin/conda shell.bash hook)" \
&& conda init \
&& conda install -y python==3.10 setuptools numpy

WORKDIR /opt

COPY build.sh /opt/build.sh
ARG sextractor_version=2.28.0
ARG scamp_version=2.10.0
ARG swarp_version=2.41.5
ARG psfex_version=3.24.2
ARG hotpants_version=5.1.11
ARG astrometry_net_version=0.94

# download source code
RUN wget --no-check-certificate -O "sextractor-${sextractor_version}.tar.gz" "https://github.com/astromatic/sextractor/archive/refs/tags/${sextractor_version}.tar.gz"
RUN wget --no-check-certificate -O "scamp-${scamp_version}.tar.gz" "https://github.com/astromatic/scamp/archive/refs/tags/v${scamp_version}.tar.gz"
RUN wget --no-check-certificate -O "swarp-${swarp_version}.tar.gz" "https://github.com/astromatic/swarp/archive/refs/tags/${swarp_version}.tar.gz"
RUN wget --no-check-certificate -O "psfex-${psfex_version}.tar.gz" "https://github.com/astromatic/psfex/archive/refs/tags/${psfex_version}.tar.gz"
RUN wget --no-check-certificate -O "hotpants-${hotpants_version}.tar.gz" "https://github.com/Astro-Lee/hotpants/archive/refs/tags/${hotpants_version}.tar.gz"
RUN wget --no-check-certificate -O "astrometry.net-${astrometry_net_version}.tar.gz" "https://github.com/dstndstn/astrometry.net/archive/refs/tags/${astrometry_net_version}.tar.gz"

# extract
RUN tar -zxvf sextractor-${sextractor_version}.tar.gz
RUN tar -zxvf scamp-${scamp_version}.tar.gz
RUN tar -zxvf swarp-${swarp_version}.tar.gz
RUN tar -zxvf psfex-${psfex_version}.tar.gz
RUN tar -zxvf hotpants-${hotpants_version}.tar.gz
RUN tar -zxvf astrometry.net-${astrometry_net_version}.tar.gz

# install sextractor
RUN cd sextractor-${sextractor_version} && ./autogen.sh && ./configure && make -j$(nproc) && make install

# install scamp
RUN cd scamp-${scamp_version} && ./autogen.sh && ./configure && make -j$(nproc) && make install

# install swarp
RUN cd swarp-${swarp_version} && ./autogen.sh && ./configure && make -j$(nproc) && make install

# install psfex
RUN cd psfex-${psfex_version} && ./autogen.sh && ./configure LDFLAGS='-pthread' && make -j$(nproc) && make install

# install hotpants
RUN cd hotpants-${hotpants_version} && make -j$(nproc) && make install

# install Astrometry.Net
RUN eval "$(/opt/miniconda3/bin/conda shell.bash hook)" && \
cd astrometry.net-${astrometry_net_version} && ./configure && make && make py && make extra && make install && \
echo 'export PATH=${PATH}:/usr/local/astrometry/bin' >>  ~/.bashrc

# https://astrometry.net/doc/build-index.html
# http://astrometry.net/doc/readme.html#getting-index-files
# http://data.astrometry.net/
# download index files to /usr/local/astrometry/data OR
# make install-indexes

# clean up
RUN rm -rf astrometry.net-* sextractor-* scamp-* swarp-* psfex-* hotpants-*

# # RUN ./build.sh
RUN apt update && apt upgrade -y && apt install -y git
RUN git clone --depth=1 https://github.com/karpov-sv/stdweb.git && git clone --depth=1 https://github.com/karpov-sv/stdpipe.git

RUN eval "$(/opt/miniconda3/bin/conda shell.bash hook)" \
&& cd /opt/stdpipe && python3 -m pip install -e . \
&& cd /opt/stdweb && pip install -r requirements.txt \
&& pip install redis watchdog \
&& python manage.py migrate 

WORKDIR /opt/stdweb

RUN mkdir data tasks \
&& tee .env <<'EOF'
SECRET_KEY = 'your django secret key goes here'

DEBUG = True

DATA_PATH = /opt/stdweb/data/
TASKS_PATH = /opt/stdweb/tasks/

STDPIPE_HOTPANTS=/usr/local/bin/hotpants
STDPIPE_SOLVE_FIELD=/usr/local/astrometry/bin/solve-field
EOF

EXPOSE 8000

CMD bash
# ./run_celery.sh &
# python manage.py runserver 0.0.0.0:8000