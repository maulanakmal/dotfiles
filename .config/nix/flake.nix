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
    self,
    nix-darwin,
    nixpkgs,
    nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle,
    home-manager
    }:
  let
    configuration = { pkgs, ... }:
    let
      gvm = pkgs.stdenv.mkDerivation rec {
        pname = "gvm";
        version = "1.0";

        src = pkgs.fetchFromGitHub {
          # url = "https://github.com/moovweb/gvm.git";
          owner = "moovweb";
          repo = "gvm";
          rev = "master";
          sha256 = "sha256-dRFhvyOVUu1RjUpkjBneFWrCmnvSqO4Gyb6UR4bjboM=";
        };

        installPhase = ''
          mkdir -p $out/share/gvm
          cp -r ${src}/* $out/share/gvm
        '';
      };
      in
    {
      nix.settings.experimental-features = "nix-command flakes";
      services.nix-daemon.enable = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 5;
      programs.zsh.enable = true;  # default shell on catalina

      # system.defaults.finder.AppleShowAllFiles = true;
      system.defaults.finder.ShowPathbar = true;
      system.defaults.finder.ShowStatusBar = true;
      system.defaults.finder.FXPreferredViewStyle = "Nlsv";
      system.defaults.finder.FXDefaultSearchScope = "SCcf";
      # system.defaults.finder.NewWindowTarget = "Home";
      environment.systemPackages =
        [
          gvm
          # for dotfiles symlinking
          pkgs.stow

          pkgs.neofetch

          pkgs.neovim
          pkgs.oh-my-posh
          pkgs.fzf
          pkgs.zoxide

          pkgs.tmux
          pkgs.sesh

          # pkgs.lazygit
          pkgs.jq
          pkgs.yq

          # for gvm (go version manager)
          # pkgs.bison
          # pkgs.mercurial

          # for python version management
          pkgs.pyenv

          pkgs.tree
          pkgs.fd

          # rg, used for nvim-telescope
          pkgs.ripgrep

          pkgs.socat
          pkgs.redis
          pkgs.wget

          pkgs.lnav
          pkgs.jdk
          pkgs.gradle

          pkgs.docker
        ];
    };

    homebrew = {
      nix-homebrew = {
        enable = true;
        mutableTaps = false;
        taps = {
          "homebrew/homebrew-core"      = homebrew-core;
          "homebrew/homebrew-cask"      = homebrew-cask;
          "homebrew/homebrew-bundle"    = homebrew-bundle;
        };
        # autoUpdate = true;
        # upgrade = true;
      };

      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "uninstall";
          extraFlags = [
            "--verbose"
          ];
        };

        casks = [
          "shottr"
          "kitty"
          "font-jetbrains-mono-nerd-font"
          "raycast"
          "alt-tab"
          {
            name = "readdle-spark";
            greedy = true;
          }
        ];


        brews = [
          "lazygit"
          "node"
          "xsv"
          "graphviz" #for plantuml

          "zookeeper"
        ];
      };
    };

  in
  {
    darwinConfigurations = {
      "gojo" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          {
            nixpkgs.hostPlatform = "x86_64-darwin";
          }
          
          # homebrew config
          nix-homebrew.darwinModules.nix-homebrew
          homebrew
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
      "toji" = nix-darwin.lib.darwinSystem {

        modules = [
          configuration
          {
            nixpkgs.hostPlatform = "aarch64-darwin";
          }

          nix-homebrew.darwinModules.nix-homebrew
          homebrew
          {
            nix-homebrew = {
              user = "maulanakmal";
              enableRosetta = true;
            };
          }

          {
            users.users."maulanakmal" = {
              name = "maulanakmal";
              home = "/Users/maulanakmal";
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."maulanakmal" = {pkgs, ...}: {
                # The state version is required and should stay at the version you
                # originally installed.
                home.stateVersion = "24.11";

                home.username = "maulanakmal";
                home.homeDirectory = "/Users/maulanakmal";
                home.packages = [ pkgs.httpie ];
              };
          }


        ];
      };
    };
  };
}
