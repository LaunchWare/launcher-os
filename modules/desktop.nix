inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.launcher-os.desktop;
  system = pkgs.stdenv.hostPlatform.system;
  hyprlandFlake = inputs.hyprland.packages.${system};
  hyprlandPkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
  launcherPkgs = pkgs.callPackage ../pkgs { hyprland = config.programs.hyprland.package; };
in
{
  options.launcher-os.desktop.enable = lib.mkEnableOption "the Hyprland + DankMaterialShell desktop";

  config = lib.mkMerge [
    # The upstream module defaults this to true, so it has to be switched off explicitly.
    { programs.vicinae.input-server.enable = lib.mkDefault cfg.enable; }

    (lib.mkIf cfg.enable {
      nix.settings = {
        extra-substituters = [
          "https://hyprland.cachix.org"
          "https://vicinae.cachix.org"
        ];
        extra-trusted-public-keys = [
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
        ];
      };

      programs.hyprland = {
        enable = true;
        withUWSM = true;
        package = hyprlandFlake.hyprland;
        portalPackage = hyprlandFlake.xdg-desktop-portal-hyprland;
      };

      # Hyprland from its flake links against its own nixpkgs' mesa; a mismatched
      # system mesa breaks GL. Per the Hyprland wiki's NixOS instructions.
      hardware.graphics = {
        enable = true;
        package = hyprlandPkgs.mesa;
        enable32Bit = true;
        package32 = hyprlandPkgs.pkgsi686Linux.mesa;
      };

      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

      # GTK apps take the cursor from gsettings, not XCURSOR_THEME; match env.lua.
      # icon-theme is what QT_QPA_PLATFORMTHEME=gtk3 hands Qt, and it is also what
      # DMS probes for its own lookup, so the named theme has to actually exist:
      # Qt stops at a missing theme instead of falling through to hicolor, which
      # left app and tray icons blank.
      programs.dconf.profiles.user.databases = [
        {
          settings."org/gnome/desktop/interface" = {
            cursor-theme = "Bibata-Modern-Classic";
            cursor-size = lib.gvariant.mkInt32 24;
            icon-theme = "Adwaita";
          };
        }
      ];

      environment.etc."launcher-os/hypr".source = ../default/hypr;

      programs.dank-material-shell = {
        enable = true;
        systemd.enable = true;
      };

      services.displayManager.dms-greeter = {
        enable = true;
        # Defaults to nixpkgs' older dms-shell, whose launcher writes a hyprlang
        # config that Lua-era Hyprland rejects. Use the same DMS as the shell.
        package = config.programs.dank-material-shell.package;
        compositor.name = "hyprland";
        configHome = config.users.users.${config.launcher-os.user}.home;
      };

      programs.handy.enable = true;
      users.users.${config.launcher-os.user}.extraGroups = [ "input" ];

      programs.hyprlock.enable = true;
      services.hypridle.enable = true;

      systemd.user.services.hyprpolkitagent = {
        description = "Hyprland Polkit Authentication Agent";
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        unitConfig.ConditionEnvironment = "WAYLAND_DISPLAY";
        serviceConfig = {
          ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
          Slice = "session.slice";
          TimeoutStopSec = "5sec";
          Restart = "on-failure";
        };
      };

      systemd.user.services.hyprmoncfgd = {
        description = "Hyprland monitor profile daemon (hyprmoncfgd)";
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${unstable.hyprmoncfg}/bin/hyprmoncfgd";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };

      environment.systemPackages =
        (with pkgs; [
          adwaita-icon-theme
          bibata-cursors
          brightnessctl
          cliphist
          colloid-gtk-theme
          dotool
          grim
          hyprpicker
          hyprshot
          hyprsunset
          libsForQt5.qtwayland
          matugen
          pamixer
          pavucontrol
          playerctl
          qt6.qtwayland
          qt6Packages.qt6ct
          slurp
          swayosd
          wl-clipboard
          wtype
        ])
        ++ [
          config.programs.vicinae.input-server.package
          unstable.hyprmoncfg
        ]
        ++ (with launcherPkgs; [
          launch-or-focus
          restart-app
          install-webapp
        ]);
    })
  ];
}
