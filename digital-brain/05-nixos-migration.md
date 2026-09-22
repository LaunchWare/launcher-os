# NixOS Migration Plan

**Date:** 2026-09-22
**Status:** Phase 1 in progress — flake builds for `madthinkpad`; install guide in `06-madthinkpad-install.md`
**Scope:** Replace launcher-os's Arch/pacman bash installer with a NixOS flake. Both machines end on NixOS.

---

## 1. Why

**Consistency across two machines** is the driver. Not reproducibility-for-its-own-sake, not
bleeding-edge packages, not dev-environment purity.

The mechanical problem: **the manifest is a second step.** `paru -S ghostty` produces a working
ghostty; editing `install/bootstrap/packages/apps.txt` produces nothing today. The manifest edit is
unpaid work with no immediate reward, so it gets skipped. Nothing ever reconciles the lists against
reality.

Evidence found in the repo on 2026-09-22:

| Symptom | Detail |
|---|---|
| Installs hardware that doesn't exist | `nvidia-dkms`, `nvidia-utils`, `lib32-nvidia-utils`, `libva-nvidia-driver` — madxp is AMD now |
| Installs hardware that doesn't exist | `broadcom-wl-dkms` — the ThinkPad is Intel CNVi |
| Installs tooling for a filesystem not in use | `limine-snapper-sync` — every filesystem is ext4, no btrfs, no subvolumes, **no snapshots** |
| Software in no manifest at all | `ghostty`, `handy` (both referenced in live `hyprland.lua`) |
| Services in no manifest at all | `hyprmoncfgd.service`, `llama.socket`, `tmux.service`, `daily-briefing.timer`, `satcom.timer` |
| Live config drifted from its own source | `~/.config/hypr/hyprland.lua` ≠ `dot_config/hypr/hyprland.lua.tmpl` (nvidia conditional missing, `vicinae server` added) |
| No reconciliation possible | `pacman -S --noconfirm` with no `--needed`, no removal pass |

**What NixOS changes:** `nixos-rebuild switch` is the *only* way to install anything. The manifest
edit stops being optional because it is the install mechanism. That is the whole thesis. Everything
else is secondary.

---

## 2. Non-goals

Explicitly out of scope. Each of these is a plausible-sounding expansion that would stall the migration:

- **home-manager.** chezmoi stays and keeps owning `$HOME`. It is cross-platform (live macOS branch),
  considerate to others, and is not what's broken.
- **Replacing mise.** Same reasoning — cross-platform, considerate to collaborators on client repos.
- **Per-project devshells / direnv.** Maybe later on repos we own; never as part of this migration.
  ~30 repos in `~/work`, most not ours.
- **A shared manifest that generates both pacman and Nix.** Package names don't map 1:1
  (`ttf-firacode-nerd` → `nerd-fonts.fira-code`; `vicinae-bin` → a flake input;
  `dms-shell-git` → `homeModules.dank-material-shell`). Building a translation layer for something
  we intend to delete in weeks is a tarpit.
- **Full rolling.** Stable base; only the WM stack floats.

---

## 3. Architecture

### 3.1 Layer ownership (unchanged seam, new implementation)

| Layer | Owner | Notes |
|---|---|---|
| System, hardware, services, packages | **launcher-os** (NixOS flake) | Everything that is a `pacman -S` today |
| `$HOME` dotfiles | **chezmoi** | Unchanged, 137 files |

The existing coupling survives with a one-string change. `~/.config/hypr/hyprland.lua` currently does:

```lua
local launcher_os = "/usr/local/share/launcher-os/default/hypr/"
```

becomes `/etc/launcher-os/hypr/`, delivered via `environment.etc`. This also removes the
`rm -rf`-the-install-dir behaviour in `install/config/copy-root.sh` entirely.

Apply is one habit, two steps — wrap it:

```sh
los switch   # nixos-rebuild switch --flake .#$(hostname) && chezmoi apply
```

### 3.2 Channel strategy — stable base, desktop floating

```nix
inputs = {
  # Base: kernel, systemd, glibc, mesa, docker, postgresql_18
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  # Leaf packages we want current, via overlay (ghostty, handy, CLI tools)
  nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

  # Fast-moving desktop stack — each brings its own nixpkgs, deliberately NOT followed
  hyprland.url = "github:hyprwm/Hyprland";
  dms.url      = "github:AvengeMedia/DankMaterialShell";
  vicinae.url  = "github:vicinaehq/vicinae";
};
```

