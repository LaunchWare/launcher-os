# madthinkpad Install (Phase 1)

**Scope:** Clean NixOS install on the ThinkPad from the `nix-migration` branch. **The whole disk is
reformatted.** See `05-nixos-migration.md` for the why; this is only the how. Everything below is
scripted; this file only says what to run.

| Partition | Size | Mount |
|---|---|---|
| ESP | 1G | `/boot` |
| swap | 36G | hibernate resume device (32G RAM + headroom) |
| root | 187G | `/` |
| home | rest (~750G) | `/home` |

Declared in `hosts/madthinkpad/disk.nix` (disko), on `/dev/nvme0n1`.

---

## 1. Make the USB stick (on Arch)

Get the **minimal** ISO and its `.sha256` from <https://nixos.org/download> (NixOS 26.05). The
graphical ISO adds nothing here — its installer can't install from a flake.

```sh
sha256sum -c nixos-minimal-26.05*-x86_64-linux.iso.sha256
lsblk -o NAME,SIZE,MODEL,TRAN            # identify the stick by size/model
sudo dd if=nixos-minimal-26.05*-x86_64-linux.iso of=/dev/sdX bs=4M status=progress conv=fsync oflag=direct
```

`of=` is the whole device (`/dev/sda`), not a partition (`/dev/sda1`).

## 2. Boot it

In the ThinkPad BIOS (F1 at power-on): **disable Secure Boot** — systemd-boot is unsigned. Boot the
stick from the F12 menu, then get online with `nmtui`.

## 3. Install

```sh
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:LaunchWare/launcher-os/nix-migration#install -- madthinkpad
```

It shows the target disk and waits for you to type `madthinkpad` before wiping anything, then
partitions, installs (Hyprland and Vicinae come from Cachix; Handy and DMS build locally), and asks
for your user password. Root gets no password — use `sudo`. Reboot when it finishes.

## 4. First login

Log in through the DMS greeter, open a terminal:

```sh
nmtui                                                    # wifi, now on the installed system
los bootstrap https://github.com/dpickett/dotfiles.git
```

`los bootstrap` applies the dotfiles, installs mise toolchains, commits the generated hardware
configuration, and creates the GMail / Calendar / Zoom site-specific browsers. From then on every
change is `los switch`.

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
| Hibernate | `systemctl hibernate`, power on, session is restored |

A missing shared library from a mise binary means `programs.nix-ld.libraries` in
`modules/dev.nix` needs another entry — find it with `LD_DEBUG=libs <binary>`.

## 6. Known gaps

- If the NVMe isn't `/dev/nvme0n1`, the install stops at the confirmation — fix `disk.nix`, push, rerun.
- `hyprmoncfg` comes from nixpkgs-unstable at 1.9.1; madxp runs 1.18.4.
- DMS 1.6.2 runs on nixpkgs' Quickshell 0.3.0; watch `journalctl --user -u dms` for version skew.
- Gate 4 (rollback): pick an older generation from the systemd-boot menu.
