{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.launcher-os.printing;
in
{
  options.launcher-os.printing.enable = lib.mkEnableOption "printing and scanning";

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;

    hardware.sane = {
      enable = true;
      brscan4.enable = true;
    };
    users.users.${config.launcher-os.user}.extraGroups = [
      "scanner"
      "lp"
    ];

    environment.systemPackages = [ pkgs.simple-scan ];
  };
}
