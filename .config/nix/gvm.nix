{ lib, config, pkgs, ... }:

{
  options.gvm.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable GVM (Go Version Manager)";
  };

  options.gvm.version = lib.mkOption {
    type = lib.types.str;
    default = "1.21.1";
    description = "Default Go version to manage with GVM.";
  };

  config = lib.mkIf config.gvm.enable {
    environment.systemPackages = with pkgs; [
      curl
      bash
      bison
      mercurial
      git
    ];
  };
  #
  #   # home.shellInit = ''
  #   #   export GVM_ROOT="${HOME}/.gvm"
  #   #   if [ -s "${GVM_ROOT}/scripts/gvm" ]; then
  #   #     source "${GVM_ROOT}/scripts/gvm"
  #   #   fi
  #   # '';
  #   #
  #   # home.activation.installGVM = lib.hm.dag.entryAfter [ "writeShellProfile" ] ''
  #   #   if [ ! -d "${HOME}/.gvm" ]; then
  #   #     echo "Installing gvm..."
  #   #     bash -c "$(curl -fsSL https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)"
  #   #   fi
  #   #
  #   #   source "${HOME}/.gvm/scripts/gvm"
  #   #
  #   #   if ! gvm list | grep -q "go${config.gvm.version}"; then
  #   #     echo "Installing Go ${config.gvm.version} with gvm..."
  #   #     gvm install go${config.gvm.version}
  #   #     gvm use go${config.gvm.version} --default
  #   #   fi
  #   # '';
  # };
}

