#!/bin/bash

# Specifies a list of CodaLab bundle uuids to download.
for uuid in "$@"; do
  cl down $uuid/tensorboard -o codalab-tensorboard/$uuid-tensorboard
done
