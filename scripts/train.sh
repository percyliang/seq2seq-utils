#!/bin/bash

# Based on https://fairseq.readthedocs.io/en/latest/getting_started.html#training-a-new-model

echo ============= Preprocessing
rm -rf preprocessed  # For running locally
time python3.6 fairseq/preprocess.py --source-lang src --target-lang tgt --trainpref data/train --validpref data/valid --testpref data/test --destdir preprocessed || exit 1

echo ============= Training
time python3.6 fairseq/train.py preprocessed \
  --lr 0.25 --clip-norm 0.1 --dropout 0.2 --max-tokens 4000 --max-epoch 30 --arch fconv_iwslt_de_en \
  --save-dir . --tensorboard-logdir tensorboard --no-epoch-checkpoints --seed 1 \
  "$@" || exit 1

echo ============= Predicting
time python3.6 fairseq/generate.py preprocessed --path checkpoint_best.pt --batch-size 128 --beam 5 --nbest 5 --sacrebleu
