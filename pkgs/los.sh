flake="${LAUNCHER_OS_FLAKE:-$HOME/work/launcher-os}"

case "${1:-}" in
  switch)
    sudo nixos-rebuild switch --flake "$flake#$(uname -n)"
    chezmoi apply
    ;;
  *)
    echo "Usage: los switch    (flake: $flake, override with LAUNCHER_OS_FLAKE)" >&2
    exit 1
    ;;
esac
