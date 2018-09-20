#!/usr/bin/env bash

if [ "$EXTRA_PIP_PACKAGES" ]; then
    echo "EXTRA_PIP_PACKAGES environment variable found.  Installing".
    /venv/bin/pip install $EXTRA_PIP_PACKAGES
fi
/venv/bin/jupyter notebook --config=/app/config/jupyter-config.py /app &
/venv/bin/jupyter lab --port=8889 --config=/app/config/jupyter-config.py /app &
wait
