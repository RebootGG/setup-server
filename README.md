# Media Stack Setup (Ubuntu amd64)

Goal: install Sonarr, Radarr, Prowlarr, qBittorrent-nox, Plex, and Netdata with automatic startup after reboot.

## Install (scripted)

Use the install script and keep any optional changes in that file.

```bash
chmod +x ./media-stack-install.sh
./media-stack-install.sh
```

## What gets installed

- Sonarr: `/opt/Sonarr`, data in `/var/lib/sonarr`, port `8989`
- Radarr: `/opt/Radarr`, data in `/var/lib/radarr`, port `7878`
- Prowlarr: `/opt/Prowlarr`, data in `/var/lib/prowlarr`, port `9696`
- qBittorrent-nox: `/home/<primary_user>/.config/qBittorrent`, WebUI port `8080`
- Plex: `/var/lib/plexmediaserver`, port `32400`
- Netdata: `/var/lib/netdata`, port `19999`

## Verify

```bash
systemctl is-active sonarr.service radarr.service prowlarr.service qbittorrent-nox@<primary_user>.service plexmediaserver.service netdata.service
```

## Backup/restore priorities

- `/home/<primary_user>/.config/qBittorrent`
- `/var/lib/sonarr`
- `/var/lib/radarr`
- `/var/lib/prowlarr`
- `/var/lib/plexmediaserver`
