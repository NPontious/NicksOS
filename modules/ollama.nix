{ config, lib, pkgs, ... }:

{
  options.mySystem.services.ollama.enable = lib.mkEnableOption "Ollama and Open-WebUI";

  config = lib.mkIf config.mySystem.services.ollama.enable {
    systemd.tmpfiles.rules = [
      "d /mnt/storage/ollama/models 0750 ollama ollama -"
    ];

    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      port = 11434;
      package = pkgs.ollama-rocm;
      rocmOverrideGfx = "11.0.0";
      loadModels = [
        "gemma4"
        "qwen3.5:4b-q8_0"
        "qwen3.5:9b-q4_K_M"
      ];
    };

    services.open-webui = {
      enable = true;
      host = "0.0.0.0";
      port = 8080; 
      environment = {
        OLLAMA_BASE_URL = "http://127.0.0.1:11434";
      };
    };
  };
}
