import argparse
import random
from pathlib import Path

TOPICS = [
    ("Python", "Python adalah bahasa pemrograman yang mudah dibaca dan sering digunakan untuk otomasi, data, serta kecerdasan buatan."),
    ("belajar", "Belajar lebih efektif jika dilakukan bertahap, dengan tujuan kecil, latihan rutin, dan evaluasi berkala."),
    ("AI", "Kecerdasan buatan adalah teknologi yang membuat komputer mempelajari pola dan membantu menyelesaikan tugas tertentu."),
    ("model bahasa", "Model bahasa memprediksi token berikutnya berdasarkan pola yang dipelajari dari data pelatihan."),
    ("GGUF", "GGUF adalah format file model yang banyak digunakan untuk menjalankan model bahasa secara lokal dengan llama.cpp."),
    ("privasi", "Privasi perlu dijaga dengan tidak membagikan kata sandi, data identitas, atau informasi rahasia kepada pihak yang tidak dipercaya."),
    ("olahraga", "Olahraga ringan yang dilakukan secara rutin dapat membantu menjaga kebugaran dan kesehatan tubuh."),
    ("membaca", "Membaca membantu memperluas kosakata, meningkatkan pemahaman, dan melatih kemampuan berpikir kritis."),
    ("rencana", "Rencana yang baik berisi tujuan, langkah yang jelas, batas waktu, dan cara untuk mengukur kemajuan."),
    ("kesalahan", "Kesalahan adalah bagian dari proses belajar. Analisis penyebabnya, perbaiki langkahnya, lalu coba kembali."),
]

GREETINGS = [
    ("Halo", "Halo! Senang bertemu dengan Anda."),
    ("Hai", "Hai! Ada yang ingin Anda pelajari hari ini?"),
    ("Selamat pagi", "Selamat pagi! Semoga hari Anda berjalan lancar."),
    ("Apa kabar", "Saya baik dan siap membantu. Apa kabar Anda?"),
]

TEMPLATES = [
    ("Apa itu {topic}?", "{answer}"),
    ("Tolong jelaskan tentang {topic}.", "Baik. {answer}"),
    ("Mengapa {topic} penting?", "{answer} Hal itu penting karena dapat membantu kita mengambil keputusan yang lebih baik."),
    ("Bagaimana cara belajar {topic}?", "Mulailah dari dasar, lakukan latihan kecil, dan catat hal yang belum dipahami. Dalam konteks ini, {answer}"),
    ("Berikan saran tentang {topic}.", "Saran saya adalah membuat langkah yang sederhana dan konsisten. {answer}"),
    ("Saya ingin memahami {topic}.", "Tentu. Inti yang perlu dipahami adalah: {answer}"),
]

FOLLOWUPS = [
    ("Mengapa?", "Karena pemahaman yang baik terbentuk dari contoh, latihan, dan peninjauan kembali."),
    ("Bisa dijelaskan lebih sederhana?", "Tentu. Mulailah dari konsep paling dasar, kemudian tambahkan satu bagian baru setiap kali sudah paham."),
    ("Apa langkah pertama?", "Langkah pertama adalah menentukan tujuan kecil yang jelas dan dapat diselesaikan hari ini."),
    ("Ada contoh singkat?", "Contoh sederhananya adalah mencoba satu kasus kecil, mengamati hasilnya, lalu memperbaiki bagian yang kurang."),
]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default='data.txt')
    ap.add_argument('--examples', type=int, default=10000)
    ap.add_argument('--seed', type=int, default=42)
    args = ap.parse_args()
    rng = random.Random(args.seed)
    rows = []
    for user, assistant in GREETINGS:
        rows.append(f"Pengguna: {user}\nAsisten: {assistant}\n")
    for _ in range(args.examples):
        topic, answer = rng.choice(TOPICS)
        question, response = rng.choice(TEMPLATES)
        rows.append(f"Pengguna: {question.format(topic=topic)}\nAsisten: {response.format(answer=answer)}\n")
        if rng.random() < 0.35:
            q2, a2 = rng.choice(FOLLOWUPS)
            rows.append(f"Pengguna: {q2}\nAsisten: {a2}\n")
    rng.shuffle(rows)
    Path(args.out).write_text("\n".join(rows), encoding='utf-8')
    print(f"written={args.out} examples={len(rows)} bytes={Path(args.out).stat().st_size}")

if __name__ == '__main__':
    main()
