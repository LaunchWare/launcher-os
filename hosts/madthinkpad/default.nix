# Lenovo ThinkPad, Intel Raptor Lake: CNVi wifi (iwlwifi) and Intel graphics, all in-tree.
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disk.nix
  ];

  networking.hostName = "madthinkpad";

  # Pinned explicitly so kernel and desktop updates stay separate decisions.
  boot.kernelPackages = pkgs.linuxPackages_7_2;

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
  };

  system.stateVersion = "26.05";
}
