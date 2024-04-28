FROM ubuntu:latest

MAINTAINER Rui-Zhi Li <liruizhi@ynao.ac.cn>

RUN apt-get upgrade && apt-get update && \ 
apt-get install -y git wget vim gcc make \ 
libmagic-dev sextractor scamp psfex swarp libcfitsio-dev \
build-essential curl git file pkg-config swig \
libcairo2-dev libnetpbm10-dev netpbm libpng-dev libjpeg-dev \
zlib1g-dev libbz2-dev libcfitsio-dev wcslib-dev \
python3 python3-pip python3-dev \
python3-numpy python3-scipy python3-pil



RUN cd /opt \
&& git clone --depth=1 https://github.com/karpov-sv/stdweb.git \
&& git clone --depth=1 https://github.com/karpov-sv/stdpipe.git \
&& wget https://astrometry.net/downloads/astrometry.net-latest.tar.gz \
&& wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh \
&& sh Miniconda3-latest-Linux-aarch64.sh -bfu -p /opt/miniconda3

RUN cd /opt \
&& tar -xvzf astrometry.net-latest.tar.gz \
&& cd /opt/astrometry.net-* \
&& make && make py && make extra && make install \
&& cd /opt && rm -rf astrometry.net-*

RUN cd /opt && rm -rf Miniconda3-latest-Linux-aarch64.sh

RUN echo 'eval "$(/opt/miniconda3/bin/conda shell.bash hook)"' >> ~/.bashrc

RUN cd /opt/stdpipe && ./install_hotpants.sh
RUN eval "$(/opt/miniconda3/bin/conda shell.bash hook)" && conda install -y python==3.10 \
&& cd /opt/stdweb && pip install -r requirements.txt \
&& cd /opt/stdpipe && python3 -m pip install -e . \
&& cd /opt && rm -rf stdpipe

RUN eval "$(/opt/miniconda3/bin/conda shell.bash hook)" && cd /opt/stdweb \
&& pip install redis watchdog \
&& python manage.py migrate \
&& mkdir data tasks \
&& tee .env <<-'EOF'
SECRET_KEY = 'your django secret key goes here'

DEBUG = True

DATA_PATH = /opt/stdweb/data/
TASKS_PATH = /opt/stdweb/tasks/

STDPIPE_HOTPANTS=/usr/local/bin/hotpants
STDPIPE_SOLVE_FIELD=/usr/local/astrometry/bin/solve-field
EOF

EXPOSE 8000

WORKDIR /opt/stdweb

CMD bash
# ./run_celery.sh &
# python manage.py runserver 0.0.0.0:8000