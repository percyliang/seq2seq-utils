#!/usr/bin/ruby

if not File.exists?('fig')
  system 'git clone https://github.com/percyliang/fig'
end

if not File.exists?('fairseq')
  system 'git clone https://github.com/percyliang/fairseq'
end

$: << 'fig/lib'
require 'execrunner'
$optPrefix = '--'

def create_synthetic_data
  l(
    sel(:cl,
      l(),
      l(
        'cl', 'run', '-n', env(:data),
        ':scripts', '---',
      nil),
    nil),
    'python3.6', 'scripts/create_synthetic_data.py',
    sel(:data, {
      'data1' => l(o('length', 10), o('vocab-size', 5), o('num-train-examples', 100)),
      'data2' => l(o('length', 30), o('vocab-size', 100), o('num-train-examples', 1000)),
      'data2-1' => l(o('length', 30), o('vocab-size', 100), o('num-train-examples', 1000), o('test-length-factor', 2)),  # longer sequences
      'data2-2' => l(o('length', 50), o('vocab-size', 100), o('num-train-examples', 1000), o('test-length-factor', 2)),  # longer sequences
      'data2-r' => l(o('length', 30), o('vocab-size', 100), o('num-train-examples', 1000), o('source-repeat-stop-prob', 0.5)),  # repeat
      'data2-n' => l(o('length', 30), o('vocab-size', 100), o('num-train-examples', 1000), o('source-noise-prob', 0.5)),  # noise
      'data2-s' => l(o('length', 30), o('vocab-size', 100), o('num-train-examples', 1000), o('source-synonymy', 5)),  # synonymy
    }),
    selo(:cl, 'out-dir', env(:data), '.'),
  nil)
end

def subsample_data
  l(
    sel(:cl,
      l(),
      l(
        'cl', 'run', '-n', env('$data-$frac'),
        ':scripts', env('data:$data'), '---',
      nil),
    nil),
    'python3.6', 'scripts/subsample_data.py',
    o('train-frac', env(:frac)),
    selo(:cl, 'input-dir', env('$data'), 'data'),
    selo(:cl, 'output-dir', env('$data-$frac'), '.'),
  nil)
end

def train
  l(
    sel(:cl,
      l(),
      l(
        'cl', 'run',
        o('request-gpus', 1),
        o('request-memory', '4g'),
        o('request-network'),
        ':fairseq', ':scripts',
        env('data:$data'),
        '---',
        'bash', 'scripts/init.sh', '&&',
      nil),
    nil),
    'bash', 'scripts/train.sh',
    selo(0, 'arch', 'fconv_iwslt_de_en', 'fconv', 'lstm', 'transformer'),
    o('lr', 0.25), o('clip-norm', 0.1), o('dropout', 0.2),
    o('max-epoch', 30),
    o('seed', 1),
  nil)
end

run!(
  sel(:m, {
    'data' => create_synthetic_data,
    'subsample' => subsample_data,
    'train' => train,
  }),
nil)
