{ config, lib, pkgs, ... }:

{
  options.mySystem.tailscale.enable = lib.mkEnableOption "Tailscale";

  config = lib.mkIf config.mySystem.tailscale.enable {
    services.tailscale.enable = true;
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
