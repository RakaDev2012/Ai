import argparse
import random
from pathlib import Path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--source', default='data.txt')
    ap.add_argument('--out', default='data_3000.txt')
    ap.add_argument('--count', type=int, default=3000)
    ap.add_argument('--seed', type=int, default=42)
    args = ap.parse_args()
    blocks = [b.strip() for b in Path(args.source).read_text(encoding='utf-8').split('\n\n') if b.strip()]
    rng = random.Random(args.seed)
    rng.shuffle(blocks)
    selected = blocks[:args.count]
    Path(args.out).write_text('\n\n'.join(selected) + '\n', encoding='utf-8')
    print(f'written={args.out} dialogs={len(selected)} bytes={Path(args.out).stat().st_size}')

if __name__ == '__main__':
    main()
