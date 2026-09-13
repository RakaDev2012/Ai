import argparse
import json
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--source-dir', required=True)
    ap.add_argument('--out', default='data_indonlg.txt')
    ap.add_argument('--max-per-file', type=int, default=6000)
    args = ap.parse_args()
    rows = []
    for path in sorted(Path(args.source_dir).glob('*/train_preprocess.json')):
        records = json.loads(path.read_text(encoding='utf-8'))
        for item in records[:args.max_per_file]:
            source = ' '.join(str(item.get('text', '')).split())
            target = ' '.join(str(item.get('label', '')).split())
            if len(source) >= 20 and len(target) >= 20:
                rows.append(f'Pengguna: Tolong jelaskan atau terjemahkan teks berikut.\n{source}\nAsisten: {target}\n')
    Path(args.out).write_text('\n'.join(rows), encoding='utf-8')
    print(f'written={args.out} dialogs={len(rows)} bytes={Path(args.out).stat().st_size}')

if __name__ == '__main__':
    main()
