# AGENTS

Use this file to avoid asking for basic environment details before installing software.

## System facts
- OS: Ubuntu amd64 (x86_64).
- Primary user: `<primary_user>` (home: `/home/<primary_user>`).
- Init system: systemd.
- Package manager: `apt` (use `sudo apt update` + `sudo apt install -y ...`).
- Base packages already expected: `curl`, `ca-certificates`, `tar`, `unzip`.
- Do not ask questions when the answer can be derived locally; check files, configs, or system state first.

## Install policy (default behavior)
- Prefer Ubuntu packages via `apt` when available.
- If not available in `apt`, use the vendor's official repo (signed keyring in `/usr/share/keyrings`).
- If no repo, use the upstream tarball for the current architecture, install under `/opt/<AppName>`, and create a systemd unit in `/etc/systemd/system`.
- Long-running services should be managed by systemd and enabled on boot.
- Config/data locations should follow existing conventions:
  - User apps: `/home/aymar/.config/<AppName>`
  - Service data: `/var/lib/<app>`

## Users and groups
- `<primary_user>` runs qBittorrent-nox.
- `sonarr`, `radarr`, and `prowlarr` are system users in group `media`.
- `plex` user is created by the Plex package; add it to `media`.

## Installed services (enabled) and ports
- `sonarr.service`: `/opt/Sonarr`; data `/var/lib/sonarr`; port `8989`.
- `radarr.service`: `/opt/Radarr`; data `/var/lib/radarr`; port `7878`.
- `prowlarr.service`: `/opt/Prowlarr`; data `/var/lib/prowlarr`; port `9696`.
- `qbittorrent-nox@<primary_user>.service`: config `/home/<primary_user>/.config/qBittorrent`; WebUI port `8080` (default; not set in config).
- `plexmediaserver.service`: data `/var/lib/plexmediaserver`; port `32400` (default).
- `netdata.service`: data `/var/lib/netdata`; port `19999` (default).