Rationale: kernel/glibc/systemd/Docker/Postgres move twice a year on a tested set, identically on
both machines — more stable than Arch today. The WM stays current enough for DMS, which builds
Quickshell from source because it needs unreleased Quickshell features.

**Do not** force the desktop inputs to follow stable nixpkgs. "One nixpkgs followed everywhere" is
correct only when that nixpkgs is unstable; on a stable base it's a documented cause of Hyprland
build failures.

Two hard requirements that follow:
- **Configure Hyprland's Cachix substituters *before* adding Hyprland as an input.** Otherwise the
  first `switch` compiles Hyprland and Quickshell from source. Check for a DMS cache too.
- If `hyprland-plugins` is ever added, it must `follows = "hyprland"`.
- `boot.kernelPackages` pinned explicitly, so kernel updates and desktop updates are separate
  decisions. This is the lever for bisecting the unresolved **amdgpu S3-resume bug** on madxp across
  generations instead of hand-pinning kernels.
- `flake.lock` is committed. `nix flake update` is the new `pacman -Syu`; a bad update is a `git revert`.

### 3.3 Repo layout

```
launcher-os/                        # branch: nixos
├── flake.nix                       # inputs, both hosts, nixosModules.default
├── hosts/
│   ├── madxp/
│   │   ├── default.nix             # AMD, /home reuse, gaming, localLlm
│   │   └── hardware-configuration.nix
│   └── madthinkpad/
│       ├── default.nix             # Intel, laptop
│       └── hardware-configuration.nix
├── modules/
│   ├── base.nix                    # networking, pipewire, bluetooth, shell, fonts, CLI tools
│   ├── desktop.nix                 # hyprland, dms, vicinae, handy, portals
│   ├── dev.nix                     # docker, nix-ld, postgres
│   ├── apps.nix                    # GUI applications
│   ├── printing.nix                # cups, sane, brscan4
│   ├── gaming.nix                  # steam
│   ├── localLlm.nix                # llama socket unit + model path
│   └── laptop.nix                  # lid, backlight, power profiles
├── pkgs/                           # bin/*.sh as writeShellApplication, `los`
├── default/hypr/*.lua              # → /etc/launcher-os/hypr via environment.etc; moves to etc/hypr in Phase 4
└── install/                        # DEAD — untouched until madxp flips, then deleted
```

### 3.4 Module design — option-based opt-in

Every module is always imported; its body is wrapped in `lib.mkIf cfg.enable` under a
`launcher-os.*` namespace. Hosts become readable feature declarations:

```nix
# hosts/madxp/default.nix
launcher-os = {
  desktop.enable  = true;
  desktop.shell   = "dms";
  dev.enable      = true;
  dev.docker      = true;
  dev.postgres    = true;     # satcom + tcs worktree DBs
  gaming.enable   = true;     # /mnt/storage library
  localLlm.enable = true;     # llama.socket + ~/models (21GB Qwen GGUF)
};

# hosts/madthinkpad/default.nix
launcher-os = {
  desktop.enable  = true;
  desktop.shell   = "dms";
  dev.enable      = true;
  dev.docker      = true;
  laptop.enable   = true;
};
```

**The diff between those two files is the intended difference between the machines.** Anything that
drifts becomes a visible line rather than an invisible omission. That artifact is what's missing today.

Guardrails:
- Export `nixosModules.default` from `flake.nix` — the one thing that makes this consumable by
  someone who isn't us. Costs nothing now, delivers the "others can use and extend it" intent later.
- **Start with `enable` flags only.** Add a real option the first time a second host actually needs
  to differ. Speculative option surfaces are how these repos rot.
- **Modules own their whole vertical** — `localLlm.enable` brings the systemd socket unit, the model
  path, *and* the package. This is precisely what `packages/*.txt` structurally cannot do, and why
  `llama.socket` and `hyprmoncfgd.service` live in neither repo today.

### 3.5 Dev toolchain — mise survives via nix-ld

mise distributes precompiled, dynamically-linked binaries (node ×6, bun, temurin-17, maestro, and
now precompiled Ruby). NixOS has no `/lib64/ld-linux-x86-64.so.2`, so these fail to exec.

