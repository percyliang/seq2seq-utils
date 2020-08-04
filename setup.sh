#!/bin/bash

if [ ! -e venv ]; then
  virtualenv -p python3.7 venv || exit 1
  venv/bin/pip install -r requirements.txt || exit 1
fi

if [ ! -e fairseq ]; then
  git clone https://github.com/percyliang/fairseq
fi
