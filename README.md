# launcher-os

A NixOS flake that builds a Hyprland + [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
workstation. `nixos-rebuild switch` is the only way anything gets installed, which is the entire
point: editing the manifest *is* the install mechanism, so it can never drift from the running
machine.

This replaced an Arch/pacman bash installer. The reasoning, and the evidence that the old manifests
had stopped matching reality, is in [`digital-brain/05-nixos-migration.md`](digital-brain/05-nixos-migration.md).

## Layer ownership

The seam that matters. Two tools, no overlap:

| Layer | Owner |
|---|---|
| System, hardware, services, packages | **this flake** |
| `$HOME` dotfiles | **chezmoi**, from a separate repo |

home-manager is a deliberate non-goal — chezmoi already owns `$HOME`, works on macOS too, and is not
what was broken. Same for mise, which still manages language toolchains.

## Layout

| Path | Contents |
|---|---|
| `flake.nix` | Inputs, the `madthinkpad` host, the `install` and `check` apps |
| `modules/` | The `launcher-os.*` options every host composes |
| `hosts/<name>/` | Per-machine hardware, disk layout, option switches |
| `pkgs/` | Scripts packaged with `writeShellApplication` (`los`, the installer, the gates) |
| `default/hypr/` | Hyprland config delivered to `/etc/launcher-os/hypr`, read by chezmoi's `hyprland.lua` |
| `digital-brain/` | Design notes and install runbooks |
| `install/` | **Superseded.** The old Arch bootstrap; nothing here runs it (see below) |

Hosts turn on what they need:

```nix
launcher-os = {
  user = "dpickett";
  desktop.enable = true;   # Hyprland, DMS, greeter, portals
  dev.enable = true;       # docker, postgres, nix-ld for mise toolchains
  apps.enable = true;      # desktop applications
  printing.enable = true;  # printing and scanning
  laptop.enable = true;    # TLP power management
};
```

The base layer — networking, pipewire, bluetooth, fonts, the shell, CLI tooling — is unconditional.

### Inputs

The stable base is `nixos-26.05`. The desktop stack floats, and **each fast-moving input keeps its
own nixpkgs on purpose**: making them follow the stable base is a documented cause of Hyprland build
failures and cache misses. `hyprland`, `dms`, `vicinae` and `handy` are all pinned this way, with
Hyprland's own mesa used for `hardware.graphics` so GL does not break on a version mismatch.

## Installing a machine

Full runbook, including the USB stick and the BIOS settings:
[`digital-brain/06-madthinkpad-install.md`](digital-brain/06-madthinkpad-install.md). **It reformats
the whole disk.** From a booted NixOS minimal ISO:

```sh
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:LaunchWare/launcher-os#install -- madthinkpad
```

It shows the target disk and waits for you to type the hostname before wiping anything. After the
first login:

```sh
los bootstrap https://github.com/dpickett/dotfiles.git
```

## Day to day

```sh
los switch     # nixos-rebuild switch for this host, then chezmoi apply
```

`los` finds the flake at `~/work/launcher-os`; override with `LAUNCHER_OS_FLAKE`. Rolling back is a
previous generation in the systemd-boot menu.

## Checks

One command is the whole gate, and the git hooks and CI both run it:

```sh
nix run .#check            # nixfmt, deadnix, statix, shellcheck, actionlint, lua syntax
nix run .#check -- --full  # the above, plus evaluating every host
nix fmt                    # format the nix sources
```

Enable the hooks once per clone:

```sh
git config core.hooksPath .githooks
```

`pre-commit` runs the file gates against the index (~2s); `pre-push` adds host evaluation (~30s, and
nix caches none of it, which is why it is not on every commit).

CI runs the same `nix run .#check -- --full` plus `nix flake check`, so the hooks and the workflow
cannot drift into disagreeing about what conforms. **CI stops at evaluation on purpose** — the
`madthinkpad` closure is around 23.5 GiB against roughly 14 GiB of disk on a GitHub-hosted runner, so
the build belongs on the machine that is going to boot it.

## The Arch installer

`install/` is the pre-NixOS bootstrap: `pacman`, `paru`, AUR helpers, and `packages/*.txt` manifests.
Nothing in the flake references it and none of it runs on NixOS. It is kept only as a record of what
the old setup installed while the last of it gets ported, and is linted but not otherwise maintained.
`pkgs/install.sh` is the current installer and is unrelated to it.

Some notes under `digital-brain/` predate the migration too — `01-tool-specifications.md` still
describes Waybar, Walker and Mako, which DMS and Vicinae replaced.
