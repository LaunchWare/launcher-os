{ config, lib, ... }:
let
  cfg = config.launcher-os.remoteAccess;
in
{
  options.launcher-os.remoteAccess.enable =
    lib.mkEnableOption "the Cloudflare One client, for reaching the home LAN from outside";

  config = lib.mkIf cfg.enable {
    # Runs the warp-svc daemon as the `cloudflare-warp` systemd unit. The package
    # is unfree; base.nix already allows that. Enrollment is a one-time manual step
    # after the first switch, because it signs in through a browser:
    #   warp-cli registration new <team-name>
    # The device then matches its Cloudflare device profile by the signed-in email.
    services.cloudflare-warp.enable = true;
  };
}
