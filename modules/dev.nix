inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.launcher-os.dev;
  user = config.launcher-os.user;
  # Imported rather than legacyPackages so it inherits allowUnfree (claude-code is unfree).
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };
in
{
  options.launcher-os.dev.enable = lib.mkEnableOption "development tooling: docker, nix-ld for mise, postgres";

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    users.users.${user}.extraGroups = [ "docker" ];

    # mise ships precompiled, dynamically linked toolchains (node, ruby) plus native
    # npm/gem extensions. nix-ld's default set has no GL, Wayland/X or NSS, so the
    # list is explicit. Expect to add to it: find the missing lib with
    # `LD_DEBUG=libs <binary>` and append it here.
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc
        zlib
        zstd
        openssl
        curl
        icu
        libuuid
        expat
        libyaml
        glib
        gtk3
        nss
        nspr
        dbus
        at-spi2-atk
        cups
        alsa-lib
        libdrm
        libgbm
        mesa
        libGL
        vulkan-loader
        wayland
        libxkbcommon
        libx11
        libxext
        libxrandr
        libxcb
        libxcomposite
        libxdamage
        libxfixes
        libxtst
        libxrender
        libxi
        libxcursor
        libxscrnsaver
        libxshmfence
        pango
        cairo
        gdk-pixbuf
        freetype
        fontconfig
        libsecret
        libpulseaudio
        libnotify
      ];
    };

    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_18;
      ensureUsers = [
        {
          name = user;
          ensureClauses.superuser = true;
        }
      ];
    };

    environment.systemPackages = [
      # Releases near-daily and can't self-update out of the store; stable lags weeks.
      unstable.claude-code
    ]
    ++ (with pkgs; [
      # C toolchain, the NixOS counterpart to Arch's base-devel: treesitter
      # parsers, cgo, native npm/gem extensions. mise runtimes stay precompiled
      # (all_compile = false in the mise config) and run via nix-ld above.
      gcc
      gnumake
      pkg-config

      caddy
      cloudflared
      docker-buildx
      docker-compose
      lazydocker
      opentofu
      pandoc
      texliveMedium
      valkey
    ]);
  };
}
