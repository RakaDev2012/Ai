"""Export the trainable TinyDiT weights to GGUF as a portable tensor container.
This is intentionally a custom 't2i-diffusion' GGUF architecture; llama.cpp cannot execute it.
"""
import argparse, json
from pathlib import Path
import torch
from gguf import GGUFWriter, GGMLQuantizationType

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--model',default='artifacts/fine-t2i-dit/model.pt'); ap.add_argument('--out',default='artifacts/fine-t2i-dit.gguf'); ap.add_argument('--quant',choices=['f16','q8_0'],default='f16'); args=ap.parse_args()
    ck=torch.load(args.model,map_location='cpu'); w=GGUFWriter(args.out,'t2i-diffusion'); c=ck['config']; w.add_string('general.architecture','t2i-diffusion'); w.add_string('general.name','FineT2I-TinyDiT-300M'); w.add_string('general.description','Custom latent diffusion transformer trained with ma-xu/fine-t2i'); w.add_string('t2i.dataset','ma-xu/fine-t2i'); w.add_string('t2i.config',json.dumps(c)); w.add_uint64('t2i.trainable_parameters',sum(v.numel() for v in ck['model'].values()))
    q=GGMLQuantizationType.F16 if args.quant=='f16' else GGMLQuantizationType.Q8_0
    for name,t in ck['model'].items(): w.add_tensor(name,t.detach().numpy(),raw_dtype=q)
    w.write_header_to_file(); w.write_kv_data_to_file(); w.write_tensors_to_file(); w.close(); print('GGUF tersimpan:',Path(args.out).resolve())
if __name__=='__main__': main()
