# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.extraModulePackages = [ pkgs.linuxPackages.sysdig ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.timeout = 2;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  boot.initrd.luks.devices = [ { device = "/dev/sda2"; name = "crypted"; } ];

  networking.hostName = "eeenix"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    consoleColors = [ "002b36" "dc322f" "859900" "b58900" "268bd2" "d33682"
                      "2aa198" "eee8d5" "002b36" "cb4b16" "586e75" "657b83"
                      "839496" "6c71c4" "93a1a1" "fdf6e3" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      hack-font
      inconsolata
      liberation_ttf
      powerline-fonts
      ubuntu_font_family
      unifont
    ];
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    byobu
    dmenu
    emacs
    feh
    file
    firefox
    fontconfig
    git
    gmrun
    gnumake
    gnupg21
    meld
    mupdf
    mutt-with-sidebar
    nitrokey-app
    nix-prefetch-scripts
    nix-repl
    pandoc
    pass
    psmisc
    python35
    rxvt_unicode-with-plugins
    stalonetray
    sysdig
    tmux
    tree
    unzip
    usbutils
    usermount
    vim
    w3m
    wireshark
    xcompmgr
    xorg.xev
    (pkgs.haskellPackages.ghcWithPackages (self: [
      self.MissingH
      self.cabal-install
      self.stack
      self.xmobar
      self.xmonad
      self.xmonad-contrib
      self.xmonad-extras
    ]))
  ];

  programs = {
    bash.enableCompletion = true;
    zsh.enable = true;
  };

#  security.sudo.configFile =
#    ''
#      kai  ALL=(ALL:ALL) ALL
#    '';

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    gutenprint = true;
  };

  services.physlock = {
    enable = true;
    user = "kai";
  };


  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;
    layout = "us";
    # services.xserver.xkbOptions = "eurosign:e";
    synaptics.enable = true;
    synaptics.twoFingerScroll = true;
    synaptics.tapButtons = false;

    # Enable the Window Manager.
    #displayManager.gdm.enable = true;
    #desktopManager.gnome3.enable = true;
    displayManager.slim = {
      enable = true;
      defaultUser = "kai";
      autoLogin = true;
    };
    desktopManager.default = "none";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    windowManager.xmonad.extraPackages = self: [ self.MissingH ];
    windowManager.default = "xmonad";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.kai = {
    isNormalUser = true;
    uid = 1000;
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKeT9XLuhzUU4k4gd8URDS3gQIZemTqXSvlVy5nYXJ4gMfJ0sYVMrI9KBBU2Ukkb0Cl8Rmfzblf1iE6IUMrat4Cb9RGIbzjiAzC2XaLUsDC5W87Qv5bgV0t83nWQFjWPWy38Ybjcp8+WuvJNaX9ECc8t+xwtUdVNZ5TszblEqE5wKfOAqJZNGO8uwX2ZY7hOLr9C9a/AM74ouHqR7iDaujMNdLuOA6XmHAnWI6aiA6Lu3NOpGO6UXIudUCIUQ+ymSCCfu99xaAs5aXw/XQLS2f8W8C4q45m/V+uozdqYOK2wrFQlhFa/7TZwi5s3XPeG0d7t5HnxymSIHO7HudP0E7 cardno:00050000351F" ];
  };

  services.udev.extraRules = ''
    # Nitrokey U2F
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0664", GROUP="wheel", ATTRS{idVendor}=="2581", ATTRS{idProduct}=="f1d0"
    
    SUBSYSTEM!="usb", GOTO="gnupg_rules_end"
    ACTION!="add", GOTO="gnupg_rules_end"
    
    # USB SmartCard Readers
    ## Crypto Stick 1.2
    ATTR{idVendor}=="20a0", ATTR{idProduct}=="4107", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP+="wheel", TAG+="uaccess"
    ## Nitrokey Pro
    ATTR{idVendor}=="20a0", ATTR{idProduct}=="4108", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP+="wheel", TAG+="uaccess"
    ## Nitrokey Storage
    ATTR{idVendor}=="20a0", ATTR{idProduct}=="4109", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP+="wheel", TAG+="uaccess"
    ## Nitrokey Start
    ATTR{idVendor}=="20a0", ATTR{idProduct}=="4211", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP+="wheel", TAG+="uaccess"
    ## Nitrokey HSM
    ATTR{idVendor}=="20a0", ATTR{idProduct}=="4230", ENV{ID_SMARTCARD_READER}="1", ENV{ID_SMARTCARD_READER_DRIVER}="gnupg", GROUP+="wheel", TAG+="uaccess"
    
    LABEL="gnupg_rules_end"
  '';

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";

  nix.useChroot = true;

}
