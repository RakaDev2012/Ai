# VoxelCraft: Lumen Frontier

Prototype voxel sandbox Android-ready yang **orisinal** dan tidak memakai kode, merek, atau aset Minecraft. Fitur inti:

- Dunia voxel prosedural kecil dengan terrain berlapis dan instancing untuk mengurangi draw call.
- Tekstur SVG buatan sendiri: moss, slate, dan emberwood, dengan material warna orisinal untuk registry block.
- Registry 35 block/material orisinal: moss, slate, emberwood, glowstone, sand, snow, obsidian, brick, glass, water, leaves, copper, gold, clay, bedrock, dirt, grass, gravel, stone, cobblestone, oak_log, birch_log, planks, quartz, netherrack, endstone, amethyst, prismarine, sea_lantern, torch, lantern, tnt, iron, diamond, dan emerald.
- Mining dan placement block berbasis raycast, inventory lima slot, health, hunger, fall damage, dan siklus siang/malam.
- Tangan kanan dan tangan kiri yang dapat memegang semua item; klik kiri menambang/menggunakan tangan kiri, klik kanan memasang/menggunakan tangan kanan.
- Dynamic light dari lampu yang dibawa pemain, dengan shadow opsional.
- Hotbar/inventory HUD, crosshair, dan info performa.
- Command console dengan sintaks orisinal `/give`, `/set`, `/tp`, `/time`, dan `/help`.
- Save/load world JSON, autosave setiap 30 detik, restore posisi pemain, inventory, health, hunger, dan waktu dunia.
- Crafting awal melalui `/craft glowstone` dengan resep emberwood + slate.
- Content registry terpisah untuk wooden/stone/iron/diamond tools, sword, bow, armor, food, ammo, dan recipe; gunakan `/recipes` untuk melihat daftar resep.
- Desain hemat memori: grid 20×20, MultiMesh per jenis blok, material bersama, dan renderer Compatibility.

## Menjalankan

Buka folder ini di Godot 4.3+ lalu jalankan scene utama. Keyboard: WASD, Space, E, klik kiri/kanan. Tombol angka memilih slot hotbar.

Tekan `/` untuk membuka command console. Command mencakup `/give`, `/setblock`, `/fill`, `/clone`, `/tp`, `/spawnpoint`, `/kill`, `/clear`, `/locate`, `/time`, `/weather`, `/difficulty`, `/gamerule`, `/effect`, `/craft`, `/recipes`, `/save`, dan `/load`.

## Android

Preset ekspor Android disiapkan di `export_presets.cfg`. APK debug hasil ekspor tersedia di `exported/VoxelCraft-debug.apk`; APK ini ditandatangani dengan debug keystore untuk pengujian lokal, bukan untuk rilis Play Store.

## Lisensi

Kode proyek ini MIT. Semua aset visual di folder `assets/` dibuat khusus untuk proyek ini oleh generator sederhana dan dirilis bersama kode.
