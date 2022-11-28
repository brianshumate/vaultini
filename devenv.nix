{ pkgs, ... }: {

  env.VAULT_ADDR = "http://127.0.0.1:8200";

  packages = [ pkgs.curl pkgs.jq pkgs.vault pkgs.terraform ];

  enterShell = ''
    echo "[vaultini][devenv]"
    make
  '';

}
