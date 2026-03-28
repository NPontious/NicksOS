{ config, pkgs, ... }:

{
  services.tandoor-recipes = {
    enable = true;
    port = 8082;
    address = "0.0.0.0";
    djangoSecretKeyFile = config.age.secrets."webui-secret-key".path;
    extraConfig = {
      MEDIA_ROOT = "/mnt/storage/Pictures/tandoor";
    };
  };
}
