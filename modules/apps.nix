{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.launcher-os.apps;
in
{
  options.launcher-os.apps.enable = lib.mkEnableOption "desktop applications";

  config = lib.mkIf cfg.enable {
    programs.firefox.enable = true;
    services.flatpak.enable = true;
    virtualisation.waydroid.enable = true;

    environment.systemPackages = with pkgs; [
      alacritty
      cava
      chromium
      dbeaver-bin
      easyeffects
      galculator
      ghostty
      libreoffice-fresh
      mpv
      nautilus
      nwg-displays
      obsidian
      postman
      signal-desktop
      slack
      spotify
      telegram-desktop
      vivaldi
      vscode
      xournalpp
    ];
  };
}
