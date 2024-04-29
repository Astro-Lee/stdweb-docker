# STDWeb

STDWeb - web version of [STDPipe](https://github.com/karpov-sv/stdpipe) (Docker)

```python
python3 manage.py shell
from django.core.management import utils
utils.get random secret key() # edit .env
```

```bash
#edit stdweb/settings.py
CSRF_TRUSTED_ORIGINS = [ 'https://example.domain.com', ]
```