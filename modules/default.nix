inputs: {
  imports = [
    inputs.dms.nixosModules.default
    inputs.vicinae.nixosModules.default
    inputs.handy.nixosModules.default
    ./base.nix
    (import ./desktop.nix inputs)
    (import ./dev.nix inputs)
    ./apps.nix
    ./printing.nix
    ./laptop.nix
  ];
}
