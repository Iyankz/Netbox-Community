# Netbox-Community
  Auto Install Netbox Community

1. Install Docker & Netbox
  ##
    sudo curl -Ssl https://raw.githubusercontent.com/Iyankz/Netbox-Community/refs/heads/main/netbox.sh | sudo bash
2. Buat Super User
  ##
    docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser
