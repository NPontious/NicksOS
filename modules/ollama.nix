{ config, lib, pkgs, ... }:

{
  options.mySystem.services.ollama.enable = lib.mkEnableOption "Ollama and Open-WebUI";

  config = lib.mkIf config.mySystem.services.ollama.enable {
    services.ollama = {
      enable = true;
      host = "0.0.0.0";
      port = 11434;
      package = lib.mkDefault (
        if config.mySystem.hardware.nvidia.enable or false
        then pkgs.ollama-cuda
        else pkgs.ollama-vulkan
      );
      environmentVariables = {
        OLLAMA_KEEP_ALIVE = "1h";
      } // lib.optionalAttrs (! (config.mySystem.hardware.nvidia.enable or false)) {
        OLLAMA_IGPU_ENABLE = "1";
      };
      loadModels = [
        "mxbai-embed-large"
        "qwen3.5:4b-q8_0"
        "qwen3.5:9b-q4_K_M"
        "gemma4:latest"
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

    nixpkgs.overlays = [
      (final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (pyFinal: pyPrev: {
            posthog = pyPrev.posthog.overridePythonAttrs (old: {
              meta = old.meta // { broken = false; };
              doCheck = false;
            });
            mcp = pyPrev.mcp.overridePythonAttrs (old: {
              postPatch = (old.postPatch or "") + ''
                cat << 'EOF' >> src/mcp/client/streamable_http.py

from typing import Any

@asynccontextmanager
async def streamablehttp_client(
    url: str,
    *,
    headers: dict[str, str] | None = None,
    auth: Any = None,
    httpx_client_factory: Any = None,
    timeout: float | None = None,
    sse_read_timeout: float | None = None,
    terminate_on_close: bool = True,
    **kwargs,
):
    if httpx_client_factory is not None:
        client = httpx_client_factory(headers=headers, timeout=timeout, auth=auth)
    else:
        client = httpx2.AsyncClient(headers=headers, auth=auth, timeout=timeout)
    async with streamable_http_client(url, http_client=client, terminate_on_close=terminate_on_close) as streams:
        yield (streams[0], streams[1], None)
EOF
              '';
              doCheck = false;
            });
          })
        ];
      })
    ];
  };
}
