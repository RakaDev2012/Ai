# VoxelCraft: Lumen Frontier

Prototype voxel sandbox Android-ready yang **orisinal** dan tidak memakai kode, merek, atau aset Minecraft. Fitur inti:

- Dunia voxel prosedural kecil dengan terrain berlapis dan instancing untuk mengurangi draw call.
- Tekstur SVG buatan sendiri: moss, slate, dan emberwood.
- Registry item/block orisinal: moss, slate, emberwood, dan glowstone.
- Mining dan placement block berbasis raycast, inventory lima slot, health, hunger, fall damage, dan siklus siang/malam.
- Tangan kanan dan tangan kiri yang dapat memegang semua item; klik kiri menambang/menggunakan tangan kiri, klik kanan memasang/menggunakan tangan kanan.
- Dynamic light dari lampu yang dibawa pemain, dengan shadow opsional.
- Hotbar/inventory HUD, crosshair, dan info performa.
- Command console dengan sintaks orisinal `/give`, `/set`, `/tp`, `/time`, dan `/help`.
- Desain hemat memori: grid 20×20, MultiMesh per jenis blok, material bersama, dan renderer Compatibility.

## Menjalankan

Buka folder ini di Godot 4.3+ lalu jalankan scene utama. Keyboard: WASD, Space, E, klik kiri/kanan. Tombol angka memilih slot hotbar.

Tekan `/` untuk membuka command console. Contoh: `/give glowstone`, `/set 2 4 2 moss`, `/tp 0 8 0`, atau `/time night`.

## Android

Preset ekspor Android disiapkan di `export_presets.cfg`. Build APK membutuhkan Android SDK/NDK, OpenJDK, dan template ekspor Godot di mesin build. Source di repositori siap diekspor setelah dependency Android tersedia.

## Lisensi

Kode proyek ini MIT. Semua aset visual di folder `assets/` dibuat khusus untuk proyek ini oleh generator sederhana dan dirilis bersama kode.
