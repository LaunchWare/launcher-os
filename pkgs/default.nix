{
  writeShellApplication,
  chezmoi,
  curl,
  hyprland,
  imagemagick,
  jq,
  procps,
  util-linux,
  xdg-utils,
}:
{
  los = writeShellApplication {
    name = "los";
    runtimeInputs = [ chezmoi ];
    text = builtins.readFile ./los.sh;
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
