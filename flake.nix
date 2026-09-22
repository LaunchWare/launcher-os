{
  description = "launcher-os: a Hyprland + DankMaterialShell workstation on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Fast-moving desktop stack. Each keeps its own nixpkgs on purpose: following
    # the stable base is a documented cause of Hyprland build failures and cache misses.
    hyprland.url = "github:hyprwm/Hyprland";
    dms.url = "github:AvengeMedia/DankMaterialShell/stable";
    vicinae.url = "github:vicinaehq/vicinae";
    handy.url = "github:cjpais/Handy";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      mkHost =
        hostName:
        nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.default
            ./hosts/${hostName}
          ];
        };
    in
    {
      nixosModules.default = import ./modules inputs;

      nixosConfigurations.madthinkpad = mkHost "madthinkpad";
    };
}
