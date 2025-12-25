#!/bin/bash

# =================================================================
# NetBox Auto-Install - Ubuntu 24.04 (Password Otomatis)
# =================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Gagal pada: $1.${NC}"
        exit 1
    fi
}

echo -e "${BLUE}>>> Memulai Instalasi...${NC}"

# 1. Update & Install Docker
sudo apt update && sudo apt install -y curl git
check_status "Update Sistem"

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
check_status "Instalasi Docker"

# 2. Clone Repository
if [ ! -d "netbox-docker" ]; then
    git clone -b release https://github.com/netbox-community/netbox-docker.git
fi
cd netbox-docker || exit

# 3. Konfigurasi Port 8000
cat <<EOF > docker-compose.override.yml
services:
  netbox:
    ports:
      - 8000:8080
EOF

# 4. Jalankan Service
sudo docker compose pull
sudo docker compose up -d
check_status "Docker Compose Up"

# 5. Tunggu Database Siap
echo -e "${BLUE}>>> Menunggu database siap (90 detik)...${NC}"
sleep 90

# 6. Membuat Superuser Otomatis dengan Password Default
echo -e "${BLUE}>>> Membuat Superuser Otomatis...${NC}"
sudo docker compose exec -T -e DJANGO_SUPERUSER_PASSWORD='netboxAdmin1' netbox \
    /opt/netbox/netbox/manage.py createsuperuser \
    --no-input \
    --username netboxAdmin1 \
    --email netboxadmin1@net.id
check_status "Pembuatan Superuser"

echo "----------------------------------------------------"
echo -e "${GREEN}INSTALASI SELESAI!${NC}"
echo -e "Login URL : http://$(hostname -I | awk '{print $1}'):8000"
echo -e "Username  : netboxAdmin1"
echo -e "Password  : netboxAdmin1"
echo "----------------------------------------------------"
