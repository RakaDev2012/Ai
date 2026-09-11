import argparse
import torch
from transformers import GPT2LMHeadModel, PreTrainedTokenizerFast

ap = argparse.ArgumentParser()
ap.add_argument('--model', default='artifacts/aksaraai-hf')
ap.add_argument('--prompt', default='Halo, nama saya')
ap.add_argument('--max-new-tokens', type=int, default=80)
ap.add_argument('--temperature', type=float, default=0.8)
args = ap.parse_args()

device = 'cuda' if torch.cuda.is_available() else 'cpu'
tok = PreTrainedTokenizerFast.from_pretrained(args.model)
model = GPT2LMHeadModel.from_pretrained(args.model).to(device).eval()
inputs = tok(args.prompt, return_tensors='pt').to(device)
with torch.no_grad():
    output = model.generate(**inputs, max_new_tokens=args.max_new_tokens, do_sample=True, temperature=args.temperature, top_k=40, pad_token_id=tok.pad_token_id)
print(tok.decode(output[0], skip_special_tokens=True))
