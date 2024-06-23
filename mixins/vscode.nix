{ pkgs, config, inputs, ... }:
{
  config = {
    home-manager.users.sam = { pkgs, ... }: {
      programs.vscode = {
        enable = true;
        extensions = [ pkgs.vscode-extensions.continue.continue ];
      };
    };
  };
}
