{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = false;
  };
}
