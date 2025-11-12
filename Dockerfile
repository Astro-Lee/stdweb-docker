FROM ubuntu:latest

LABEL maintainer="Rui-Zhi Li <liruizhi@ynao.ac.cn>"

# ====== 基本环境配置 ======
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV GIT_SSL_NO_VERIFY=1
ENV PATH=/opt/conda3/bin:$PATH

# ====== 系统依赖 ======
RUN apt update && apt upgrade -y && \
    apt install --no-install-recommends -y \
        git wget vim gcc make autoconf automake libtool \
        libcfitsio-dev libfftw3-dev libatlas-base-dev \
        libjpeg-dev wcslib-dev libcairo2-dev swig libnetpbm10-dev netpbm \
        libpng-dev zlib1g-dev libbz2-dev libcurl4-gnutls-dev file pkg-config \
        python3-astrometry ca-certificates && \
    apt clean && rm -rf /var/lib/apt/lists/*

# ====== 安装 Mambaforge (conda-forge) ======
RUN wget --no-check-certificate "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-$(uname -m).sh" && \
    bash Mambaforge-Linux-$(uname -m).sh -b -p /opt/conda3 && \
    rm Mambaforge-Linux-$(uname -m).sh && \
    conda config --set always_yes yes --set changeps1 no && \
    conda update -n base -c defaults conda && \
    conda install -c conda-forge python=3.10 numpy=1.25.2 setuptools jupyter pip

WORKDIR /opt

# ====== 版本定义 ======
ARG sextractor_version=2.28.2
ARG scamp_version=2.14.0
ARG swarp_version=2.41.5
ARG psfex_version=3.24.2
ARG hotpants_version=5.1.11
ARG astrometry_net_version=0.97

# ====== 下载源码并安装 ======
RUN set -eux; \
    wget -O sextractor.tar.gz "https://github.com/astromatic/sextractor/archive/refs/tags/${sextractor_version}.tar.gz" && \
    wget -O scamp.tar.gz "https://github.com/astromatic/scamp/archive/refs/tags/v${scamp_version}.tar.gz" && \
    wget -O swarp.tar.gz "https://github.com/astromatic/swarp/archive/refs/tags/${swarp_version}.tar.gz" && \
    wget -O psfex.tar.gz "https://github.com/astromatic/psfex/archive/refs/tags/${psfex_version}.tar.gz" && \
    wget -O hotpants.tar.gz "https://github.com/Astro-Lee/hotpants/archive/refs/tags/${hotpants_version}.tar.gz" && \
    wget -O astrometry.tar.gz "https://github.com/dstndstn/astrometry.net/archive/refs/tags/${astrometry_net_version}.tar.gz" && \
    tar -xzf sextractor.tar.gz && cd sextractor-* && ./autogen.sh && ./configure && make -j$(nproc) && make install && cd .. && \
    tar -xzf scamp.tar.gz && cd scamp-* && ./autogen.sh && ./configure && make -j$(nproc) && make install && cd .. && \
    tar -xzf swarp.tar.gz && cd swarp-* && ./autogen.sh && ./configure && make -j$(nproc) && make install && cd .. && \
    tar -xzf psfex.tar.gz && cd psfex-* && ./autogen.sh && ./configure LDFLAGS='-pthread' && make -j$(nproc) && make install && cd .. && \
    tar -xzf hotpants.tar.gz && cd hotpants-* && make -j$(nproc) && make install && cd .. && \
    tar -xzf astrometry.tar.gz && cd astrometry.net-* && ./configure && make && make py && make extra && make install && cd .. && \
    rm -rf *.tar.gz sextractor-* scamp-* swarp-* psfex-* hotpants-* astrometry.net-*

# ====== 安装 stdpipe & stdweb ======
RUN git clone --depth=1 https://github.com/karpov-sv/stdpipe.git && \
    pip install -e ./stdpipe && \
    git clone --depth=1 https://github.com/karpov-sv/stdweb.git && \
    cd stdweb && \
    pip install -r requirements.txt && \
    pip install watchdog && \
    python manage.py migrate

# ====== 设置环境与配置 ======
WORKDIR /opt/stdweb

RUN mkdir -p data tasks notebooks && \
    echo "SECRET_KEY = 'your django secret key goes here'" > .env && \
    echo "DEBUG = True" >> .env && \
    echo "DATA_PATH = /opt/stdweb/data/" >> .env && \
    echo "TASKS_PATH = /opt/stdweb/tasks/" >> .env && \
    echo "STDPIPE_HOTPANTS=/usr/local/bin/hotpants" >> .env && \
    echo "STDPIPE_SOLVE_FIELD=/usr/local/astrometry/bin/solve-field" >> .env && \
    sed -i "/ALLOWED_HOSTS/a\# CSRF_TRUSTED_ORIGINS = ['https://example.domain.com']" stdweb/settings.py && \
    sed -i "s@redis://localhost/@redis://redis/@g" stdweb/settings.py && \
    sed -i "s@redis://127.0.0.1@redis://redis@g" stdweb/settings.py

ADD start.sh /opt/stdweb/start.sh

EXPOSE 8000 8888

CMD ["/usr/bin/env", "bash"]
