let
  nicho_vesania = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBpd06o2ZlbZh+mQ/h59K1DYHL4RragnqxosiCriL+u/ nicho@vesania";
  
  glacio_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDASAHScag9TBoXy0oZKTR67BykcH5g5HTrqLsbABLnl root@glacio";
  vesania_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQmu30vMqi1V8v8iUk3/EF6r8+l+ujSruqq+At7j3oj root@vesania";
  sylva_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBn2c/9xEqfTocaT2HfIAjEKYgJytv/dUq5Kr9TDdhCv root@sylva";
  desolo_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINhXX59EL8xxxnMQkaPYD+J1s70JXiAPFqBlPSNsFYDJ root@nixos";
  
  admins = [ nicho_vesania ];
  hosts = [ glacio_host vesania_host sylva_host desolo_host ];

  # Groups
  all_hosts = admins ++ hosts;
  glacio_only = admins ++ [ glacio_host ];
in
{
  "postgres-password.age".publicKeys = glacio_only;
  "openai-access-token.age".publicKeys = all_hosts;
  "webui-secret-key.age".publicKeys = glacio_only;
  "secret-key-base.age".publicKeys = glacio_only;
  "sure-env.age".publicKeys = glacio_only;
  "paperless-password.age".publicKeys = glacio_only;
  "windscribe-creds.age".publicKeys = glacio_only;
}
