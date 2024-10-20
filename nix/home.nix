# vim: set shiftwidth=2:

{ config, pkgs, ... }:

{
    programs.home-manager.enable = true;

    home.username = "maulana.akmal";
    home.homeDirectory = "/Users/maulana.akmal";
    home.stateVersion = "24.05";


    home.file = {
      ".zshrc".source = ~/Work/dotfiles/zsh/.zshrc;
    };
}
