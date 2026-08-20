{ config, lib, pkgs, ... }:

{
  options.mySystem.services.tandoor.enable = lib.mkEnableOption "Tandoor Recipes";

  config = lib.mkIf config.mySystem.services.tandoor.enable {
    services.tandoor-recipes = {
      enable = true;
      port = 8082;
      address = "0.0.0.0";
      extraConfig = {
        HOME = "/var/lib/tandoor-recipes";
        MEDIA_ROOT = "/mnt/storage/Pictures/tandoor";
        SECRET_KEY_FILE = config.age.secrets."webui-secret-key".path;
        ALLOWED_HOSTS = "*";
        CSRF_TRUSTED_ORIGINS = "http://glacio:8082,http://100.85.234.127:8082,http://glacio.tail4a2d4d.ts.net:8082";
      };
    };

    age.secrets."webui-secret-key" = {
      file = ../secrets/webui-secret-key.age;
      mode = "0400";
      owner = "tandoor_recipes";
    };
  };
}
