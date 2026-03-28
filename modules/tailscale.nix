{ config, pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    #extraUpFlags = [ "--advertise-routes=192.168.100.0/24" ];
  };
  #boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
}
