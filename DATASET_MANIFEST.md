# Manifest Dataset Bahasa Indonesia

Tanggal pencatatan: 2026-09-15.

## Dataset yang berhasil dikumpulkan

| Kategori | Sumber | Lisensi | Isi lokal | Status penggunaan |
|---|---|---|---:|---|
| NLG/QA | [IndoNLG](https://github.com/indobenchmark/indonlg) dan [kartu GEM](https://huggingface.co/datasets/GEM/indonlg) | Kartu GEM menyatakan MIT; ikuti dokumentasi sumber | 11.929 pasangan di `data_indonlg.txt` | Dipakai untuk data gabungan sebelumnya |
| Dialog | [IndoToD](https://github.com/dehanalkautsar/IndoToD) | Dataset CC BY-SA 4.0; kode Apache 2.0 | 999 dialog di `data_indotod.txt` | Siap dipakai untuk fine-tuning dengan atribusi |
| Wikipedia | [Wikipedia Bahasa Indonesia](https://id.wikipedia.org/) dan [IndoWiki](https://huggingface.co/datasets/sabilmakbar/indo_wiki) | CC BY-SA 4.0 / dataset card IndoWiki CC BY-SA 3.0 | Belum disalin pada sesi ini | API Wikipedia memberi HTTP 429; gunakan dump resmi atau unduh terjadwal dengan atribusi |
| Instruksi | [SEA-IFEval](https://huggingface.co/datasets/aisingapore/Instruction-Following-IFEval) | Terjemahan SEA CC BY 4.0; sumber IFEval Apache 2.0 | Belum disalin | Kartu dataset memerlukan persetujuan berbagi kontak; jangan bypass gate |
| QA | [AC-IQuAD](https://github.com/muhammadravi251001/ac-iquad) | Lisensi eksplisit tidak ditemukan di repo | Tidak disalin | Ditahan sampai pemilik memberikan lisensi yang jelas |

## Artefak gabungan

`data_legal_combined.txt` menggabungkan dataset training sebelumnya dengan 999 dialog IndoToD. Ukurannya sekitar 5,13 MB. `data_indotod.txt` dibuat oleh `import_indotod.py` dari file JSON Indonesia, bukan dari file bilingual.

## Aturan penggunaan

Atribusi dan lisensi harus ikut disertakan ketika mendistribusikan dataset atau model turunan. Dataset Wikipedia/IndoToD yang berlisensi share-alike tidak boleh diperlakukan sebagai data tanpa kewajiban lisensi. Dataset dengan lisensi atau akses yang tidak jelas tidak dimasukkan ke training.
