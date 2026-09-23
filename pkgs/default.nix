{
  writeShellApplication,
  chezmoi,
  curl,
  disko,
  git,
  hyprland,
  imagemagick,
  jq,
  mise,
  nixos-install-tools,
  procps,
  util-linux,
  xdg-utils,
}:
{
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
      imagemagick
      xdg-utils
    ];
    text = builtins.readFile ../bin/launcher-os-install-webapp;
  };
}
