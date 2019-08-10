This repository contains some scripts for running experiments with fairseq on
CodaLab.

The main entry point is `run.rb`, which can run things both locally (pass
`@cl=0`) and on CodaLab (pass `@cl=1`).  Note: pass `-n` to print out the
command that will be executed.

Upload things to CodaLab:

    cl up fairseq --exclude .git fairseq.gif
    cl up scripts

Generate datasets and train models:

    # Create the iwslt14 dataset
    cl run :fairseq 'bash fairseq/examples/translation/prepare-iwslt14.sh' -n prepare-iwslt14
    cl make train.src:prepare-iwslt14/iwslt14.tokenized.de-en/train.de train.tgt:prepare-iwslt14/iwslt14.tokenized.de-en/train.en valid.src:prepare-iwslt14/iwslt14.tokenized.de-en/valid.de valid.tgt:prepare-iwslt14/iwslt14.tokenized.de-en/valid.en test.src:prepare-iwslt14/iwslt14.tokenized.de-en/test.de test.tgt:prepare-iwslt14/iwslt14.tokenized.de-en/test.en -n iwslt14-de-en

    # Create synthetic dataset
    ./run.rb @cl=1 @m=data @data=data2

    # Train a model on that dataset
    ./run.rb @cl=1 @m=train @data=data2
