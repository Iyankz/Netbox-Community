#!/bin/bash

# =================================================================
# Script Auto-Install NetBox Community (Docker) - Ubuntu 22.04 & 24.04
# =================================================================

# Pastikan script dijalankan sebagai root/sudo
if [ "$EUID" -ne 0 ]; then 
  echo "Silakan jalankan script ini dengan sudo!"
  exit
fi

echo "--- 1. Mengatur Timezone ke Asia/Jakarta ---"
timedatectl set-timezone Asia/Jakarta

echo "--- 2. Update System & Install Dependencies ---"
apt update && apt install -y apt-transport-https ca-certificates curl software-properties-common git

echo "--- 3. Instalasi Docker Engine ---"
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "--- 4. Download NetBox Docker via Git ---"
if [ -d "netbox-docker" ]; then
  echo "Folder netbox-docker sudah ada, melewati proses clone..."
  cd netbox-docker
else
  git clone -b release https://github.com/netbox-community/netbox-docker.git
  cd netbox-docker
fi

echo "--- 5. Konfigurasi Docker Compose Override ---"
cat <<EOF > docker-compose.override.yml
version: '3.4'
services:
  netbox:
    ports:
      - 8000:8080
EOF

echo "--- 6. Menarik Image & Menjalankan NetBox ---"
docker compose pull
docker compose up -d

echo "------------------------------------------------------------"
echo "Menunggu container siap (sekitar 30 detik)..."
echo "------------------------------------------------------------"
sleep 30

echo "--- 7. Membuat Superuser ---"
echo "Silakan masukkan detail admin sesuai instruksi sebelumnya:"
echo "Username: netboxAdmin1"
echo "Email: netboxadmin1@net.id"
echo "Password: Sukabumi2024!"
echo "------------------------------------------------------------"

docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser

echo "------------------------------------------------------------"
echo "INSTALASI SELESAI!"
echo "Akses NetBox di: http://$(hostname -I | awk '{print $1}'):8000"
echo "Script Ini di buat oleh Iyankz dan di tata oleh Gemini"
echo "------------------------------------------------------------"
