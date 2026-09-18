import argparse
from pathlib import Path
import torch
from PIL import Image
from transformers import CLIPTokenizer, CLIPTextModel
from diffusers import AutoencoderKL
from model import TinyDiT, DiTConfig

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--model',default='artifacts/rkimage1/model.pt'); ap.add_argument('--prompt',required=True); ap.add_argument('--out',default='rkimage1-sample.png'); ap.add_argument('--steps',type=int,default=30); ap.add_argument('--seed',type=int,default=42); ap.add_argument('--size',type=int,default=256); ap.add_argument('--vae',default='stabilityai/sd-vae-ft-mse'); ap.add_argument('--text-model',default='openai/clip-vit-large-patch14'); args=ap.parse_args()
    device='cuda' if torch.cuda.is_available() else 'cpu'; ck=torch.load(args.model,map_location=device); cfg=DiTConfig(**ck['config']); model=TinyDiT(cfg).to(device); model.load_state_dict(ck['model']); model.eval()
    tok=CLIPTokenizer.from_pretrained(args.text_model); enc=CLIPTextModel.from_pretrained(args.text_model).to(device).eval(); vae=AutoencoderKL.from_pretrained(args.vae).to(device).eval()
    ids=tok([args.prompt],padding='max_length',truncation=True,max_length=77,return_tensors='pt').to(device)
    with torch.no_grad(): h=enc(**ids).last_hidden_state; g=torch.Generator(device=device).manual_seed(args.seed); z=torch.randn((1,4,cfg.latent_size,cfg.latent_size),generator=g,device=device)
    # Rectified-flow Euler reverse path: t=1 (noise) -> 0 (data).
    with torch.no_grad():
        for t in torch.linspace(1,0,args.steps+1,device=device)[:-1]:
            tt=torch.full((1,),t,device=device); v=model(z,tt,h); dt=-1/args.steps; z=z+v*dt
        img=vae.decode(z/vae.config.scaling_factor).sample[0].clamp(-1,1); img=((img+1)*127.5).byte().permute(1,2,0).cpu().numpy(); Image.fromarray(img).save(args.out)
    print('saved',Path(args.out).resolve())
if __name__=='__main__': main()
