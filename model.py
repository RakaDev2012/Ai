"""Compact text-conditioned latent diffusion transformer (~300M trainable params)."""
from dataclasses import dataclass
import math
import torch
from torch import nn

@dataclass
class DiTConfig:
    latent_channels: int = 4
    latent_size: int = 32
    text_dim: int = 768
    hidden: int = 1024
    depth: int = 20
    heads: int = 16
    patch: int = 2
    max_text_tokens: int = 77

class AdaLN(nn.Module):
    def __init__(self, dim):
        super().__init__(); self.norm = nn.LayerNorm(dim, elementwise_affine=False); self.mod = nn.Linear(dim, dim * 6)
    def forward(self, x, c):
        shift, scale, gate, shift2, scale2, gate2 = self.mod(c).chunk(6, dim=-1)
        return self.norm(x) * (1 + scale[:, None]) + shift[:, None], gate[:, None], shift2[:, None], scale2[:, None], gate2[:, None]

class Block(nn.Module):
    def __init__(self, cfg):
        super().__init__(); d = cfg.hidden
        self.attn = nn.MultiheadAttention(d, cfg.heads, batch_first=True)
        self.n1 = AdaLN(d); self.n2 = nn.LayerNorm(d); self.ff = nn.Sequential(nn.Linear(d, d*4), nn.GELU(), nn.Linear(d*4, d))
    def forward(self, x, cond):
        h, gate, shift2, scale2, gate2 = self.n1(x, cond)
        h = self.attn(h, h, h, need_weights=False)[0]
        x = x + gate * h
        h = self.n2(x) * (1 + scale2[:, None]) + shift2[:, None]
        return x + gate2 * self.ff(h)

class TinyDiT(nn.Module):
    def __init__(self, cfg=DiTConfig()):
        super().__init__(); self.cfg = cfg; p = cfg.patch; n = (cfg.latent_size // p) ** 2
        self.patch = nn.Conv2d(cfg.latent_channels, cfg.hidden, p, p)
        self.pos = nn.Parameter(torch.randn(1, n, cfg.hidden) * .02)
        self.text_proj = nn.Linear(cfg.text_dim, cfg.hidden)
        self.time = nn.Sequential(nn.Linear(cfg.hidden, cfg.hidden*4), nn.SiLU(), nn.Linear(cfg.hidden*4, cfg.hidden))
        self.blocks = nn.ModuleList([Block(cfg) for _ in range(cfg.depth)])
        self.out = nn.Sequential(nn.LayerNorm(cfg.hidden), nn.Linear(cfg.hidden, p*p*cfg.latent_channels))
    def timestep(self, t):
        half = self.cfg.hidden // 2; freqs = torch.exp(-math.log(10000) * torch.arange(half, device=t.device) / half)
        a = t[:, None] * freqs[None]; return torch.cat([a.sin(), a.cos()], -1)
    def forward(self, z, t, text_hidden):
        b = z.shape[0]; x = self.patch(z).flatten(2).transpose(1, 2) + self.pos
        cond = self.time(self.timestep(t)) + self.text_proj(text_hidden.mean(1))
        for block in self.blocks: x = block(x, cond)
        x = self.out(x); p = self.cfg.patch; s = self.cfg.latent_size // p
        return x.transpose(1,2).reshape(b, self.cfg.latent_channels*p*p, s, s).reshape(b, self.cfg.latent_channels, self.cfg.latent_size, self.cfg.latent_size)

def count_parameters(model): return sum(p.numel() for p in model.parameters())

if __name__ == '__main__':
    m = TinyDiT(); print(f'{count_parameters(m):,} trainable parameters')
