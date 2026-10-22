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
    # AppImages assume an FHS layout that NixOS does not have, so they cannot be
    # executed directly: appimage-run unpacks each one into an FHS sandbox built
    # from the same base as appimageTools. binfmt registers the type-1 and type-2
    # AppImage magic with the kernel, so a `chmod +x`'d image runs as
    # `./Foo.AppImage` rather than needing `appimage-run ./Foo.AppImage`. An image
    # that still misses a library wants
    # `package = pkgs.appimage-run.override { extraPkgs = pkgs: [ ... ]; }`.
    programs.appimage = {
      enable = true;
      binfmt = true;
    };

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
