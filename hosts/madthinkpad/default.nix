# Lenovo ThinkPad, Intel Raptor Lake: CNVi wifi (iwlwifi) and Intel graphics, all in-tree.
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
  ];

  networking.hostName = "madthinkpad";

  # Mainline, not a pinned series. An explicit linuxPackages_X_Y does not actually
  # defer the decision: nixpkgs deletes the attribute at upstream EOL and evaluation
  # fails until it is bumped, so the move happens on upstream's schedule either way.
  # This way it happens on `nix flake update nixpkgs` instead, where
  # `nix store diff-closures` shows it before the switch and a bad kernel is one
  # boot-menu generation away from undone. Safe here because this ThinkPad is all
  # in-tree (i915, iwlwifi); a host whose hardware is under investigation wants a
  # fixed series instead, so kernel version stays a variable it can bisect.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.sof-firmware ];
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

  launcher-os = {
    user = "dpickett";
    desktop.enable = true;
    dev.enable = true;
    apps.enable = true;
    printing.enable = true;
    laptop.enable = true;
    remoteAccess.enable = true;
  };

  system.stateVersion = "26.05";
}
