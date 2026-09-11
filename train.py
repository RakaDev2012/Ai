import argparse
import json
import math
import random
from pathlib import Path

import torch
from tokenizers import Tokenizer, decoders, models, pre_tokenizers, trainers
from transformers import GPT2Config, GPT2LMHeadModel, PreTrainedTokenizerFast


def build_tokenizer(text_path: Path, out_dir: Path):
    tokenizer = Tokenizer(models.BPE(unk_token="[UNK]"))
    tokenizer.pre_tokenizer = pre_tokenizers.ByteLevel(add_prefix_space=True, use_regex=True)
    tokenizer.decoder = decoders.ByteLevel()
    trainer = trainers.BpeTrainer(
        vocab_size=2048,
        min_frequency=1,
        special_tokens=["[PAD]", "[UNK]", "[BOS]", "[EOS]"],
    )
    tokenizer.train([str(text_path)], trainer)
    raw_path = out_dir / "tokenizer.json"
    tokenizer.save(str(raw_path))
    return PreTrainedTokenizerFast(
        tokenizer_file=str(raw_path),
        unk_token="[UNK]", pad_token="[PAD]", bos_token="[BOS]", eos_token="[EOS]"
    )


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", default="data.txt")
    ap.add_argument("--out", default="artifacts/aksaraai-hf")
    ap.add_argument("--steps", type=int, default=1200)
    ap.add_argument("--batch-size", type=int, default=8)
    ap.add_argument("--block-size", type=int, default=128)
    ap.add_argument("--lr", type=float, default=3e-4)
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()

    random.seed(args.seed)
    torch.manual_seed(args.seed)
    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    tokenizer = build_tokenizer(Path(args.data), out_dir)
    text = Path(args.data).read_text(encoding="utf-8")
    ids = tokenizer.encode(text, add_special_tokens=True)
    if len(ids) < args.block_size + 2:
        ids = (ids * ((args.block_size + 2) // len(ids) + 1))[: args.block_size + 2]
    device = "cuda" if torch.cuda.is_available() else "cpu"

    config = GPT2Config(
        vocab_size=tokenizer.vocab_size,
        n_positions=args.block_size,
        n_ctx=args.block_size,
        n_embd=256,
        n_layer=6,
        n_head=8,
        bos_token_id=tokenizer.bos_token_id,
        eos_token_id=tokenizer.eos_token_id,
        pad_token_id=tokenizer.pad_token_id,
    )
    model = GPT2LMHeadModel(config).to(device)
    model.train()
    optimizer = torch.optim.AdamW(model.parameters(), lr=args.lr, weight_decay=0.1)

    def batch():
        starts = torch.randint(0, len(ids) - args.block_size - 1, (args.batch_size,))
        x = torch.stack([torch.tensor(ids[s : s + args.block_size]) for s in starts])
        y = torch.stack([torch.tensor(ids[s + 1 : s + args.block_size + 1]) for s in starts])
        return x.to(device), y.to(device)

    for step in range(1, args.steps + 1):
        x, y = batch()
        loss = model(input_ids=x, labels=y).loss
        loss.backward()
        torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
        optimizer.step(); optimizer.zero_grad(set_to_none=True)
        if step == 1 or step % 100 == 0:
            print(f"step={step}/{args.steps} loss={loss.item():.4f} ppl={math.exp(min(loss.item(), 20)):.2f}")

    model.save_pretrained(out_dir, safe_serialization=True)
    tokenizer.save_pretrained(out_dir)
    (out_dir / "training_info.json").write_text(json.dumps({"from_scratch": True, "steps": args.steps, "seed": args.seed}, indent=2), encoding="utf-8")
    print(f"saved: {out_dir.resolve()}")


if __name__ == "__main__":
    main()
