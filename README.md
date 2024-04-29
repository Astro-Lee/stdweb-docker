# STDWeb

STDWeb - web version of [STDPipe](https://github.com/karpov-sv/stdpipe) (Docker)

## Step 0

- Download index files from http://data.astrometry.net/
- Map save path to container, see 'docker-compose.yaml'
- 'docker-compose up -d'

## Step 1
```python
python3 manage.py shell
from django.core.management import utils
utils.get random secret key() # edit .env
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
## Step 2
```bash
#edit stdweb/settings.py
CSRF_TRUSTED_ORIGINS = [ 'https://example.domain.com', ] # reverse proxy 
```

## Step 3
```bash
./run_celery.sh &
python manage.py runserver 0.0.0.0:8000
```
