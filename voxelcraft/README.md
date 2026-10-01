# VoxelCraft: Lumen Frontier

Prototype voxel sandbox Android-ready yang **orisinal** dan tidak memakai kode, merek, atau aset Minecraft. Fitur inti:

- Dunia voxel prosedural kecil dengan terrain berlapis dan instancing untuk mengurangi draw call.
- Tekstur SVG buatan sendiri: moss, slate, dan emberwood.
- Tangan kanan dan tangan kiri yang dapat memegang item aktif; klik kiri/kanan menjalankan aksi independen.
- Dynamic light dari lampu yang dibawa pemain, dengan shadow opsional.
- Hotbar/inventory HUD, crosshair, info performa, dan toggle inventory.
- Desain hemat memori: chunk 20×20, MultiMesh untuk blok, material bersama, dan renderer Compatibility.

## Menjalankan

Buka folder ini di Godot 4.3+ lalu jalankan scene utama. Keyboard: WASD, Space, E, klik kiri/kanan. Tombol angka memilih slot hotbar.

## Android

Preset ekspor Android disiapkan di `export_presets.cfg`. Build APK membutuhkan Android SDK/NDK, OpenJDK, dan template ekspor Godot di mesin build. Source di repositori siap diekspor setelah dependency Android tersedia.

## Lisensi

Kode proyek ini MIT. Semua aset visual di folder `assets/` dibuat khusus untuk proyek ini oleh generator sederhana dan dirilis bersama kode.
