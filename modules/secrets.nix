{ config, pkgs, agenix, ... }:

{
  age.secrets = {
    "openai-access-token" = {
      file = ../secrets/openai-access-token.age;
      mode = "0400";
    };
  };
}
