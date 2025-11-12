#!/usr/bin/env bash
set -e

# 启动 JupyterLab（后台运行）
/opt/conda3/bin/jupyter-lab \
  --notebook-dir=/opt/notebooks \
  --ip=0.0.0.0 \
  --port=8888 \
  --no-browser \
  --allow-root > jupyter.log 2>&1 &

# 启动 Celery（后台运行）
/opt/conda3/bin/watchmedo auto-restart \
  -d stdweb -p '*.py' --ignore-patterns='*/.*' \
  -- /opt/conda3/bin/python -m celery --broker=redis://redis:6379/ -A stdweb worker --loglevel=info > watchmedo.log 2>&1 &

# 启动 Django（前台运行）
/opt/conda3/bin/python manage.py runserver 0.0.0.0:8000
