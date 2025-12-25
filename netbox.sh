#!/bin/bash

# =================================================================
# NetBox Auto-Install - Core Only (Tanpa Auto-Superuser)
# =================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Gagal pada langkah: $1${NC}"
        exit 1
    fi
}

echo -e "${BLUE}>>> Memulai Instalasi NetBox Community (Ubuntu 24.04)...${NC}"

# 1. Update & Install Docker
sudo apt update && sudo apt install -y curl git
check_status "Update Repository"

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
check_status "Instalasi Docker"

# 2. Persiapan NetBox Repository
if [ ! -d "netbox-docker" ]; then
    git clone -b release https://github.com/netbox-community/netbox-docker.git
fi
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

# 5. Menunggu Status Healthy
echo -e "${YELLOW}>>> Menunggu NetBox Ready (Proses migrasi database)...${NC}"
TIMER=0
until [ "$(sudo docker inspect --format='{{.State.Health.Status}}' netbox-docker-netbox-1 2>/dev/null)" == "healthy" ]; do
    echo -n "."
    sleep 5
    TIMER=$((TIMER+5))
    if [ $TIMER -gt 300 ]; then
        echo -e "${RED}\n[ERROR] Service belum healthy. Cek log: docker compose logs netbox${NC}"
        exit 1
    fi
done

echo -e "\n${GREEN}[OK] NetBox Core sudah terinstal dan berjalan!${NC}"
IP_ADDR=$(hostname -I | awk '{print $1}')
echo "----------------------------------------------------"
echo -e "Akses Dashboard : http://$IP_ADDR:8000"
echo "----------------------------------------------------"
