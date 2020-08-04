#!/usr/bin/env python

from argcomb import *

def create_synthetic_data():
    return [
        sel('@cl', [], ['cl', 'run', '-n', fmt('@data'), ':scripts', '---']),
        'python3.6', 'scripts/create_synthetic_data.py',
        sel('@data', {
            'data1': [arg('length', 10), arg('vocab-size', 5), arg('num-train-examples', 100)],
            'data2': [arg('length', 30), arg('vocab-size', 100), arg('num-train-examples', 1000)],
            'data2-1': [arg('length', 30), arg('vocab-size', 100), arg('num-train-examples', 1000), arg('test-length-factor', 2)],  # longer sequences
            'data2-2': [arg('length', 50), arg('vocab-size', 100), arg('num-train-examples', 1000), arg('test-length-factor', 2)],  # longer sequences
            'data2-r': [arg('length', 30), arg('vocab-size', 100), arg('num-train-examples', 1000), arg('source-repeat-stop-prob', 0.5)],  # repeat
            'data2-n': [arg('length', 30), arg('vocab-size', 100), arg('num-train-examples', 1000), arg('source-noise-prob', 0.5)],  # noise
            'data2-s': [arg('length', 30), arg('vocab-size', 100), arg('num-train-examples', 1000), arg('source-synonymy', 5)],  # synonymy
        }),
        selarg('@cl', 'out-dir', fmt('@data'), '.'),
    ]

def subsample_data():
    return [
        sel('@cl', [], ['cl', 'run', '-n', fmt('@data-@frac'), ':scripts', fmt('data:@data'), '---']),
        'python3.6', 'scripts/subsample_data.py',
        arg('train-frac', fmt('@frac')),
        selarg('@cl', 'input-dir', fmt('@data'), 'data'),
        selarg('@cl', 'output-dir', fmt('@data-@frac'), '.'),
    ]

def train():
    return [
        sel('@cl',
            [],
            [
                'cl', 'run',
                arg('request-gpus', 1),
                arg('request-memory', '4g'),
                arg('request-network'),
                ':fairseq', ':scripts',
                fmt('data:@data'),
                '---',
                'bash', 'scripts/init.sh', '&&',
            ],
        ),
        'bash', 'scripts/train.sh',
        selarg(0, 'arch', 'fconv_iwslt_de_en', 'fconv', 'lstm', 'transformer'),
        arg('lr', 0.25), arg('clip-norm', 0.1), arg('dropout', 0.2),
        arg('max-epoch', 30),
        arg('seed', 1),
    ]

run(
    sel('@mode', {
        'data': create_synthetic_data(),
        'subsample': subsample_data(),
        'train': train(),
    }),
)
