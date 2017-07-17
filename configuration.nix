# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  systemd.mounts = [
    { where = "/media/nas";
      what = "//fritz.box/FRITZ.NAS/NAS";
      type = "cifs";
      options = "credentials=/etc/.cifs-cred,iocharset=utf8,uid=1000,noauto,_netdev";
      after = ["network-online.target" "wpa_supplicant.service"];
      requires = ["network-online.target" "wpa_supplicant.service"]; }
  ];

  systemd.automounts = [
    { wantedBy = ["multi-user.target"];
      where = "/media/nas"; }
  ];

  hardware.bluetooth.enable = true;
  hardware.nitrokey.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  boot.kernelPackages = pkgs.linuxPackages_4_12;

  boot.cleanTmpDir = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 60;

  # GRUB was only enabled to create a legacy boot option to boot
  # from ISO images. If GRUB is enabled, then systemd-boot is not
  # updated. Therfore do not enable it permanently.
  # If you need to fix the boot-order then use `efibootmgr`. Eg
  #    $ sudo efibootmgr -o 0018,0019,0000,...
  boot.loader.grub = {
    #enable = true;
    memtest86.enable = true;
    version = 2;
    default = 1;
    efiSupport = true;
    device = "/dev/sda";
    extraFiles = { "memdisk" = "${pkgs.syslinux}/share/syslinux/memdisk"; };
    extraEntries = ''
      menuentry "Bootable ISO Image: Debian Stretch" {
          insmod part_gpt
          insmod fat
          set root='hd0,1'
          set isofile='/images/stretch.iso'
          loopback loop $isofile
          linux (loop)/live/vmlinuz boot=live config fromiso=/dev/sda1/$isofile
          initrd (loop)/live/initrd.img
      }
      menuentry "Bootable ISO Image: Tails 2" {
          insmod part_gpt
          insmod fat
          set root='hd0,1'
          set isofile='/images/tails2.iso'
          loopback loop $isofile
          linux (loop)/live/vmlinuz2 boot=live config findiso=/images/tails2.iso apparmor=1 security=apparmor nopersistence noprompt timezone=Etc/UTC block.events_dfl_poll_msecs=1000 noautologin module=Tails kaslr slab_nomerge slub_debug=FZ mce=0 vsyscall=none  
          initrd (loop)/live/initrd2.img
      }
      menuentry "Bootable ISO Image: Tails 3" {
          insmod part_gpt
          insmod fat
          set root='hd0,1'
          set isofile='/images/tails3.iso'
          loopback loop $isofile
          linux (loop)/live/vmlinuz boot=live config findiso=/images/tails3.iso apparmor=1 security=apparmor nopersistence noprompt timezone=Etc/UTC block.events_dfl_poll_msecs=1000 noautologin module=Tails kaslr slab_nomerge slub_debug=FZP mce=0 vsyscall=none page_poison=1 union=aufs  
          initrd (loop)/live/initrd.img
      }
      menuentry "Bootable ISO Image: Kali Linux" {
          insmod part_gpt
          insmod fat
          set root='hd0,1'
          set isofile='/images/kali.iso'
          loopback loop $isofile
          linux (loop)/live/vmlinuz boot=live components splash username=root hostname=kali fromiso=/dev/sda1/$isofile
          initrd (loop)/live/initrd.img
      }
      '';
  };

  boot.initrd.luks.devices."crypt".allowDiscards = true;

  fileSystems."/".options = ["defaults" "noatime" "nodiratime" "discard"];

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
    cdrkit
    cifs-utils
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
    gimp
    git
    gitAndTools.gitFull
    gmrun
    gnumake
    gnupg
    gparted
    kvm
    linuxPackages.perf
    mc
    meld
    mutt
    ncdu
    nethogs
    nitrokey-app
    nix-prefetch-scripts
    nix-repl
    nix-zsh-completions
    pandoc
    parted
    pass
    pavucontrol
    pciutils
    psmisc
    pwgen
    python35
    rsync
    rxvt_unicode-with-plugins
    shotwell
    stalonetray
    stdenv
    sysdig
    syslinux
    tmux
    transmission_gtk
    tree
    unzip
    usbutils
    usermount
    vim
    virt-viewer
    virtmanager
    vnstat
    weechat
    w3m
    wireshark
    xorg.xbacklight
    xcompmgr
    xorg.xev
    xorg.xmessage
    zathura
    (pkgs.haskellPackages.ghcWithHoogle (self: with self; [
      MissingH
      alex
      cabal-install
      doctest
      ghc-mod
      happy
      hlint
      hmatrix
      xmobar
      xmonad
      xmonad-contrib
      xmonad-extras
      zlib
    ]))
  ];

  programs = {
    bash.enableCompletion = true;
    ssh.startAgent = false;
    zsh.enable = true;
    zsh.syntaxHighlighting.enable = true;
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

  services.physlock.enable = true;
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
      SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
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

  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.onShutdown = "shutdown";
  services.spice-vdagentd.enable = true;

### modemmanager is not yet needed
#  systemd.services.wwan = {
#    description = "Start ModemManager";
#    serviceConfig = {
#      Type = "oneshot";
#      ExecStart = "${pkgs.dbus}/bin/dbus-send --system --print-reply --reply-timeout=120000 --type=method_call --dest='org.freedesktop.ModemManager1' '/org/freedesktop/ModemManager1' org.freedesktop.ModemManager1.ScanDevices";
#    };
#    wantedBy = [ "default.target" ];
#    after = [ "network-manager.service" ];
#  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.kai = {
    isNormalUser = true;
    uid = 1000;
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "wheel" "networkmanager" "nitrokey" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKeT9XLuhzUU4k4gd8URDS3gQIZemTqXSvlVy5nYXJ4gMfJ0sYVMrI9KBBU2Ukkb0Cl8Rmfzblf1iE6IUMrat4Cb9RGIbzjiAzC2XaLUsDC5W87Qv5bgV0t83nWQFjWPWy38Ybjcp8+WuvJNaX9ECc8t+xwtUdVNZ5TszblEqE5wKfOAqJZNGO8uwX2ZY7hOLr9C9a/AM74ouHqR7iDaujMNdLuOA6XmHAnWI6aiA6Lu3NOpGO6UXIudUCIUQ+ymSCCfu99xaAs5aXw/XQLS2f8W8C4q45m/V+uozdqYOK2wrFQlhFa/7TZwi5s3XPeG0d7t5HnxymSIHO7HudP0E7 cardno:00050000351F" ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.useSandbox = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

}
