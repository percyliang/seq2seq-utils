import argparse
import os
import json

def correct_str(b):
    return 'OK' if b else 'WRONG'

def read_jsonl(path, max_items=None):
    items = [json.loads(line) for line in open(path) if line.strip() != '']
    if max_items is not None:
        items = items[:max_items]
    print('Read {} items from {}'.format(len(items), path))
    return items

parser = argparse.ArgumentParser()
parser.add_argument('-p', '--prediction-files', nargs='+', help='jsonl files that hold the predictions')
parser.add_argument('-o', '--output-dir', help='Directory to output the visualization', default='.')
args = parser.parse_args()

if not os.path.exists(args.output_dir):
    os.path.mkdir(args.output_dir)

for prediction_file in args.prediction_files:
    predictions = read_jsonl(prediction_file)
    with open(os.path.join(args.output_dir, 'predictions.txt'), 'w') as f:
        for prediction in predictions:
            print('SRC: {}'.format(prediction['source_str']), file=f)
            print('TGT: {}'.format(prediction['target_str']), file=f)
            for hypo in prediction['hypotheses']:
                print('HYP: {} [{}]'.format(hypo['str'], correct_str(hypo['exact_match'])), file=f)
                break
            print('', file=f)
