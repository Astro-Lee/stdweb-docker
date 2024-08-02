# STDWeb

STDWeb - web version of [STDPipe](https://github.com/karpov-sv/stdpipe) (Docker)

## Step 0
- `git clone https://github.com/Astro-Lee/stdweb-docker.git`
- Download suitable index files from [data.astrometry.net](http://data.astrometry.net/) (also refer to `build.sh`). Map the saved path to the container by referring to `docker-compose.yaml`.
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
```python
python3 manage.py shell <<< "from django.core.management import utils; print(utils.get_random_secret_key())"
# add to .env file
```

`.env` file
```bash
SECRET_KEY = 'your django secret key goes here'

DEBUG = True

DATA_PATH = /opt/stdweb/data/
TASKS_PATH = /opt/stdweb/tasks/

STDPIPE_HOTPANTS=/usr/local/bin/hotpants
STDPIPE_SOLVE_FIELD=/usr/local/astrometry/bin/solve-field
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
mv /opt/stdweb/stdweb/settings.py /opt/stdweb/stdweb/settings.py.bak
cd /opt/stdweb && git pull && pip install -r requirements.txt
```
