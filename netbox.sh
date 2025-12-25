#!/bin/bash

# =================================================================
# Script Auto-Install NetBox Community - Ubuntu 24.04 (Custom Pause)
# =================================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}>>> Memulai Instalasi NetBox Community...${NC}"

# 1. Set Local Time Zone
timedatectl set-timezone Asia/Jakarta

# 2. Update & Install Dependencies
apt update && apt install -y apt-transport-https ca-certificates curl software-properties-common git

# 3. Install Docker Engine
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 4. Clone NetBox Repository
if [ ! -d "netbox-docker" ]; then
    git clone -b release https://github.com/netbox-community/netbox-docker.git
fi
cd netbox-docker

# 5. Konfigurasi Port 8000
cat <<EOF > docker-compose.override.yml
services:
  netbox:
    ports:
      - 8000:8080
EOF

# 6. Menjalankan NetBox
echo -e "${GREEN}>>> Pulling images dan menjalankan container...${NC}"
docker compose pull
docker compose up -d

echo "----------------------------------------------------"
echo -e "${YELLOW}JEDA MANUAL:${NC}"
echo -e "Silakan tunggu sekitar 1 menit agar database selesai migrasi."
echo -e "Anda bisa mengecek status di terminal lain dengan: docker compose ps"
echo -e "Jika status semua container sudah 'healthy', silakan lanjut."
echo "----------------------------------------------------"
read -p "Tekan [ENTER] untuk mulai membuat User Admin (Superuser)..."

# 7. Create Superuser (Menggunakan -it agar interaktif)
echo -e "${GREEN}>>> Menjalankan Create Superuser...${NC}"
docker compose exec -it netbox /opt/netbox/netbox/manage.py createsuperuser

# Selesai
IP_ADDR=$(hostname -I | awk '{print $1}')
echo "----------------------------------------------------"
echo -e "${GREEN}INSTALASI SELESAI!${NC}"
echo -e "Akses NetBox di: ${BLUE}http://$IP_ADDR:8000${NC}"
echo "----------------------------------------------------"
