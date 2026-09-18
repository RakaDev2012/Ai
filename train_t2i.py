import argparse, json, math, random
from pathlib import Path
import torch
from torch.utils.data import IterableDataset, DataLoader
from torchvision import transforms
from datasets import load_dataset
from transformers import CLIPTokenizer, CLIPTextModel
from diffusers import AutoencoderKL
from tqdm import tqdm
from model import TinyDiT, DiTConfig, count_parameters

class FineT2I(IterableDataset):
    def __init__(self, subset, image_size, max_samples=None):
        self.subset, self.image_size, self.max_samples = subset, image_size, max_samples
        self.tf = transforms.Compose([transforms.Resize((image_size,image_size)), transforms.ToTensor(), transforms.Normalize([.5]*3,[.5]*3)])
    def __iter__(self):
        pattern=f'https://huggingface.co/datasets/ma-xu/fine-t2i/resolve/main/{self.subset}/train-*.tar'
        ds=load_dataset('webdataset', data_files={'train':pattern}, split='train', streaming=True)
        for i, x in enumerate(ds):
            if self.max_samples and i >= self.max_samples: break
            try: yield self.tf(x['jpg'].convert('RGB')), x['txt']
            except Exception: continue

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--subset',default='synthetic_enhanced_prompt_square_resolution'); ap.add_argument('--out',default='artifacts/rkimage1'); ap.add_argument('--steps',type=int,default=10000); ap.add_argument('--batch-size',type=int,default=2); ap.add_argument('--image-size',type=int,default=256); ap.add_argument('--max-samples',type=int); ap.add_argument('--lr',type=float,default=1e-4); ap.add_argument('--grad-accum',type=int,default=1); ap.add_argument('--vae',default='stabilityai/sd-vae-ft-mse'); ap.add_argument('--text-model',default='openai/clip-vit-large-patch14'); ap.add_argument('--seed',type=int,default=42); args=ap.parse_args()
    random.seed(args.seed); torch.manual_seed(args.seed); out=Path(args.out); out.mkdir(parents=True,exist_ok=True); device='cuda' if torch.cuda.is_available() else 'cpu'
    tok=CLIPTokenizer.from_pretrained(args.text_model); text=CLIPTextModel.from_pretrained(args.text_model).to(device).eval(); vae=AutoencoderKL.from_pretrained(args.vae).to(device).eval()
    for m in (text,vae):
        for p in m.parameters(): p.requires_grad=False
    cfg=DiTConfig(latent_size=args.image_size//8); model=TinyDiT(cfg).to(device); print('trainable:',count_parameters(model), 'device:',device)
    opt=torch.optim.AdamW(model.parameters(),lr=args.lr,weight_decay=.01); data=DataLoader(FineT2I(args.subset,args.image_size,args.max_samples),batch_size=args.batch_size)
    it=iter(data); model.train(); opt.zero_grad(set_to_none=True)
    for step in range(1,args.steps+1):
        try: imgs,caps=next(it)
        except StopIteration: it=iter(data); imgs,caps=next(it)
        imgs=imgs.to(device); ids=tok(list(caps),padding='max_length',truncation=True,max_length=77,return_tensors='pt').to(device)
        with torch.no_grad(): z=vae.encode(imgs).latent_dist.sample()*vae.config.scaling_factor; h=text(input_ids=ids.input_ids,attention_mask=ids.attention_mask).last_hidden_state
        noise=torch.randn_like(z); t=torch.rand(z.size(0),device=device); a=torch.cos(t*math.pi/2)[:,None,None,None]; b=torch.sin(t*math.pi/2)[:,None,None,None]; noisy=a*z+b*noise; target=a*noise-b*z
        loss=torch.nn.functional.mse_loss(model(noisy,t,h),target)/args.grad_accum; loss.backward()
        if step%args.grad_accum==0: torch.nn.utils.clip_grad_norm_(model.parameters(),1); opt.step(); opt.zero_grad(set_to_none=True)
        if step==1 or step%50==0: print(f'step={step}/{args.steps} loss={loss.item()*args.grad_accum:.5f}',flush=True)
        if step%1000==0: torch.save({'model':model.state_dict(),'config':cfg.__dict__,'step':step},out/f'checkpoint-{step}.pt')
    torch.save({'model':model.state_dict(),'config':cfg.__dict__,'step':args.steps,'model_name':'Rkimage 1'},out/'model.pt'); (out/'training_info.json').write_text(json.dumps({'model_name':'Rkimage 1','dataset':'ma-xu/fine-t2i','subset':args.subset,'steps':args.steps,'parameters':count_parameters(model),'architecture':'TinyDiT latent diffusion transformer'},indent=2)); print('saved',out)
if __name__=='__main__': main()
