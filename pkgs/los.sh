flake="${LAUNCHER_OS_FLAKE:-$HOME/work/launcher-os}"
host="$(uname -n)"

usage() {
  echo "Usage: los switch                        rebuild this host, then chezmoi apply" >&2
  echo "       los bootstrap <dotfiles-repo-url>  one-time setup after the first login" >&2
  echo "Flake: $flake (override with LAUNCHER_OS_FLAKE)" >&2
  exit 1
}

install_ssbs() {
  launcher-os-install-webapp "GMail" "https://mail.google.com" \
    "https://ssl.gstatic.com/ui/v1/icons/mail/rfr/gmail.ico" "x-scheme-handler/mailto"
  launcher-os-install-webapp "Google Calendar" "https://calendar.google.com" \
    "https://calendar.google.com/googlecalendar/images/favicon_v2014_2.ico" \
    "text/calendar;application/ics;x-scheme-handler/webcal"
  launcher-os-install-webapp "Zoom" "https://zoom.us/wc" \
    "https://st1.zoom.us/zoom.ico" "x-scheme-handler/zoom;x-scheme-handler/zoommtg"
}

case "${1:-}" in
  switch)
    sudo nixos-rebuild switch --flake "$flake#$host"
    chezmoi apply
    ;;
  bootstrap)
    dotfiles="${2:-}"
    [[ -n "$dotfiles" ]] || usage

    # Dotfiles first: they carry the git identity the commit below needs.
    chezmoi init --apply "$dotfiles"
    mise install

    hardware="hosts/$host/hardware-configuration.nix"
    if ! git -C "$flake" diff --quiet -- "$hardware"; then
      git -C "$flake" commit -m "chore($host): commit generated hardware configuration" -- "$hardware"
    fi

    if command -v launcher-os-install-webapp >/dev/null; then
      install_ssbs
    fi
    ;;
  *)
    usage
    ;;
esac
