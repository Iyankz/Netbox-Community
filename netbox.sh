#!/bin/bash

# =================================================================
# Script Auto-Install NetBox Community (Docker) - Ubuntu 24.04
# Dibuat oleh Iyankz & Gemini
# =================================================================

# Pastikan script dijalankan sebagai root/sudo
if [ "$EUID" -ne 0 ]; then 
  echo "Silakan jalankan script ini dengan sudo!"
  exit 1
fi

echo "--- 1. Mengatur Timezone ke Asia/Jakarta ---"
timedatectl set-timezone Asia/Jakarta

echo "--- 2. Update System & Install Dependencies ---"
apt update && apt install -y apt-transport-https ca-certificates curl software-properties-common git

echo "--- 3. Instalasi Docker Engine Terbaru ---"
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--- 4. Download NetBox Docker via Git ---"
if [ -d "netbox-docker" ]; then
  echo "Folder netbox-docker sudah ada, masuk ke folder..."
  cd netbox-docker
else
  git clone -b release https://github.com/netbox-community/netbox-docker.git
  cd netbox-docker
fi

echo "--- 5. Konfigurasi Docker Compose Override ---"
# Menghapus 'version' untuk menghilangkan pesan WARN: attribute version is obsolete
cat <<EOF > docker-compose.override.yml
services:
  netbox:
    ports:
      - 8000:8080
EOF

echo "--- 6. Menjalankan NetBox Service ---"
docker compose pull
docker compose up -d

echo "------------------------------------------------------------"
echo "MENUNGGU SERVICE READY (Status Healthy)..."
echo "Proses ini memakan waktu (Migrasi Database & Inisialisasi)."
echo "------------------------------------------------------------"

# Loop pengecekan status Healthy untuk menghindari error 'unhealthy'
TIMER=0
until [ "$(docker inspect --format='{{.State.Health.Status}}' netbox-docker-netbox-1 2>/dev/null)" == "healthy" ]; do
    echo -n "."
    sleep 5
    TIMER=$((TIMER+5))
    if [ $TIMER -gt 300 ]; then
        echo -e "\n[!] Service gagal Healthy setelah 5 menit. Cek logs: docker compose logs netbox"
        exit 1
    fi
done

echo -e "\n------------------------------------------------------------"
echo "INSTALASI BERHASIL!"
echo "------------------------------------------------------------"
echo "Langkah Terakhir: Buat Superuser Secara Manual"
echo "Gunakan perintah di bawah ini agar aman dari error TTY:"
echo ""
echo "cd netbox-docker/"
echo "docker compose exec -it netbox /opt/netbox/netbox/manage.py createsuperuser"
echo ""
echo "Akses NetBox di: http://$(hostname -I | awk '{print $1}'):8000"
echo "------------------------------------------------------------"
echo "Script ini dibuat oleh Iyankz dan ditata oleh Gemini"
echo "------------------------------------------------------------"
