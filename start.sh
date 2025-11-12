#!/usr/bin/env bash
set -e

#nohup /opt/miniconda3/bin/jupyter-lab --notebook-dir=/opt/notebooks --ip='*' --port=8888 --no-browser --allow-root &

/opt/miniconda3/bin/watchmedo auto-restart -d stdweb -p '*.py' --ignore-patterns='*/.*' -- /opt/miniconda3/bin/python -m celery --broker=redis://redis:6379/ -A stdweb worker --loglevel=info > watchmedo.log 2>&1 &

/opt/miniconda3/bin/python manage.py runserver 0.0.0.0:8000
