# vim: set shiftwidth=2:

{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;

  home.username = "maulana.akmal";
  home.homeDirectory = "/Users/maulana.akmal";
  home.stateVersion = "24.05";

  # need to add --impure args to darwin-rebuild
  home.file = {
    # ".zshrc".source         = ~/dotfiles/zsh/.zshrc;
    # ".tmux.conf".source     = ~/dotfiles/tmux/.tmux.conf;
    # ".config/kitty".source  = ~/dotfiles/kitty;
    # ".config/nvim".source   = ~/dotfiles/nvim;
  };
}
