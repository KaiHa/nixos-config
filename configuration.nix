# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
   not_required_for_online = ''
     [Link]
     RequiredForOnline=no
     '';
in
with pkgs; {
  imports = [
    ./hardware-configuration.nix
    ./services.nix
    ./systemPackages.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      # chromium.enablePepperFlash = true;
    };
    overlays = [( self: super: rec {
      gnupg = super.gnupg.override { pinentry = pinentry; };
      lbdb = super.lbdb.override { inherit gnupg; goobook = python27Packages.goobook; };
      zathura = super.zathura.override { synctexSupport = false; };
      linux_4_19 = super.linux_4_19.override { modDirVersion = "4.19.34-hardened"; };
    })];
  };

  nix.useSandbox = "relaxed";

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";


  systemd = {
    network = {
      enable = true;
      networks = {
        "10-wwp0s20u4i6"= {
          name = "wwp0s20u4i6";
          extraConfig = not_required_for_online;
        };
        "10-ens5" = {
          name = "ens5";
          DHCP = "yes";
        };
        "11-virbr" = {
          name = "virbr*";
          extraConfig = not_required_for_online;
        };
      };
    };
  };

  hardware = {
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
    nitrokey.enable = true;
    pulseaudio.enable = true;
  };

  powerManagement = {
    powertop.enable = false;
  };

  boot = {
    kernelPackages = linuxPackages_hardened;
    cleanTmpDir = true;

    loader = {
      grub.enable = true;
      grub.version = 2;
      grub.device = "/dev/sda";
    };
    supportedFilesystems = [ "nfs4" ];
  };


  fileSystems."/".options     = ["defaults" "noatime" "nodiratime"];
  fileSystems."/boot".options = ["defaults" "noatime" "nodiratime"];

  networking = {
    hostName = "c20";
    wireless.enable = false;  # Enables wireless support via wpa_supplicant.
    useDHCP = false;  # Provided by networkd
    useNetworkd = true;
    firewall.allowPing = false;
    firewall.allowedTCPPorts = [5232];
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    consoleColors = [ "000000" "dc322f" "859900" "b58900" "268bd2" "d33682"
                      "2aa198" "eee8d5" "002b36" "cb4b16" "586e75" "657b83"
                      "839496" "6c71c4" "93a1a1" "fdf6e3" ];
  };

  sound.enableOSSEmulation = false;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = [
      corefonts
      hack-font
      inconsolata
      liberation_ttf
      noto-fonts-emoji
      powerline-fonts
      symbola
      ubuntu_font_family
      unifont
    ];
  };

  programs = {
    bash.enableCompletion = true;
    chromium.enable = true;
    chromium.extensions = [ "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    ];
    command-not-found.enable = true;
    # Disable gnupg/ssh agent because it conflicts with ssh-agent forwarding
    #gnupg.agent.enable = true;
    #gnupg.agent.enableSSHSupport = true;
    mosh.enable = true;
    ssh.startAgent = false;
    tmux = {
      enable = true;
      escapeTime = 0;
      shortcut = "a";
      terminal = "tmux-256color";
      extraTmuxConf = ''
        run-shell ${pkgs.tmuxPlugins.urlview}/share/tmux-plugins/urlview/urlview.tmux
        run-shell ${pkgs.tmuxPlugins.open}/share/tmux-plugins/open/open.tmux
      '';
    };
    vim.defaultEditor = true;
    zsh.enable = true;
    zsh.syntaxHighlighting.enable = false;
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.onShutdown = "shutdown";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.kai = {
    isNormalUser = true;
    uid = 1000;
    shell = "${zsh}/bin/zsh";
    extraGroups = [ "wheel" "networkmanager" "nitrokey" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKeT9XLuhzUU4k4gd8URDS3gQIZemTqXSvlVy5nYXJ4gMfJ0sYVMrI9KBBU2Ukkb0Cl8Rmfzblf1iE6IUMrat4Cb9RGIbzjiAzC2XaLUsDC5W87Qv5bgV0t83nWQFjWPWy38Ybjcp8+WuvJNaX9ECc8t+xwtUdVNZ5TszblEqE5wKfOAqJZNGO8uwX2ZY7hOLr9C9a/AM74ouHqR7iDaujMNdLuOA6XmHAnWI6aiA6Lu3NOpGO6UXIudUCIUQ+ymSCCfu99xaAs5aXw/XQLS2f8W8C4q45m/V+uozdqYOK2wrFQlhFa/7TZwi5s3XPeG0d7t5HnxymSIHO7HudP0E7 cardno:00050000351F"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNRoiSl7xkHoHyytkeqhRMeVblZv35Nt8xppfCglFa9LC97fxxDAxoFDK5CTyqRa6PUV1/kD4pLKrP2euhj5GY6m14mvkJxvXpY/SuRN11yp+ATCNC3GeQgTt/jWThhohnZW8OLNXi7lqf6OMIBLUvxajMpqVDCreAU40CYp9E4A+yVTahQCusO/O6ivlURaqqiQ8O0zOCkY5ZPc6KZRoE1VRnX9K7fTL3XrMIPcw27WvSycD9v6cTKSew3eN+SM2BO/AMqaCPpFPegpKpRGK/yrLJwVZTg9YrFav0410ffQ+XvEs7rlVup4eaeeCaWB1tu/mqVxwUFhRkdeDq8vfj JuiceSSH"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCoUcg4szxfmzmretxXMVXfM6e28yiq+rBJM3tIYVwApJpX40Y5NsVe/MQkz8SOKgfxsSXyOw07e2UIWYg3MnaurM4pQJOMWEdfq8ddelFM7ZP9dL+6DZqCapyMA+6VAHOYaocI7IGVQHBb/W7q1PhPEGQZ50phsfKXArfkDlKMhfwQwzJsNCfinH2x7e/vLg8wL6at/um+lGprt3gkL2nettLNUav6WRK8nqh+Jf3p9VNW59Rp85M4g5XjsP1kCdgFqkapr3nb1lJm9vPW2qzUYh/TgGQ8RNnZCQNI38Rp0O1gAUmNXHUT/gudeRT453n7LRyfroq+qhxL5k9KwJf /home/kai/.ssh/id_kai"
    ];
  };

  environment = {
    etc = {
      "tmpfiles.d/xmonad.conf".text = ''
        r! /home/kai/.xmonad/xmonad.state
      '';
    };
  };

  security.apparmor.enable = true;
  security.chromiumSuidSandbox.enable = true;
  security.sudo.extraConfig =''
    kai ALL = NOPASSWD : /run/current-system/sw/bin/physlock -d
    kai ALL = NOPASSWD : /run/current-system/sw/bin/poweroff
    kai ALL = NOPASSWD : /run/current-system/sw/bin/reboot
    '';
}
