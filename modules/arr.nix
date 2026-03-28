{ config, pkgs, ... }:

{
  services.sonarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.lidarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  services.qbittorrent = {
    enable = true;
    group = "media";
    user = "qbittorrent";
    openFirewall = true;
    webuiPort = 8081;
    
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        General.Locale = "en";
        Connection.PortRangeMin = 55000;
        WebUI = {
          Username = "admin";
          Password_PBKDF2 = "@ByteArray(SulfH08xh5wIjTVGaRLL7g==:oBepPsgTULDnkRSMd3qnH1gFA1jCuVNKZcAYdfOn55ZzenDCCn0/QUcHeRJAYzAVowndZDZ6aRskJ5nLx0iBnQ==)";
          CSRFProtection = true;
        };
      };
    };
  };

  users.groups.media = {};
  users.users.qbittorrent = {
    isSystemUser = true;
    group = "media";
    description = "qBittorrent User";
  };
}
