let
  nicho_vesania = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBpd06o2ZlbZh+mQ/h59K1DYHL4RragnqxosiCriL+u/ nicho@vesania";
  
  glacio_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDASAHScag9TBoXy0oZKTR67BykcH5g5HTrqLsbABLnl root@glacio";
  vesania_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQmu30vMqi1V8v8iUk3/EF6r8+l+ujSruqq+At7j3oj root@vesania";
  sylva_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm0uYEByEBtVwiP6HWM2JT9enlmjuUiIiFsxmejWgtH root@sylva";

  admins = [ nicho_vesania glacio_host vesania_host sylva_host ];
  systems = [ glacio_host vesania_host sylva_host ];

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
