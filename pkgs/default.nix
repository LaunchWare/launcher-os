{
  writeShellApplication,
  actionlint,
  chezmoi,
  curl,
  deadnix,
  desktop-file-utils,
  disko,
  git,
  hyprland,
  imagemagick,
  jq,
  lua5_4,
  mise,
  nixfmt,
  nixos-install-tools,
  procps,
  shellcheck,
  statix,
  util-linux,
  xdg-utils,
}:
{
  check = writeShellApplication {
    name = "launcher-os-check";
    runtimeInputs = [
      actionlint
      deadnix
      git
      jq
      lua5_4
      nixfmt
      shellcheck
      statix
    ];
    text = builtins.readFile ./check.sh;
  };

  los = writeShellApplication {
    name = "los";
    runtimeInputs = [
      chezmoi
      git
      mise
    ];
    text = builtins.readFile ./los.sh;
  };

  install = writeShellApplication {
    name = "launcher-os-install";
    runtimeInputs = [
      disko
      git
      nixos-install-tools
      util-linux
    ];
    text = builtins.readFile ./install.sh;
  };

  launch-or-focus = writeShellApplication {
    name = "launch-os-launch-or-focus.sh";
    runtimeInputs = [
      hyprland
      jq
    ];
    text = builtins.readFile ../bin/launch-os-launch-or-focus.sh;
  };

  restart-app = writeShellApplication {
    name = "launch-os-restart-app.sh";
    runtimeInputs = [
      procps
      util-linux
    ];
    text = builtins.readFile ../bin/launch-os-restart-app.sh;
  };

  install-webapp = writeShellApplication {
    name = "launcher-os-install-webapp";
    runtimeInputs = [
      curl
      desktop-file-utils
      imagemagick
      xdg-utils
    ];
    text = builtins.readFile ../bin/launcher-os-install-webapp;
  };
}
