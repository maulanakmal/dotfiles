# vim: set shiftwidth=2:

{ config, pkgs, ... }:

{
    home.username = "maulana.akmal";
    home.homeDirectory = "/Users/maulana.akmal";
    home.stateVersion = "24.05";

    programs.home-manager.enable = true;
}
