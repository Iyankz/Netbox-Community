#!/bin/bash

# =================================================================
# NetBox Auto-Install - Ubuntu 24.04 (Clean State Version)
# =================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Fungsi cek error
check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Gagal pada langkah: $1${NC}"
        exit 1
    fi
}

echo -e "${BLUE}>>> Memulai Instalasi di Sistem Bersih...${NC}"

# 1. Update & Install Docker (Official Script)
sudo apt update && sudo apt install -y curl git
check_status "Update Repository"

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
check_status "Instalasi Docker"

# 2. Persiapan NetBox Repository
git clone -b release https://github.com/netbox-community/netbox-docker.git
cd netbox-docker || exit
check_status "Clone Repository"

# 3. Konfigurasi Port 8000
cat <<EOF > docker-compose.override.yml
services:
  netbox:
    ports:
      - 8000:8080
EOF

# 4. Jalankan Service
echo -e "${BLUE}>>> Menarik Images & Menjalankan Containers...${NC}"
sudo docker compose pull
sudo docker compose up -d
check_status "Docker Compose Up"

# 5. Menunggu Healthcheck (Sangat Penting untuk Proxmox/VM)
echo -e "${YELLOW}>>> Menunggu NetBox Ready (Status: Healthy)...${NC}"
echo -e "${YELLOW}>>> Proses migrasi database sedang berjalan di latar belakang.${NC}"

# Loop untuk mengecek status healthy container netbox
TIMER=0
until [ "$(sudo docker inspect --format='{{.State.Health.Status}}' netbox-docker-netbox-1 2>/dev/null)" == "healthy" ]; do
    echo -n "."
    sleep 5
    TIMER=$((TIMER+5))
    
    # Timeout jika lebih dari 5 menit
    if [ $TIMER -gt 300 ]; then
        echo -e "${RED}\n[ERROR] Container tidak kunjung Healthy. Silakan cek 'docker compose logs netbox'${NC}"
        exit 1
    fi
done

echo -e "\n${GREEN}[OK] NetBox sudah siap!${NC}"

# 6. Pembuatan Superuser Otomatis (Fix TTY & No-Input)
echo -e "${BLUE}>>> Membuat Superuser Default...${NC}"
sudo docker compose exec -T -e DJANGO_SUPERUSER_PASSWORD='netboxAdmin1' netbox \
    /opt/netbox/netbox/manage.py createsuperuser \
    --no-input \
    --username netboxAdmin1 \
    --email netboxadmin1@net.id
check_status "Pembuatan Superuser"

# Selesai
IP_ADDR=$(hostname -I | awk '{print $1}')
echo "----------------------------------------------------"
echo -e "${GREEN}INSTALASI SELESAI!${NC}"
echo -e "URL      : ${BLUE}http://$IP_ADDR:8000${NC}"
echo -e "Username : ${YELLOW}netboxAdmin1${NC}"
echo -e "Password : ${YELLOW}netboxAdmin1${NC}"
echo "----------------------------------------------------"
