# AksaraAI — Model Bahasa Kecil dari Nol ke GGUF

AksaraAI adalah proyek eksperimen **model bahasa yang dilatih dari nol**, tanpa bobot model pralatih. Proyek ini menggunakan transformer bergaya GPT-2, tokenizer BPE lokal, dan dapat dikonversi ke format `.gguf` untuk dijalankan dengan llama.cpp. Konfigurasi default sekarang menargetkan sekitar **300 juta parameter**.

> Model contoh yang dihasilkan dari korpus mini hanya untuk demonstrasi pipeline. Untuk kemampuan percakapan yang baik, gunakan korpus Bahasa Indonesia yang lebih besar dan legal.

## Kebutuhan

- Python 3.10+
- PyTorch
- `transformers`, `tokenizers`, `safetensors`
- `git`, untuk mengambil `llama.cpp` saat konversi

Instal dependensi:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## 1. Latih dari nol

```bash
python train.py --steps 10000 --batch-size 2 --block-size 512
```

Semua parameter model dibuat baru secara acak. Tidak ada `from_pretrained()` dan tidak ada unduhan bobot.

Output berada di `artifacts/aksaraai-hf/`.

Uji generasi langsung dari checkpoint:

```bash
python generate.py --prompt "Halo, nama saya" --max-new-tokens 80
```

## 2. Konversi ke GGUF

```bash
python convert_to_gguf.py --quant q8_0
```

Hasilnya berada di `artifacts/aksaraai-q8_0.gguf`. Untuk tanpa kuantisasi gunakan `--quant f16`.

## 3. Jalankan dengan llama.cpp

```bash
./llama.cpp/build/bin/llama-cli -m artifacts/aksaraai-q8_0.gguf -p "Halo, nama saya" -n 80 --temp 0.8
```

## Catatan penting

- Model 300M membutuhkan RAM/VRAM dan waktu training jauh lebih besar daripada model demo sebelumnya.
- Kualitas model ditentukan terutama oleh ukuran dan kebersihan data.
- Jangan memasukkan data pribadi, rahasia, atau materi berhak cipta tanpa izin.
- GGUF adalah format distribusi/inferensi; pelatihan tetap berlangsung pada checkpoint PyTorch.

## Lisensi

Kode dan korpus contoh dirilis sebagai MIT.
