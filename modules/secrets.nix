{ config, pkgs, agenix, ... }:

{
  age.secrets = {
    "postgres-password" = {
      file = ../secrets/postgres-password.age;
      mode = "0444";
    };
    "openai-access-token" = {
      file = ../secrets/openai-access-token.age;
      mode = "0444";
    };
    "webui-secret-key" = {
      file = ../secrets/webui-secret-key.age;
      mode = "0444";
    };
    "secret-key-base" = {
      file = ../secrets/secret-key-base.age;
      mode = "0444";
    };
    "sure-env" = {
      file = ../secrets/sure-env.age;
      mode = "0444";
    };
    "paperless-password" = {
      file = ../secrets/paperless-password.age;
      mode = "0444";
    };
  };
}
