import argparse
import subprocess
from pathlib import Path

ap = argparse.ArgumentParser()
ap.add_argument('--model', default='artifacts/aksaraai-hf')
ap.add_argument('--out', default='artifacts/aksaraai')
ap.add_argument('--quant', choices=['f16', 'q8_0', 'q4_k_m'], default='q8_0')
args = ap.parse_args()

root = Path(__file__).parent
llama = root / 'llama.cpp'
if not llama.exists():
    subprocess.run(['git', 'clone', '--depth', '1', 'https://github.com/ggerganov/llama.cpp.git', str(llama)], check=True)
converter = llama / 'convert_hf_to_gguf.py'
if not converter.exists():
    raise SystemExit('Konverter llama.cpp tidak ditemukan; update clone llama.cpp lalu coba lagi.')
base = Path(args.out)
base.parent.mkdir(parents=True, exist_ok=True)
f16 = base.with_name(base.name + '-f16.gguf')
subprocess.run(['python', str(converter), args.model, '--outfile', str(f16), '--outtype', 'f16'], check=True)
if args.quant == 'f16':
    print(f'GGUF tersimpan: {f16}')
    raise SystemExit(0)
quant_bin = llama / 'build' / 'bin' / 'llama-quantize'
if not quant_bin.exists():
    raise SystemExit(f'Build llama.cpp terlebih dahulu agar tersedia: {quant_bin}')
final = base.with_name(base.name + f'-{args.quant}.gguf')
subprocess.run([str(quant_bin), str(f16), str(final), args.quant.upper()], check=True)
print(f'GGUF tersimpan: {final}')
