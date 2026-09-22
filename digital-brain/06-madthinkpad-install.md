# madthinkpad Install (Phase 1)

**Scope:** Greenfield NixOS install on the ThinkPad from the `nix-migration` branch.
See `05-nixos-migration.md` for the why; this is only the how.

---

## 1. Boot the installer

Boot the NixOS 26.05 minimal ISO. Get online with `nmtui`.

## 2. Partition — mirrors madxp deliberately

ESP + swap + `/` + separate `/home`. Size swap at least equal to RAM (`free -g`) if hibernate is
ever wanted. The labels matter: the committed `hardware-configuration.nix` mounts by label.

```sh
DISK=/dev/nvme0n1
SWAP_END=33GiB    # 1GiB + RAM size
ROOT_END=153GiB   # SWAP_END + 120GiB

parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart swap linux-swap 1GiB "$SWAP_END"
parted "$DISK" -- mkpart root ext4 "$SWAP_END" "$ROOT_END"
parted "$DISK" -- mkpart home ext4 "$ROOT_END" 100%

mkfs.fat -F 32 -n BOOT "${DISK}p1"
mkswap -L swap "${DISK}p2"
mkfs.ext4 -L nixos "${DISK}p3"
mkfs.ext4 -L home "${DISK}p4"

mount /dev/disk/by-label/nixos /mnt
mount --mkdir -o umask=077 /dev/disk/by-label/BOOT /mnt/boot
mount --mkdir /dev/disk/by-label/home /mnt/home
swapon /dev/disk/by-label/swap
```

## 3. Install from the flake

```sh
nix-shell -p git
git clone -b nix-migration https://github.com/LaunchWare/launcher-os.git /mnt/home/dpickett/work/launcher-os
cd /mnt/home/dpickett/work/launcher-os

# Replace the placeholder with the real hardware scan
nixos-generate-config --root /mnt --show-hardware-config > hosts/madthinkpad/hardware-configuration.nix
```

Check the generated `fileSystems` entries still point at `/`, `/home`, `/boot` and the swap
partition, then install. **The caches go on the command line** — the installer doesn't know about
them yet, and without them Hyprland and Quickshell compile from source.

```sh
nixos-install --flake .#madthinkpad \
  --option extra-substituters "https://hyprland.cachix.org https://vicinae.cachix.org" \
  --option extra-trusted-public-keys "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc= vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
```

Expect local builds of Handy (Rust, the slow one), DMS (Go), and repackaging of unfree apps.
Everything else is substituted.

Set the root password when prompted, then the user password and ownership:

```sh
nixos-enter --root /mnt -c 'passwd dpickett'
nixos-enter --root /mnt -c 'chown -R dpickett:users /home/dpickett'
reboot
```

## 4. First boot

Log in through the DMS greeter (Hyprland (UWSM) session), open a terminal, then:

```sh
nmtui                                          # wifi again, now on the installed system
cd ~/work/launcher-os
git add hosts/madthinkpad/hardware-configuration.nix
git commit -m "chore(madthinkpad): commit generated hardware configuration"

chezmoi init --apply https://github.com/dpickett/dotfiles.git
mise install                                   # node + ruby via nix-ld
```

Site-specific browsers are `$HOME` state, not system state — recreate them:

```sh
launcher-os-install-webapp "GMail" "https://mail.google.com" "https://ssl.gstatic.com/ui/v1/icons/mail/rfr/gmail.ico" "x-scheme-handler/mailto"
launcher-os-install-webapp "Google Calendar" "https://calendar.google.com" "https://calendar.google.com/googlecalendar/images/favicon_v2014_2.ico" "text/calendar;application/ics;x-scheme-handler/webcal"
launcher-os-install-webapp "Zoom" "https://zoom.us/wc" "https://st1.zoom.us/zoom.ico" "x-scheme-handler/zoom;x-scheme-handler/zoommtg"
```

From here on, every change is `los switch` (`nixos-rebuild switch` for this host, then
`chezmoi apply`).

## 5. Smoke test

| Check | Command / action |
|---|---|
| Launcher-os defaults loaded | `ls /etc/launcher-os/hypr`; `SUPER+Space` opens Vicinae |
| DMS running | `systemctl --user status dms` |
| Monitor daemon | `systemctl --user status hyprmoncfgd` |
| Voice to text | `SUPER+SHIFT+Space` toggles Handy |
| mise toolchains execute | `node -e 'console.log(process.version)'`, `ruby -v` |
| Native deps link | `npm i esbuild sharp` / `gem install pg nokogiri` in a scratch dir |
| Docker | `docker run --rm hello-world` |
| Postgres | `createdb scratch && dropdb scratch` |

A missing shared library from a mise binary means `programs.nix-ld.libraries` in
`modules/dev.nix` needs another entry — find it with `LD_DEBUG=libs <binary>`.

## 6. Known gaps

- `hyprmoncfg` comes from nixpkgs-unstable at 1.9.1; madxp runs 1.18.4.
- DMS 1.6.2 runs on nixpkgs' Quickshell 0.3.0; watch `journalctl --user -u dms` for version skew.
- Gate 4 (rollback): pick an older generation from the systemd-boot menu.
