{ config, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
  };

  users.users.jellyfin = {
    extraGroups = [ "media" ];
  };
}
