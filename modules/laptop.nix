{ config, lib, ... }:
let
  cfg = config.launcher-os.laptop;
in
{
  options.launcher-os.laptop.enable = lib.mkEnableOption "laptop power management";

  config = lib.mkIf cfg.enable {
    services.power-profiles-daemon.enable = true;
    services.thermald.enable = true;
    services.upower.enable = true;
  };
}
