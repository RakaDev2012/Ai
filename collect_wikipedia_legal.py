import argparse
import json
import time
import urllib.parse
import urllib.request
from pathlib import Path


def api(params):
    q = urllib.parse.urlencode({'format': 'json', 'origin': '*', **params})
    req = urllib.request.Request('https://id.wikipedia.org/w/api.php?' + q, headers={'User-Agent': 'AksaraAI-dataset-collector/1.0'})
    with urllib.request.urlopen(req, timeout=20) as r:
        return json.load(r)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--count', type=int, default=500)
    ap.add_argument('--out', default='data_wikipedia_id.txt')
    args = ap.parse_args()
    rows, cont = [], {}
    while len(rows) < args.count:
        data = api({'action': 'query', 'generator': 'random', 'grnnamespace': 0, 'grnlimit': min(20, args.count-len(rows)), 'prop': 'extracts|info', 'explaintext': 1, 'exchars': 2500, 'inprop': 'url', **cont})
        for page in data.get('query', {}).get('pages', {}).values():
            text = ' '.join(page.get('extract', '').split())
            if len(text) >= 120:
                title = page.get('title', '')
                url = page.get('fullurl', 'https://id.wikipedia.org/wiki/' + urllib.parse.quote(title.replace(' ', '_')))
                rows.append(f'Sumber Wikipedia: {title}\nURL: {url}\n{text}')
        cont = data.get('continue', {})
        if not cont:
            break
        time.sleep(0.2)
    Path(args.out).write_text('\n\n'.join(rows[:args.count]), encoding='utf-8')
    Path(args.out + '.license.json').write_text(json.dumps({'source': 'https://id.wikipedia.org/', 'license': 'CC BY-SA 4.0', 'attribution': 'Wikipedia Bahasa Indonesia / Wikimedia Foundation', 'count': len(rows[:args.count])}, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'written={args.out} pages={len(rows[:args.count])} bytes={Path(args.out).stat().st_size}')

if __name__ == '__main__':
    main()
