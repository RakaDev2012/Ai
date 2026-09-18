# Rkimage 1 — Text-to-Image sekitar 300M ke GGUF

**Rkimage 1** adalah implementasi **text-to-image latent diffusion transformer** yang dilatih dari awal pada pasangan gambar-teks [Fine-T2I](https://huggingface.co/datasets/ma-xu/fine-t2i). Dataset tersebut berformat WebDataset dan sangat besar (sekitar 2 TB), sehingga loader menggunakan **streaming** dan tidak mengunduh seluruh dataset.

> **Penting:** GGUF di proyek ini adalah wadah tensor untuk arsitektur `t2i-diffusion` kustom. Ia bukan model bahasa GGUF dan tidak dapat dijalankan langsung oleh `llama.cpp`. Inferensi dilakukan oleh `sample_t2i.py`, yang memuat tensor GGUF/checkpoint bersama VAE dan CLIP text encoder.

## Arsitektur

Model yang dilatih adalah DiT kecil pada ruang laten: 20 transformer blocks, hidden size 1024, 16 attention heads, patch size 2, dan latent 32×32 untuk gambar 256×256. VAE `stabilityai/sd-vae-ft-mse` dan CLIP `openai/clip-vit-large-patch14` dibekukan; hanya TinyDiT yang dilatih. Jumlah parameter trainable diperiksa saat startup dan dicatat di `training_info.json`.

VAE dan CLIP adalah komponen runtime terpisah. Karena itu, ukuran “sekitar 300M” merujuk pada bobot TinyDiT, bukan total seluruh pipeline. Model generatif dari nol pada skala ini membutuhkan GPU dan data/training yang besar; konfigurasi default dimaksudkan sebagai baseline reproducible, bukan jaminan kualitas setara model komersial.

## Instalasi

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Training streaming

Contoh berikut memakai subset prompt enhanced berbentuk square. Pilih subset lain bila diperlukan: `synthetic_enhanced_prompt_random_resolution`, `synthetic_original_prompt_square_resolution`, `synthetic_original_prompt_random_resolution`, atau `curated`.

```bash
python train_t2i.py \
  --subset synthetic_enhanced_prompt_square_resolution \
  --out artifacts/rkimage1 \
  --steps 10000 \
  --batch-size 2 \
  --image-size 256 \
  --grad-accum 8
```

Untuk smoke test tanpa memproses banyak contoh:

```bash
python train_t2i.py --steps 2 --batch-size 1 --max-samples 8 --image-size 256
```

Training memerlukan akses internet ke Hugging Face dan pertama kali akan mengunduh VAE/CLIP. Hindari mode non-streaming karena dataset penuh berukuran sekitar 2 TB.

## Sampling

```bash
python sample_t2i.py \
  --model artifacts/rkimage1/model.pt \
  --prompt "a cinematic photograph of a red bicycle beside a quiet lake at sunrise" \
  --out sample.png \
  --steps 30
```

## Ekspor ke GGUF

```bash
python convert_t2i_gguf.py \
  --model artifacts/rkimage1/model.pt \
  --out artifacts/Rkimage-1-f16.gguf \
  --quant f16
```

Perintah ringkas:

```bash
python convert_t2i_gguf.py --model artifacts/rkimage1/model.pt --out artifacts/Rkimage-1-f16.gguf --quant f16
```

Jika ingin mengurangi ukuran bobot, gunakan `--quant q8_0`. File GGUF menyimpan metadata arsitektur, konfigurasi, asal dataset, jumlah parameter, serta seluruh tensor TinyDiT. VAE dan CLIP tetap didownload/dimuat terpisah saat sampling.

## Dataset dan lisensi

Fine-T2I memiliki lisensi Apache-2.0 menurut kartu datasetnya dan menyediakan file `jpg`, `txt`, serta `json`. Sertakan atribusi dataset dan sitasi paper ketika mendistribusikan model turunan. Jangan mengklaim bahwa model ini menggunakan seluruh 6 juta pasangan bila training hanya dijalankan untuk sejumlah langkah atau satu subset.

Sitasi:

```bibtex
@misc{ma2026finet2i,
  title={Fine-T2I: An Open, Large-Scale, and Diverse Dataset for High-Quality T2I Fine-Tuning},
  author={Xu Ma and Yitian Zhang and Qihua Dong and Yun Fu},
  year={2026}, eprint={2602.09439}, archivePrefix={arXiv}
}
```

## Lisensi kode

Kode proyek ini mengikuti lisensi MIT dari repositori asal, sedangkan kewajiban distribusi data/model turunan harus mengikuti lisensi dataset dan komponen runtime yang digunakan.
