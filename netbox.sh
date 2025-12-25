#!/bin/bash

# =================================================================
# Script Auto-Install NetBox Community (Docker) - Ubuntu 24.04
# =================================================================

# Warna untuk output agar mudah dibaca
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}>>> Memulai Instalasi NetBox Community...${NC}"

# 1. Set Local Time Zone
echo -e "${GREEN}>>> Mengatur Timezone ke Asia/Jakarta...${NC}"
timedatectl set-timezone Asia/Jakarta

# 2. Update & Install Dependencies
echo -e "${GREEN}>>> Update System & Install Dependencies...${NC}"
apt update && apt install -y apt-transport-https ca-certificates curl software-properties-common git

# 3. Install Docker Engine Terbaru
echo -e "${GREEN}>>> Menginstal Docker Engine...${NC}"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Clone NetBox Docker Repository
echo -e "${GREEN}>>> Mendownload NetBox Docker dari GitHub...${NC}"
if [ -d "netbox-docker" ]; then
    echo "Folder netbox-docker sudah ada, masuk ke folder..."
    cd netbox-docker
else
    git clone -b release https://github.com/netbox-community/netbox-docker.git
    cd netbox-docker
fi

# 5. Konfigurasi Port 8000 via Override
echo -e "${GREEN}>>> Membuat konfigurasi port 8000...${NC}"
cat <<EOF > docker-compose.override.yml
version: '3.4'
services:
  netbox:
    ports:
      - 8000:8080
EOF

# 6. Menjalankan NetBox
echo -e "${GREEN}>>> Menarik Image dan Menjalankan Container (ini butuh waktu)...${NC}"
docker compose pull
docker compose up -d

# 7. Menunggu Service Ready
echo -e "${BLUE}>>> Menunggu database inisialisasi (45 detik)...${NC}"
sleep 45

# 8. Create Superuser (Interaktif)
echo -e "${GREEN}>>> Membuat User Admin...${NC}"
echo -e "Silakan isi data berikut saat diminta:"
echo -e "Username: ${BLUE}netboxAdmin1${NC}"
echo -e "Email: ${BLUE}netboxadmin1@net.id${NC}"
echo -e "Password: ${BLUE}Sukabumi2024!${NC}"
echo "----------------------------------------------------"

docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser

# Selesai
IP_ADDR=$(hostname -I | awk '{print $1}')
echo "----------------------------------------------------"
echo -e "${GREEN}INSTALASI SELESAI!${NC}"
echo -e "Silakan akses NetBox di: ${BLUE}http://$IP_ADDR:8000${NC}"
echo "----------------------------------------------------"
