# vim: set shiftwidth=2:
{
  description = "Mol's Darwin System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core   = { url = "github:homebrew/homebrew-core";      flake = false; };
    homebrew-cask   = { url = "github:homebrew/homebrew-cask";      flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle";    flake = false; };

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{
    self, nix-darwin, nixpkgs,
    nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle,
    home-manager
    }:
  let
    common_configuration = {...}: {
      nix.settings.experimental-features = "nix-command flakes";
      services.nix-daemon.enable = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 5;

      programs.zsh.enable = true;  # default shell on catalina
    };

    homebrew_base_config = {
      nix-homebrew = {
        enable = true;
        mutableTaps = false;
        taps = {
          "homebrew/homebrew-core"      = homebrew-core;
          "homebrew/homebrew-cask"      = homebrew-cask;
          "homebrew/homebrew-bundle"    = homebrew-bundle;
        };
      };

      homebrew = {
        enable = true;
        casks = [
          "rectangle"
          "shottr"
          "kitty"
          "font-jetbrains-mono-nerd-font"
        ];
        
      };
    };
    
    configuration = { pkgs, ... }: {
      environment.systemPackages =
        [
          pkgs.neovim
          pkgs.oh-my-posh
          pkgs.fzf
          pkgs.zoxide

          pkgs.tmux
          pkgs.sesh

          pkgs.lazygit

          # for gvm (go version manager)
          pkgs.bison
          pkgs.mercurial

          pkgs.tree
        ];

    };

  in
  {
    darwinConfigurations = {
      "shopee_macbook_pro" = nix-darwin.lib.darwinSystem {
        modules = [
          common_configuration
          configuration
          {
            nixpkgs.hostPlatform = "x86_64-darwin";
          }
          
          # homebrew config
          nix-homebrew.darwinModules.nix-homebrew
          homebrew_base_config
          {
            nix-homebrew = {
              user = "maulana.akmal";
            };
          }


          {
            users.users."maulana.akmal" = {
              name = "maulana.akmal";
              home = "/Users/maulana.akmal";
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."maulana.akmal" = import ./home.nix;
          }
        ];
      };

      # macbook pro 2023 m2 pro
      "mols_macbook_proc" = nix-darwin.lib.darwinSystem {
        modules = [

          nix-homebrew.darwinModules.nix-homebrew
          homebrew_base_config
          {
            nix-homebrew = {
              user = "maulana.akmal";
              enableRosetta = true;
            };
          }
        ];
      };
    };
  };
}
