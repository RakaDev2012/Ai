from pathlib import Path
import ast

src = Path('train.py').read_text(encoding='utf-8')
tree = ast.parse(src)
values = {}
for node in ast.walk(tree):
    if isinstance(node, ast.keyword) and node.arg in {'vocab_size','n_positions','n_embd','n_layer','n_head'}:
        if isinstance(node.value, ast.Attribute) and node.value.attr == 'vocab_size':
            continue
        if isinstance(node.value, ast.Name):
            continue
        if isinstance(node.value, ast.Constant):
            values[node.arg] = node.value.value
vocab = 401
positions = 512
width = values['n_embd']
layers = values['n_layer']
# GPT-2 tied embeddings: token table + position table + transformer blocks + final LN.
per_block = 12 * width * width + 13 * width
params = vocab * width + positions * width + layers * per_block + 2 * width
print(f'approx parameters: {params:,} ({params/1e6:.3f}M)')
print(f'config: vocab={vocab}, positions={positions}, width={width}, layers={layers}, heads={values["n_head"]}')