```nix
programs.nix-ld.enable = true;
programs.nix-ld.libraries = with pkgs; [ /* explicit list */ ];
```

**The known trap:** enabling `nix-ld` and leaving `libraries` unset. The default set is derived from
systemd and nix only — **no libGL, no Wayland/X client libs, no NSS**. Things appear to work until a
toolchain binary needs graphics or DNS. Populate it deliberately on day one and expect to add to it.

Also affects: native npm deps (esbuild, sharp, prisma engines) and native gems (pg, nokogiri, ffi).

---

## 4. Phases

### Phase 0 — Pre-work, on Arch, nothing destructive

1. **Recover the true package set.** The manifests are fiction; the machine is truth.
   ```sh
   pacman -Qqe > /tmp/actually-installed.txt
   # diff against the union of install/bootstrap/packages/*.txt
   ```
   This is the real input to the Nix translation — not the `.txt` files.
2. Inventory hand-installed software: `ghostty`, `handy`, `hyprmoncfgd`, anything else the diff finds.
3. Inventory custom user units: `hyprmoncfgd.service`, `llama.socket`, `tmux.service`,
   `daily-briefing.timer`, `satcom.timer`. Find where each is currently defined; decide module owner.
4. Confirm Hyprland/DMS Cachix endpoints and keys.
5. Map AUR → Nix. Known-good: `vicinae` (nixpkgs + own flake w/ `services.vicinae`),
   DMS (`homeModules.dank-material-shell` / NixOS module), `quickshell`, `matugen`, `sesh`, `handy`
   (upstream flake), `slack`/`obsidian`/`vivaldi`/`dbeaver` (unfree — needs `allowUnfree`).
   **Note: the AUR-heaviest packages have *better* Nix support than Arch support** — `-git` AUR
   packages become properly pinned flake inputs.

### Phase 1 — ThinkPad install (greenfield, nothing at risk)

Hardware is the best case for NixOS: Intel Raptor Lake CNVi (`iwlwifi`) + Intel graphics, both
in-tree, mesa, **zero DKMS**.

1. Partition **mirroring madxp deliberately**: ESP + `/` + **separate `/home`** + **a real swap
   partition** (≥ RAM if hibernate is ever wanted). Separate `/home` is what makes the madxp flip a
   two-hour job later; real swap addresses the other half of the suspend bug class.
2. Minimal NixOS install, flake skeleton, `base.nix` only. Boot to console. Commit.
3. Add `desktop.nix` — Hyprland + DMS + Vicinae. **Cachix configured before the first `switch`.**
4. Add `dev.nix` — Docker, `nix-ld` + libraries, mise toolchains verified actually executing.
5. `chezmoi init` + apply. Change the one path string in `hyprland.lua.tmpl`
   (`/usr/local/share/launcher-os/default/hypr/` → `/etc/launcher-os/hypr/`).
   **While here, fix the drift:** reconcile the template against what's actually on madxp, and drop
   the dead `lookPath "nvidia-smi"` conditional.
6. Port `bin/*.sh` to `writeShellApplication` with declared deps (`jq`, `hyprctl`).

### Phase 2 — Exit gates (a week of real use, decided in advance)

| # | Gate | Tests |
|---|---|---|
| 1 | A full workday on the ThinkPad — Synchrony/TCS, Claude Code, Docker, mise — with no drop back to Arch | Feasibility |
| 2 | Desktop parity: vicinae, DMS, keybinds, SSBs, chezmoi dotfiles behave identically to madxp | Consistency |
| 3 | **Added something mid-week — package, keybind, or service — in one `switch`, with no separate manifest edit to forget** | **The actual thesis** |
| 4 | Broke something deliberately and rolled back from the boot menu | Trust, before betting client DBs on it |

Gate 3 is the one that matters. Gates 1–2 test feasibility; gate 4 buys the confidence to do Phase 3.

**Timebox: ~1 month.** If the ThinkPad is still the only NixOS box after that, the experiment failed —
revert it to Arch. A permanent two-OS split is strictly worse than today's status quo.

### Phase 3 — madxp cutover

Disk layout makes this far less scary than it sounds:

