{ config, lib, pkgs, ... }:

{
  options.mySystem.tailscale.enable = lib.mkEnableOption "Tailscale";

  config = lib.mkIf config.mySystem.tailscale.enable {
    services.tailscale = {
      enable = true;
      extraSetFlags = [
        "--operator=${config.mySystem.mainUser}"
        "--accept-dns=false"
      ];
    };
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
