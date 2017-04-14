# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.bluetooth.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.memtest86.enable = true;
  boot.loader.timeout = 2;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  #boot.loader.grub.efiInstallAsRemovable = true;
  #boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "nodev";
  boot.loader.grub.extraFiles = { "memdisk" = "${pkgs.syslinux}/share/syslinux/memdisk"; };
  boot.loader.grub.extraEntries = ''
    menuentry "Bootable ISO Image: Debian Jessie" {
        insmod part_msdos
        insmod ext2
        set root='hd0,msdos1'
        linux16 /memdisk iso
        initrd16 /images/jessie.iso
    }
    menuentry "Bootable ISO Image: Debian Stretch" {
        insmod part_msdos
        insmod ext2
        set root='hd0,msdos1'
        linux16 /memdisk iso
        initrd16 /images/stretch.iso
    }
    menuentry "Bootable ISO Image: Tails" {
        insmod part_msdos
        insmod ext2
        set root='hd0,msdos1'
        linux16 /memdisk iso
        initrd16 /images/tails.iso
    }
    '';


  boot.initrd.luks.devices."crypt".allowDiscards = true;

  fileSystems."/".options = ["noatime" "nodiratime" "discard"];

  networking.hostName = "nix230";
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
    consoleColors = [ "000000" "dc322f" "859900" "b58900" "268bd2" "d33682"
                      "2aa198" "eee8d5" "002b36" "cb4b16" "586e75" "657b83"
                      "839496" "6c71c4" "93a1a1" "fdf6e3" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  nixpkgs.config = {
    allowUnfree = true;
  };

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
    (mutt.override { withSidebar = true; })
    aspell
    aspellDicts.de
    aspellDicts.en
    binutils
    blueman
    byobu
    debootstrap
    dfu-programmer
    dmenu
    dstat
    efibootmgr
    emacs
    evince
    feh
    file
    firefox
    fontconfig
    git
    gitAndTools.gitFull
    gmrun
    gnumake
    gnupg
    linuxPackages.perf
    mc
    meld
    mupdf
    mutt
    nethogs
    nitrokey-app
    nix-prefetch-scripts
    nix-repl
    pandoc
    parted
    pass
    pciutils
    psmisc
    pwgen
    python35
    rsync
    rxvt_unicode-with-plugins
    stalonetray
    stdenv
    sysdig
    syslinux
    tmux
    tree
    unzip
    usbutils
    usermount
    vim
    vnstat
    weechat
    w3m
    wireshark
    xorg.xbacklight
    xcompmgr
    xorg.xev
    xorg.xmessage
    (pkgs.haskellPackages.ghcWithPackages (self: [
      self.MissingH
      self.alex
      self.brick
      self.cabal-install
      self.ghc-mod
      self.happy
      self.hlint
      self.shelly
      self.xmobar
      self.xmonad
      self.xmonad-contrib
      self.xmonad-extras
    ]))
  ];

  programs = {
    bash.enableCompletion = true;
    ssh.startAgent = false;
    zsh.enable = true;
  };

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

  services.physlock = { enable = true; };

  services.vnstat.enable = true;

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
      extraConfig = ''
        sessionstart_cmd    ${pkgs.xorg.sessreg}/bin/sessreg -a -l tty7 %user
        sessionstop_cmd     ${pkgs.xorg.sessreg}/bin/sessreg -d -l tty7 %user
      '';
    };
    desktopManager.default = "none";
    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    windowManager.xmonad.extraPackages = self: [ self.MissingH ];
    windowManager.default = "xmonad";
  };

  systemd.user.services.emacs = {
    description = "Emacs Daemon";
    environment = {
      GTK_DATA_PREFIX = config.system.path;
      SSH_AUTH_SOCK = "/home/kai/.gnupg/S.gpg-agent.ssh";
      GTK_PATH = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
      NIX_PROFILES = "${pkgs.lib.concatStringsSep " " config.environment.profiles}";
      TERMINFO_DIRS = "/run/current-system/sw/share/terminfo";
      ASPELL_CONF = "dict-dir /run/current-system/sw/lib/aspell";
    };
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; exec emacs --daemon'";
      ExecStop = "${pkgs.emacs}/bin/emacsclient --eval (kill-emacs)";
      Restart = "always";
    };
    wantedBy = [ "default.target" ];
  };

  systemd.services.wwan = {
    description = "Start ModemManager";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.dbus}/bin/dbus-send --system --print-reply --reply-timeout=120000 --type=method_call --dest='org.freedesktop.ModemManager1' '/org/freedesktop/ModemManager1' org.freedesktop.ModemManager1.ScanDevices";
    };
    wantedBy = [ "default.target" ];
    after = [ "network-manager.service" ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.kai = {
    isNormalUser = true;
    uid = 1000;
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "wheel" "networkmanager" ];
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


  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.useSandbox = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

}