| Partition | Size | Fate |
|---|---|---|
| `nvme0n1p1` `/boot` 1G vfat | | Reused as ESP |
| `nvme0n1p2` `/` 114G ext4 | | **Formatted** |
| `nvme0n1p3` `/home` 362G ext4 | | **Mounted as-is, never formatted** |
| `sda2` `/mnt/storage` 931G ext4 | | Untouched (also the backup target) |

`/home` is its own partition, so `~/models` (21GB Qwen GGUF), all of `~/work`, and the vault are
never at risk. UID is already 1000.

**The complete at-risk inventory** (everything on `/`):

1. **System PostgreSQL 18.6** at `/var/lib/postgres` — the only real casualty.
   `tcs-base/scripts/worktree-utils/common.sh` runs `createdb`/`dropdb`/`pg_dump` per worktree
   against this. satcom and TCS compliance data live here.
2. `open-webui` docker volume — chat history.
3. `personal-wiki_n8n_data` docker volume — workflows plus **encrypted credentials; capture the
   encryption key too or the restore is useless**.
4. Regenerable, ignore: 23.5GB images, 28.8GB build cache, buildkit state.
5. **Zero state:** the three Synchrony redis containers — `docker inspect` shows no mounts at all.

Procedure:

```sh
# 1. Postgres
sudo -u postgres pg_dumpall > /mnt/storage/backup/pgdumpall-$(date +%F).sql
# 2. Volumes
for v in open-webui personal-wiki_n8n_data; do
  docker run --rm -v $v:/v -v /mnt/storage/backup:/b alpine \
    tar czf /b/$v-$(date +%F).tar.gz -C /v .
done
# 3. VERIFY BEFORE TOUCHING ANYTHING — restore the dump into a throwaway container and diff
```

Then: install NixOS formatting `/` only, mount `/home` and `/mnt/storage` in place, `switch` with
`hosts/madxp`, restore. Pin `services.postgresql.package = pkgs.postgresql_18` to match 18.6 — NixOS
uses `/var/lib/postgresql/18` with its own initdb locale defaults, so **restore from dump; do not
point NixOS at the Arch `PGDATA`**.

Add real swap while here (currently zram-only 4G, implicated in the ENOMEM-at-suspend-entry issue).

Accepted cost: Arch-era cruft in `~/.config` and `~/.local/state` comes along. Take it over purity.

### Phase 4 — Cleanup

- Delete `install/` and `default/` in one commit.
- Merge the `nixos` branch.
- Update `digital-brain/02-preinstall-requirements.md` and `03-script-architecture.md`, which now
  describe a system that no longer exists. Keep `01-tool-specifications.md` and
  `site-specific-browsers.md` — still accurate.
- Remove `bin/launcher-os-install-webapp`'s assumptions about `/usr/local/share`.

---

## 5. Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| `nix-ld` libraries under-specified; mise binaries fail obscurely | High | Populate `libraries` explicitly on day one; expect iteration |
| First `switch` compiles Hyprland + Quickshell from source | High if unmitigated | Cachix configured *before* adding the flake input |
| Desktop-stack version skew (Hyprland/Quickshell/DMS) | Medium | Let desktop inputs carry their own nixpkgs; never follow stable |
| Postgres restore loses satcom/TCS data | Low, high impact | Verify the dump by restoring into a container *before* formatting |
| n8n creds unrecoverable without encryption key | Medium | Capture the key alongside the volume tarball |
| Two-OS window becomes permanent | Medium | 1-month timebox with an explicit revert-to-Arch outcome |
| Scope creep into devshells / home-manager | Medium | Listed as non-goals above; re-read before saying yes |
| NixOS 26.11 lands mid-migration | Certain (~Nov) | Stay on 26.05 until both machines are migrated; bump deliberately after |

---

## 6. Open items to verify before Phase 1

- [ ] Exact Hyprland + DMS Cachix substituters and public keys
- [ ] ThinkPad RAM (sizes the swap partition; decides hibernate)
- [ ] Whether the ThinkPad has a discrete GPU that's disabled vs absent
- [ ] Where `hyprmoncfgd.service`, `tmux.service`, `llama.socket`, and the two timers are defined today
- [ ] Steam library path under `/mnt/storage` and whether Proton prefixes live there (they should
      survive untouched; `programs.steam.enable` on the NixOS side)
- [ ] `pacman -Qqe` diff against the manifests — the real translation input
