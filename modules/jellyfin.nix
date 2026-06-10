{ config, lib, pkgs, ... }:

{
  options.mySystem.services.jellyfin.enable = lib.mkEnableOption "Jellyfin Media Server";

  config = lib.mkIf config.mySystem.services.jellyfin.enable {
    services.jellyfin.enable = true;
    users.users.jellyfin.extraGroups = [ config.mySystem.mediaGroup ];
  };
}
