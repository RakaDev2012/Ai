import argparse
import json
import time
import urllib.parse
import urllib.request
from pathlib import Path

API = 'https://id.wikipedia.org/w/api.php'


def get_json(params):
    url = API + '?' + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={'User-Agent': 'AksaraAI-dataset-builder/1.0'})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--count', type=int, default=3000)
    ap.add_argument('--out', default='web_snippets.txt')
    ap.add_argument('--seed', type=int, default=42)
    args = ap.parse_args()
    rows, seen = [], set()
    # Wikipedia API random pages provide varied, publicly documented text.
    continue_token = None
    while len(rows) < args.count:
        params = {
            'action': 'query', 'format': 'json', 'generator': 'random',
            'grnnamespace': 0, 'grnlimit': min(20, args.count - len(rows)),
            'prop': 'extracts|info', 'exintro': 1, 'explaintext': 1,
            'inprop': 'url', 'redirects': 1
        }
        if continue_token:
            params.update(continue_token)
        payload = get_json(params)
        pages = payload.get('query', {}).get('pages', {})
        for page in pages.values():
            title = (page.get('title') or '').strip()
            extract = ' '.join((page.get('extract') or '').split())
            url = page.get('fullurl') or f'https://id.wikipedia.org/wiki/{urllib.parse.quote(title.replace(" ", "_"))}'
            if not title or not extract or title in seen or len(extract) < 80:
                continue
            seen.add(title)
            extract = extract[:1200].rstrip()
            rows.append(f'Pengetahuan: {extract}\nSumber: {title} — {url}\n')
            if len(rows) >= args.count:
                break
        continue_token = payload.get('continue')
        if not continue_token:
            break
        time.sleep(0.15)
    Path(args.out).write_text('\n'.join(rows), encoding='utf-8')
    Path(args.out + '.license.json').write_text(json.dumps({
        'source': 'Wikipedia Bahasa Indonesia',
        'source_url': 'https://id.wikipedia.org/',
        'api': API,
        'license': 'CC BY-SA 4.0 / Wikimedia terms; preserve attribution and share-alike',
        'count': len(rows),
        'note': 'Review article-level licensing and remove unsuitable content before production training.'
    }, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'written={args.out} snippets={len(rows)} bytes={Path(args.out).stat().st_size}')


if __name__ == '__main__':
    main()
