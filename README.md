# STDWeb

STDWeb - web version of [STDPipe](https://github.com/karpov-sv/stdpipe) (Docker)

## Step 0

- Download index files from http://data.astrometry.net/
- Map saved path to container, see `docker-compose.yaml`
- `docker-compose up -d`

## Step 1
```python
python3 manage.py shell
from django.core.management import utils
utils.get_random_secret_key() # edit .env file
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
./start.sh
```
