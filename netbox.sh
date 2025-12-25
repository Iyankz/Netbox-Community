#!/bin/bash

# Warna output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}>>> Membersihkan instalasi lama yang gagal...${NC}"
if [ -d "netbox-docker" ]; then
    cd netbox-docker
    sudo docker compose down -v
    cd ..
    sudo rm -rf netbox-docker
fi

echo -e "${BLUE}>>> Memulai instalasi bersih NetBox...${NC}"

# 1. Update & Install Docker (Ubuntu 24.04 Standard)
sudo apt update && sudo apt install -y curl git
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Clone Repository
git clone -b release https://github.com/netbox-community/netbox-docker.git
cd netbox-docker || exit

# 3. Buat Override Port (Tanpa deklarasi 'version' untuk menghindari Warning)
cat <<EOF > docker-compose.override.yml
services:
  netbox:
    ports:
      - 8000:8080
EOF

# 4. Jalankan Service
echo -e "${BLUE}>>> Pulling & Starting containers...${NC}"
sudo docker compose pull
sudo docker compose up -d

# 5. Cek Status Kesehatan (Healthcheck)
echo -e "${BLUE}>>> Menunggu container menjadi 'healthy' (Bisa memakan waktu 2-3 menit)...${NC}"
ATTEMPTS=0
while [ $(sudo docker ps | grep "netbox-docker-netbox-1" | grep -c "healthy") -eq 0 ]; do
    if [ $ATTEMPTS -gt 30 ]; then
        echo -e "${RED}[ERROR] NetBox gagal menjadi healthy dalam 5 menit. Cek log dengan: docker compose logs netbox${NC}"
        exit 1
    fi
    echo -n "."
    sleep 10
    ATTEMPTS=$((ATTEMPTS+1))
done
echo -e "\n${GREEN}[OK] NetBox sudah Healthy!${NC}"

# 6. Membuat Superuser Otomatis (Fix TTY Error)
echo -e "${BLUE}>>> Membuat Superuser default...${NC}"
# Menggunakan flag -T agar tidak butuh TTY
sudo docker compose exec -T -e DJANGO_SUPERUSER_PASSWORD='netboxAdmin1' netbox \
    /opt/netbox/netbox/manage.py createsuperuser \
    --no-input \
    --username netboxAdmin1 \
    --email netboxadmin1@net.id

echo "----------------------------------------------------"
echo -e "${GREEN}INSTALASI SELESAI!${NC}"
echo -e "URL      : http://$(hostname -I | awk '{print $1}'):8000"
echo -e "Username : netboxAdmin1"
echo -e "Password : netboxAdmin1"
echo "----------------------------------------------------"
