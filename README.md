# 🚀 NetBox Auto-Installer (Ubuntu 22.04 & 24.04)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![OS: Ubuntu](https://img.shields.io/badge/Recommended%20OS-Ubuntu%2022.04%20%7C%2024.04-orange.svg)](https://ubuntu.com/)

Solusi instalasi **NetBox Community (Docker)** yang paling stabil dan cepat, dioptimasi khusus untuk lingkungan Proxmox dan sistem operasi Ubuntu terbaru.

---

## 🤝 Kolaborasi Pengembangan
Proyek ini adalah hasil kolaborasi antara:
* **Iyankz**: Inisiator, penguji skenario, dan penentu alur kerja operasional.
* **Gemini (Google AI)**: Penata logika script, pemecah masalah (troubleshooter), dan dokumentasi teknis.

---

## 🖥️ Sistem Operasi yang Disarankan
Untuk mendapatkan performa dan stabilitas terbaik, script ini sangat disarankan dijalankan pada:
* **Ubuntu 24.04 LTS (Noble Numbat)**
* **Ubuntu 22.04 LTS (Jammy Jellyfish)**

---

## 🚀 One-Line Installer (Quick Start)
Anda dapat menginstal NetBox secara otomatis hanya dengan menjalankan satu baris perintah berikut di terminal Anda:

```bash
curl -sSL https://raw.githubusercontent.com/Iyankz/Netbox-Community/refs/heads/main/netbox.sh | sudo bash
```
## 🔑 Langkah Terakhir: Membuat Akun Admin
Setelah script menunjukkan status SUCCESS, buatlah akun admin secara manual untuk keamanan dan menghindari error TTY:
```bash
cd netbox-docker
docker compose exec -it netbox /opt/netbox/netbox/manage.py createsuperuser
```
## 🌐 Akses Dashboard
Buka browser Anda dan akses: http://IP-SERVER-ANDA:8000

----

## Dibuat dengan ❤️ oleh [Iyankz](https://github.com/Iyankz) & [Gemini AI](https://gemini.google.com/)

* **Iyankz** (Lead Developer)

* **Gemini** (Assistant Developer)

## ⚖️ Lisensi
Proyek ini dilisensikan di bawah **MIT License** - lihat file [LICENSE](LICENSE) untuk detailnya.
