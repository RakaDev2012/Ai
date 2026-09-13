# Sumber Dataset Bahasa Indonesia

## Status lokal

`data.txt` berisi dialog sintetis yang dibuat oleh `generate_dataset.py`. `data_3000.txt` dibuat dari 3.000 blok dialog yang dipilih secara deterministik dengan seed 42. Data ini bukan salinan dari sumber internet.

`data_indonlg.txt` berisi **11.929 pasangan teks** yang diimpor dari repositori IndoNLG melalui `import_indonlg.py`. `data_combined.txt` menggabungkan 3.000 dialog lokal dan pasangan IndoNLG tersebut untuk sesi training ulang.

Buat ulang dataset 3.000 dialog dengan:

```bash
python prepare_3000.py --source data.txt --out data_3000.txt --count 3000
```

## Sumber internet yang ditinjau

| Sumber | Kegunaan | Lisensi/status | Keputusan |
|---|---|---|---|
| [SEADialogues](https://github.com/SEACrowd/SEADialogues) | Dialog multi-turn, termasuk Bahasa Indonesia | Lisensi perlu dibaca dari kartu dataset dan paper sebelum redistribusi | Kandidat impor lanjutan; belum disalin ke repo |
| [Indonesian Newspapers 2018](https://huggingface.co/datasets/indonesian-nlp/id_newspapers_2018) | Korpus teks Indonesia skala besar | CC BY 4.0 pada kartu dataset, dengan catatan hak artikel tetap pada pemilik media dan penggunaan dibatasi untuk riset terbuka | Kandidat pretraining; tidak disalin karena besar dan memiliki batas penggunaan |
| [Indonesian Wikipedia](https://id.wikipedia.org/) | Potongan ensiklopedis beragam | CC BY-SA; atribusi dan ketentuan share-alike harus dipertahankan | API pengambilan bulk tidak selesai dalam sesi ini; tidak diklaim sudah masuk dataset |
| [Awesome Indonesian LLM Dataset](https://github.com/irfanfadhullah/awesome-indonesian-llm-dataset) | Katalog sumber NLU, NER, sentiment, dan instruction | Lisensi mengikuti dataset masing-masing | Dipakai sebagai katalog, bukan sumber tunggal untuk menyalin data |
| [Cendol](https://github.com/IndoNLP/cendol) | Referensi instruction/chat Bahasa Indonesia | Proyek dan koleksi memiliki ketentuan penggunaan masing-masing | Dipakai sebagai referensi desain, bukan disalin |
| [IndoNLG](https://github.com/indobenchmark/indonlg) | Pasangan teks NLG/terjemahan dengan sisi Bahasa Indonesia | Kartu GEM menyatakan MIT; data tetap perlu dipakai sesuai dokumentasi sumber | Diimpor sebagai `data_indonlg.txt` dan digabung ke `data_combined.txt` |

## Prinsip penggunaan

Sebelum memasukkan data eksternal ke model, simpan URL sumber, lisensi, tanggal pengambilan, dan atribusi per item. Jangan memasukkan data pribadi, konten berbayar, atau artikel berita secara massal tanpa hak penggunaan yang sesuai.
