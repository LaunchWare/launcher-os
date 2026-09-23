{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.launcher-os;
in
{
  options.launcher-os.user = lib.mkOption {
    type = lib.types.str;
    description = "The primary login user; modules add it to the groups they need.";
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 20;
    };
    boot.loader.efi.canTouchEfiVariables = true;

    networking.networkmanager.enable = true;

    time.timeZone = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    zramSwap.enable = true;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    services.fwupd.enable = true;

    programs.zsh.enable = true;

    users.users.${cfg.user} = {
      isNormalUser = true;
      uid = 1000;
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
      ];
    };

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      noto-fonts
      noto-fonts-color-emoji
    ];

    systemd.user.services.tmux = {
      description = "tmux default session (detached)";
      documentation = [ "man:tmux(1)" ];
      wantedBy = [ "default.target" ];
      path = [
        pkgs.tmux
        pkgs.bash
      ];
      environment.DISPLAY = ":0";
      serviceConfig = {
        Type = "forking";
        ExecStart = "${pkgs.tmux}/bin/tmux new-session -d";
        ExecStop = [
          "%h/.config/tmux/plugins/tmux-resurrect/scripts/save.sh"
          "${pkgs.tmux}/bin/tmux kill-server"
        ];
        KillMode = "control-group";
        RestartSec = 2;
      };
    };

    environment.systemPackages =
      (with pkgs; [
        age
        bat
        btop
        chezmoi
        curl
        dnsutils
        dust
        efibootmgr
        ethtool
        exfatprogs
        eza
        fastfetch
        fd
        fzf
        gdu
        gh
        git
        glow
        gum
        imgcat
        jq
        lazygit
        lsof
        mise
        ncdu
        neovim
        ripgrep
        rsync
        sesh
        sops
        starship
        tcpdump
        tmux
        unzip
        viu
        wget
        xclip
        yq
        zoxide
      ])
      ++ [ (pkgs.callPackage ../pkgs { }).los ];
  };
}
