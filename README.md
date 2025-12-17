# STDWeb

STDWeb - web version of [STDPipe](https://github.com/karpov-sv/stdpipe) (Docker)

## Step 0
- `git clone https://github.com/Astro-Lee/stdweb-docker.git`
- Download suitable index files from [data.astrometry.net](http://data.astrometry.net/), as introduced in [astrometry](https://github.com/neuromorphicsystems/astrometry) (also refer to [download_index.sh](https://github.com/Astro-Lee/stdweb-docker/blob/master/download_index.sh)). Map the saved path to the container by referring to [docker-compose.yaml](https://github.com/Astro-Lee/stdweb-docker/blob/master/docker-compose.yaml).
- `docker compose up -d`
- `docker exec -it stdweb bash`

⚠️: All the following operations are carried out in the container

## Step 1
### create a superuser
```python
python manage.py createsuperuser
```

## Step 2
### generate a django secret key
```bash
#edit .env
python -c "from django.core.management import utils; print(utils.get_random_secret_key())"
```

## Step 3
### reverse proxy 
```bash
#edit stdweb/settings.py
CSRF_TRUSTED_ORIGINS = [ 'https://example.domain.com', ]
```

---
## update
```bash
cd /opt/stdpipe && git pull && python -m pip install -e .
cd /opt/stdweb && git pull && pip install -r requirements.txt \
&& sed -i "/ALLOWED_HOSTS/a\# CSRF_TRUSTED_ORIGINS = [ 'https://example.domain.com', ]" stdweb/settings.py \
&& sed -i "s@redis:\/\/localhost\/@redis:\/\/redis\/@g" stdweb/settings.py \
&& sed -i "s@redis:\/\/127.0.0.1@redis:\/\/redis@g" stdweb/settings.py
```
---
## jupyter-lab
```bash
nohup jupyter-lab --notebook-dir=/opt/notebooks --ip='*' --port=8888 --no-browser --allow-root &
