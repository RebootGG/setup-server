#!/usr/bin/env bash
set -euo pipefail

PRIMARY_USER=${PRIMARY_USER:-${SUDO_USER:-${USER}}}

# Version pins (match current box)
SONARR_VERSION="4.0.16.2944"
RADARR_VERSION="6.0.4.10291"
PROWLARR_VERSION="2.3.0.5236"

SONARR_URL="https://github.com/Sonarr/Sonarr/releases/download/v${SONARR_VERSION}/Sonarr.main.${SONARR_VERSION}.linux-x64.tar.gz"
RADARR_URL="https://github.com/Radarr/Radarr/releases/download/v${RADARR_VERSION}/Radarr.master.${RADARR_VERSION}.linux-core-x64.tar.gz"
PROWLARR_URL="https://github.com/Prowlarr/Prowlarr/releases/download/v${PROWLARR_VERSION}/Prowlarr.master.${PROWLARR_VERSION}.linux-core-x64.tar.gz"
PLEX_ARCH="amd64"

# Base packages
sudo apt update
sudo apt install -y curl ca-certificates tar unzip gnupg qbittorrent-nox netdata

# Users/groups
sudo groupadd -f media
sudo usermod -a -G media "$PRIMARY_USER"
sudo useradd -r -s /usr/sbin/nologin -d /nonexistent -g media sonarr || true
sudo useradd -r -s /usr/sbin/nologin -d /nonexistent -g media radarr || true
sudo useradd -r -s /usr/sbin/nologin -d /nonexistent -g media prowlarr || true

# Sonarr
curl -L -o /tmp/Sonarr.tar.gz "$SONARR_URL"
sudo mkdir -p /opt/Sonarr /var/lib/sonarr
sudo tar -xzf /tmp/Sonarr.tar.gz -C /opt/Sonarr --strip-components=1
sudo chown -R sonarr:media /opt/Sonarr /var/lib/sonarr

sudo tee /etc/systemd/system/sonarr.service > /dev/null <<'UNIT'
[Unit]
Description=Sonarr Daemon
After=syslog.target network.target

[Service]
User=sonarr
Group=media
UMask=0002
Type=simple
ExecStart=/opt/Sonarr/Sonarr -nobrowser -data=/var/lib/sonarr/
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

# Radarr
curl -L -o /tmp/Radarr.tar.gz "$RADARR_URL"
sudo mkdir -p /opt/Radarr /var/lib/radarr
sudo tar -xzf /tmp/Radarr.tar.gz -C /opt/Radarr --strip-components=1
sudo chown -R radarr:media /opt/Radarr /var/lib/radarr

sudo tee /etc/systemd/system/radarr.service > /dev/null <<'UNIT'
[Unit]
Description=Radarr Daemon
After=syslog.target network.target

[Service]
User=radarr
Group=media
UMask=0002
Type=simple
ExecStart=/opt/Radarr/Radarr -nobrowser -data=/var/lib/radarr/
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

# Prowlarr
curl -L -o /tmp/Prowlarr.tar.gz "$PROWLARR_URL"
sudo mkdir -p /opt/Prowlarr /var/lib/prowlarr
sudo tar -xzf /tmp/Prowlarr.tar.gz -C /opt/Prowlarr --strip-components=1
sudo chown -R prowlarr:media /opt/Prowlarr /var/lib/prowlarr

sudo tee /etc/systemd/system/prowlarr.service > /dev/null <<'UNIT'
[Unit]
Description=Prowlarr Daemon
After=syslog.target network.target

[Service]
User=prowlarr
Group=media
UMask=0002
Type=simple
ExecStart=/opt/Prowlarr/Prowlarr -nobrowser -data=/var/lib/prowlarr/
TimeoutStopSec=20
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT

# qBittorrent-nox
sudo systemctl enable --now qbittorrent-nox@"$PRIMARY_USER".service

# Plex
curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key | sudo gpg --dearmor -o /usr/share/keyrings/plexmediaserver.gpg
echo "deb [arch=${PLEX_ARCH} signed-by=/usr/share/keyrings/plexmediaserver.gpg] https://downloads.plex.tv/repo/deb public main" | \
  sudo tee /etc/apt/sources.list.d/plexmediaserver.list > /dev/null
sudo apt update
sudo apt install -y plexmediaserver
sudo usermod -a -G media plex
sudo systemctl enable --now plexmediaserver.service

# Netdata
sudo systemctl enable --now netdata.service

# Enable arr services
sudo systemctl daemon-reload
sudo systemctl enable --now sonarr.service radarr.service prowlarr.service

echo "Done. Verify with: systemctl is-active sonarr radarr prowlarr plexmediaserver netdata qbittorrent-nox@${PRIMARY_USER}" 
