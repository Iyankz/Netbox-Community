#!/bin/bash

# =================================================================
# Script Auto-Install NetBox Community - Fully Automated Superuser
# =================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Fungsi untuk mengecek status perintah terakhir
check_status() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Langkah gagal pada: $1. Script dihentikan.${NC}"
        exit 1
    else
        echo -e "${GREEN}[OK] $1 Berhasil.${NC}"
    fi
}

echo -e "${BLUE}>>> Memulai Instalasi NetBox Community Otomatis...${NC}"

# 1. Set Local Time Zone
sudo timedatectl set-timezone Asia/Jakarta
check_status "Setting Timezone"

# 2. Update & Install Dependencies
echo -e "${BLUE}>>> Menginstal dependensi sistem...${NC}"
sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl software-properties-common git
check_status "Install Dependencies"

# 3. Install Docker Engine
echo -e "${BLUE}>>> Menginstal Docker Engine...${NC}"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
check_status "Download Docker GPG Key"

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
check_status "Install Docker Engine"

# 4. Clone NetBox Repository
echo -e "${BLUE}>>> Mendownload NetBox Docker...${NC}"
if [ ! -d "netbox-docker" ]; then
    git clone -b release https://github.com/netbox-community/netbox-docker.git
    check_status "Git Clone NetBox"
fi
cd netbox-docker || exit

# 5. Konfigurasi Port 8000
echo -e "${BLUE}>>> Membuat docker-compose.override.yml...${NC}"
cat <<EOF > docker-compose.override.yml
services:
  netbox:
    ports:
      - 8000:8080
EOF
check_status "Create Override File"

# 6. Menjalankan NetBox
echo -e "${BLUE}>>> Menarik Docker Images...${NC}"
sudo docker compose pull
check_status "Docker Pull"

echo -e "${BLUE}>>> Menjalankan Container...${NC}"
sudo docker compose up -d
check_status "Docker Compose Up"

# 7. Jeda Otomatis untuk Inisialisasi Database
echo -e "${YELLOW}>>> Menunggu database siap (60 detik)...${NC}"
sleep 60

# 8. Create Superuser secara Otomatis (Non-Interaktif)
echo -e "${BLUE}>>> Membuat Superuser Default...${NC}"
sudo docker compose exec -e DJANGO_SUPERUSER_PASSWORD='netboxAdmin1' netbox \
    /opt/netbox/netbox/manage.py createsuperuser \
    --no-input \
    --username netboxAdmin1 \
    --email netboxadmin1@net.id
check_status "Pembuatan Superuser"

# Info Akhir
IP_ADDR=$(hostname -I | awk '{print $1}')
echo "----------------------------------------------------"
echo -e "${GREEN}INSTALASI SELESAI!${NC}"
echo -e "URL      : ${BLUE}http://$IP_ADDR:8000${NC}"
echo -e "Username : ${YELLOW}netboxAdmin1${NC}"
echo -e "Password : ${YELLOW}netboxAdmin1${NC}"
echo "----------------------------------------------------"
