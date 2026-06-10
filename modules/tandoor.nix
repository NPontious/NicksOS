{ config, lib, pkgs, ... }:

{
  options.mySystem.services.tandoor.enable = lib.mkEnableOption "Tandoor Recipes";

  config = lib.mkIf config.mySystem.services.tandoor.enable {
    services.tandoor-recipes = {
      enable = true;
      port = 8082;
      address = "0.0.0.0";
      djangoSecretKeyFile = config.age.secrets."webui-secret-key".path;
      extraConfig = {
        MEDIA_ROOT = "/mnt/storage/Pictures/tandoor";
      };
    };

    age.secrets."webui-secret-key" = {
      file = ../secrets/webui-secret-key.age;
      mode = "0400";
    };
  };
}
