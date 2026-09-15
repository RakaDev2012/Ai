import argparse
import json
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--source-dir', required=True)
    ap.add_argument('--out', default='data_indotod.txt')
    args = ap.parse_args()
    rows = []
    for path in sorted(Path(args.source_dir).glob('**/IndoSMD_split/IndoSMD_*.json')):
        if 'bilingual' in str(path):
            continue
        data = json.loads(path.read_text(encoding='utf-8'))
        for dialogue in data:
            turns = dialogue.get('dialogue', [])
            text = []
            for turn in turns:
                role = turn.get('turn')
                utterance = turn.get('data', {}).get('utterance', '').strip()
                if not utterance:
                    continue
                label = 'Pengguna' if role == 'driver' else 'Asisten'
                text.append(f'{label}: {utterance}')
            if len(text) >= 2:
                rows.append('\n'.join(text))
    for path in sorted(Path(args.source_dir).glob('**/IndoCamRest676.json')):
        data = json.loads(path.read_text(encoding='utf-8'))
        for dialogue in data:
            text = []
            for turn in dialogue.get('dial', []):
                for key, label in [('usr', 'Pengguna'), ('sys', 'Asisten')]:
                    utterance = turn.get(key, {}).get('transcript', '').strip()
                    if utterance:
                        text.append(f'{label}: {utterance}')
            if len(text) >= 2:
                rows.append('\n'.join(text))
    Path(args.out).write_text('\n\n'.join(rows), encoding='utf-8')
    print(f'written={args.out} dialogs={len(rows)} bytes={Path(args.out).stat().st_size}')

if __name__ == '__main__':
    main()
