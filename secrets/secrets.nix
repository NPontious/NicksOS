let
  nicho_vesania = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBpd06o2ZlbZh+mQ/h59K1DYHL4RragnqxosiCriL+u/ nicho@vesania";
  
  glacio_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDASAHScag9TBoXy0oZKTR67BykcH5g5HTrqLsbABLnl root@glacio";
  vesania_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQmu30vMqi1V8v8iUk3/EF6r8+l+ujSruqq+At7j3oj root@vesania";
  sylva_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBn2c/9xEqfTocaT2HfIAjEKYgJytv/dUq5Kr9TDdhCv root@sylva";
  desolo_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINhXX59EL8xxxnMQkaPYD+J1s70JXiAPFqBlPSNsFYDJ root@nixos";
  
  admins = [ nicho_vesania glacio_host vesania_host sylva_host desolo_host ];
  systems = [ glacio_host vesania_host sylva_host desolo_host ];

  all = admins ++ systems;
in
{
  "postgres-password.age".publicKeys = all;
  "openai-access-token.age".publicKeys = all;
  "webui-secret-key.age".publicKeys = all;
  "secret-key-base.age".publicKeys = all;
  "sure-env.age".publicKeys = all;
  "paperless-password.age".publicKeys = all;
  "test-secret.age".publicKeys = all;
}
