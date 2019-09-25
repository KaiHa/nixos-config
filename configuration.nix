# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: with pkgs; {
  imports = [
    ./hardware-configuration.nix
  ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "19.03";

  boot = {
    kernelPackages = linuxPackages_hardened;
    cleanTmpDir = true;

    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/sda";
      };
    };
  };

  networking = {
    hostName = "vps1";
    firewall.allowPing = false;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus22";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    consoleColors = [ "000000" "dc322f" "859900" "b58900" "268bd2" "d33682"
                      "2aa198" "eee8d5" "002b36" "cb4b16" "586e75" "657b83"
                      "839496" "6c71c4" "93a1a1" "fdf6e3" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  programs = {
    bash.enableCompletion = true;
    mosh.enable = true;
    tmux = {
      enable = true;
      escapeTime = 0;
      shortcut = "a";
      terminal = "tmux-256color";
    };
    vim.defaultEditor = true;
    zsh.enable = true;
    zsh.syntaxHighlighting.enable = false;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kai = {
    isNormalUser = true;
    shell = "${zsh}/bin/zsh";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKeT9XLuhzUU4k4gd8URDS3gQIZemTqXSvlVy5nYXJ4gMfJ0sYVMrI9KBBU2Ukkb0Cl8Rmfzblf1iE6IUMrat4Cb9RGIbzjiAzC2XaLUsDC5W87Qv5bgV0t83nWQFjWPWy38Ybjcp8+WuvJNaX9ECc8t+xwtUdVNZ5TszblEqE5wKfOAqJZNGO8uwX2ZY7hOLr9C9a/AM74ouHqR7iDaujMNdLuOA6XmHAnWI6aiA6Lu3NOpGO6UXIudUCIUQ+ymSCCfu99xaAs5aXw/XQLS2f8W8C4q45m/V+uozdqYOK2wrFQlhFa/7TZwi5s3XPeG0d7t5HnxymSIHO7HudP0E7 cardno:00050000351F"
    ];
  };

  environment = {
    systemPackages = [
      certbot
      git
      gnupg
      parted
      psmisc
      wget
    ];
  };

  security.apparmor.enable = true;
  security.sudo.extraConfig =''
    kai ALL = NOPASSWD : /run/current-system/sw/bin/poweroff
    kai ALL = NOPASSWD : /run/current-system/sw/bin/reboot
    '';

  services = {

    openssh = {
      enable = true;
      challengeResponseAuthentication = false;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };
  };
}
