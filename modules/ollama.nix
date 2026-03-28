{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /mnt/storage/ollama/models 0750 ollama ollama -"
  ];

  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = 11434;
    package = pkgs.ollama-rocm;
    rocmOverrideGfx = "11.0.0";
    #openFirewall = true;
    loadModels = [
      "llama3.2"
      "gemma3"
      "qwen3.5:4b"
      "qwen3.5:9b-q8_0"
      "qwen3.5:9b-q4_K_M"
      "qwen3-embedding:4b-q4_K_M"
    ];
    #environmentVariables = {
    #  OLLAMA_MODELS = "/mnt/storage/ollama/models";
    #};
  };

  services.open-webui = {
    enable = true;
    host = "0.0.0.0";
    port = 8080; 
    #openFirewall = true;
    environment = {
      OLLAMA_BASE_URL = "http://127.0.0.1:11434";
    };
  };
}
