{ config, lib, pkgs, ... }:

{
  options.mySystem.services.paperless.enable = lib.mkEnableOption "Paperless-ngx";

  config = lib.mkIf config.mySystem.services.paperless.enable {
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      port = 6789;
      passwordFile = config.age.secrets."paperless-password".path;
      mediaDir = "/mnt/storage/Documents/paperless/media";
      dataDir = "/mnt/storage/Documents/paperless";
      consumptionDir = "/mnt/storage/Documents/paperless/consume";
      settings = {
        PAPERLESS_OCR_LANGUAGE = "eng+deu";
      };
    };

    age.secrets."paperless-password" = {
      file = ../secrets/paperless-password.age;
      mode = "0400";
      owner = "paperless";
    };
  };
}
