host="${1:-}"
repo="${LAUNCHER_OS_REPO:-https://github.com/LaunchWare/launcher-os.git}"
branch="${LAUNCHER_OS_BRANCH:-nix-migration}"
src=/tmp/launcher-os

if [[ -z "$host" ]]; then
  echo "Usage: launcher-os-install <host>   (repo: $repo, branch: $branch)" >&2
  exit 1
fi

if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo nix run ...#install -- $host" >&2
  exit 1
fi

rm -rf "$src"
git clone --branch "$branch" "$repo" "$src"

config="$src#nixosConfigurations.$host.config"
eval_raw() { nix --extra-experimental-features 'nix-command flakes' eval --raw "$config.$1" "${@:2}"; }
joined=(--apply 'builtins.concatStringsSep " "')

disk=$(eval_raw disko.devices.disk.main.device)
user=$(eval_raw launcher-os.user)
substituters=$(eval_raw nix.settings.extra-substituters "${joined[@]}")
public_keys=$(eval_raw nix.settings.extra-trusted-public-keys "${joined[@]}")

echo
lsblk -o NAME,SIZE,MODEL,FSTYPE,LABEL "$disk"
echo
echo "Installing $host will ERASE EVERYTHING on $disk."
read -rp "Type the host name to continue: " confirmation
if [[ "$confirmation" != "$host" ]]; then
  echo "Aborted; nothing was changed." >&2
  exit 1
fi

disko --mode destroy,format,mount --yes-wipe-all-disks --flake "$src#$host"

nixos-generate-config --no-filesystems --root /mnt --show-hardware-config \
  > "$src/hosts/$host/hardware-configuration.nix"

dest="/mnt/home/$user/work/launcher-os"
mkdir -p "$(dirname "$dest")"
cp -a "$src" "$dest"

nixos-install --no-root-passwd --flake "$dest#$host" \
  --option extra-substituters "$substituters" \
  --option extra-trusted-public-keys "$public_keys"

echo "Set the password for $user:"
nixos-enter --root /mnt -c "passwd $user"
nixos-enter --root /mnt -c "chown -R $user:users /home/$user"

echo
echo "Installed $host. Reboot, log in, then run: los bootstrap <dotfiles-repo-url>"
