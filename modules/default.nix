inputs: {
  imports = [
    inputs.dms.nixosModules.default
    inputs.vicinae.nixosModules.default
    inputs.handy.nixosModules.default
    ./base.nix
    (import ./desktop.nix inputs)
    ./dev.nix
    ./apps.nix
    ./printing.nix
    ./laptop.nix
  ];
}
