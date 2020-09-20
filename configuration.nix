# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: with pkgs; {
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [( self: super: rec {
      gnupg = super.gnupg.override { pinentry = pinentry; };
      lbdb = super.lbdb.override { inherit gnupg; goobook = python27Packages.goobook; };
      zathura = super.zathura.override { synctexSupport = false; };
    })];
  };

  nix = {
    maxJobs = 16;
    useSandbox = true;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";


  systemd = {
    network = {
      enable = true;
      networks = {
        "10-ens5" = {
          name = "ens5";
          DHCP = "yes";
        };
      };
    };

    user.services.pulseaudio.environment = {
      JACK_PROMISCUOUS_SERVER = "jackaudio";
    };
  };

  hardware = {
    bluetooth.enable = false;
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    nitrokey.enable = true;
    opengl.enable = true;
    pulseaudio = {
      enable = true;
      extraModules = [ pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull.override { jackaudioSupport = true; };
    };
  };

  powerManagement = {
    powertop.enable = false;
  };

  boot = {
    kernelPackages = linuxPackages_hardened;
    cleanTmpDir = true;
    kernelModules = [ "snd-seq" "snd-rawmidi" ];

    kernel.sysctl = {
      "vm.dirty_writeback_centisecs" = 1500;
    };

    loader = {
      timeout = 2;
      grub.enable = true;
      grub.device = "/dev/sdb";
      grub.useOSProber = true;
      grub.extraEntries = ''
          menuentry "Bootable ISO Image: Debian" {
              insmod part_gpt
              insmod fat
              set root='hd0,1'
              set isofile='/boot/images/debian.iso'
              loopback loop $isofile
              linux (loop)/live/vmlinuz boot=live config fromiso=/dev/sdb1/$isofile
              initrd (loop)/live/initrd.img
          }
          menuentry "Bootable ISO Image: Tails" {
              insmod part_gpt
              insmod fat
              set root='hd0,1'
              set isofile='/boot/images/tails.iso'
              loopback loop $isofile
              linux (loop)/live/vmlinuz boot=live config findiso=$isofile apparmor=1 security=apparmor nopersistence noprompt timezone=Etc/UTC block.events_dfl_poll_msecs=1000 noautologin module=Tails slab_nomerge slub_debug=FZP mce=0 vsyscall=none page_poison=1 init_on_alloc=1 init_on_free=1 mds=full,nosmt
              initrd (loop)/live/initrd.img
          }
          '';
    };
    supportedFilesystems = [ "nfs4" ];
  };


  fileSystems."/".options     = ["defaults" "noatime" "nodiratime"];


  networking = {
    hostName = "c20";
    wireless.enable = false;  # Enables wireless support via wpa_supplicant.
    useDHCP = false;  # Provided by networkd
    useNetworkd = true;
    firewall = {
      allowPing = false;
      checkReversePath = false;
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    colors = [ "000000" "dc322f" "859900" "b58900" "268bd2" "d33682"
               "2aa198" "eee8d5" "002b36" "cb4b16" "586e75" "657b83"
               "839496" "6c71c4" "93a1a1" "fdf6e3" ];
  };

  sound.enableOSSEmulation = false;

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = [
      corefonts
      hack-font
      inconsolata
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-extra
      powerline-fonts
      symbola
      ubuntu_font_family
      unifont
    ];
  };

  programs = {
    bash.enableCompletion = true;
    command-not-found.enable = true;
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;
    mosh.enable = true;
    ssh.startAgent = false;
    sway = {
      enable = true;
      extraPackages = with pkgs; [ dmenu swayidle xwayland ];
      extraSessionCommands = ''
           export SDL_VIDEODRIVER=wayland
           # needs qt5.qtwayland in systemPackages
           export QT_QPA_PLATFORM=wayland-egl
           export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

           export GDK_BACKEND=wayland
         '';
    };
    tmux = {
      enable = true;
      escapeTime = 0;
      shortcut = "a";
      terminal = "tmux-256color";
      extraConfig = ''
        run-shell ${pkgs.tmuxPlugins.urlview}/share/tmux-plugins/urlview/urlview.tmux
        run-shell ${pkgs.tmuxPlugins.open}/share/tmux-plugins/open/open.tmux
      '';
    };
    vim.defaultEditor = true;
    wireshark.enable = true;
    wireshark.package = wireshark;
    zsh.enable = true;
    zsh.syntaxHighlighting.enable = false;
  };

  virtualisation = {
    libvirtd = {
      enable = true;
      onShutdown = "shutdown";
      qemuPackage = qemu_kvm;
    };
    # xen.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kai = {
    isNormalUser = true;
    uid = 1000;
    shell = "${zsh}/bin/zsh";
    extraGroups = [
      "audio"
      "jackaudio"
      "libvirtd"
      "networkmanager"
      "nitrokey"
      "wheel"
      "wireshark"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKeT9XLuhzUU4k4gd8URDS3gQIZemTqXSvlVy5nYXJ4gMfJ0sYVMrI9KBBU2Ukkb0Cl8Rmfzblf1iE6IUMrat4Cb9RGIbzjiAzC2XaLUsDC5W87Qv5bgV0t83nWQFjWPWy38Ybjcp8+WuvJNaX9ECc8t+xwtUdVNZ5TszblEqE5wKfOAqJZNGO8uwX2ZY7hOLr9C9a/AM74ouHqR7iDaujMNdLuOA6XmHAnWI6aiA6Lu3NOpGO6UXIudUCIUQ+ymSCCfu99xaAs5aXw/XQLS2f8W8C4q45m/V+uozdqYOK2wrFQlhFa/7TZwi5s3XPeG0d7t5HnxymSIHO7HudP0E7 cardno:00050000351F"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNRoiSl7xkHoHyytkeqhRMeVblZv35Nt8xppfCglFa9LC97fxxDAxoFDK5CTyqRa6PUV1/kD4pLKrP2euhj5GY6m14mvkJxvXpY/SuRN11yp+ATCNC3GeQgTt/jWThhohnZW8OLNXi7lqf6OMIBLUvxajMpqVDCreAU40CYp9E4A+yVTahQCusO/O6ivlURaqqiQ8O0zOCkY5ZPc6KZRoE1VRnX9K7fTL3XrMIPcw27WvSycD9v6cTKSew3eN+SM2BO/AMqaCPpFPegpKpRGK/yrLJwVZTg9YrFav0410ffQ+XvEs7rlVup4eaeeCaWB1tu/mqVxwUFhRkdeDq8vfj JuiceSSH"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDCoUcg4szxfmzmretxXMVXfM6e28yiq+rBJM3tIYVwApJpX40Y5NsVe/MQkz8SOKgfxsSXyOw07e2UIWYg3MnaurM4pQJOMWEdfq8ddelFM7ZP9dL+6DZqCapyMA+6VAHOYaocI7IGVQHBb/W7q1PhPEGQZ50phsfKXArfkDlKMhfwQwzJsNCfinH2x7e/vLg8wL6at/um+lGprt3gkL2nettLNUav6WRK8nqh+Jf3p9VNW59Rp85M4g5XjsP1kCdgFqkapr3nb1lJm9vPW2qzUYh/TgGQ8RNnZCQNI38Rp0O1gAUmNXHUT/gudeRT453n7LRyfroq+qhxL5k9KwJf /home/kai/.ssh/id_kai"
    ];
  };

  security.apparmor.enable = true;
  security.chromiumSuidSandbox.enable = true;
  security.sudo.extraConfig =''
    kai ALL = NOPASSWD : /run/current-system/sw/bin/physlock -d
    kai ALL = NOPASSWD : /run/current-system/sw/bin/poweroff
    kai ALL = NOPASSWD : /run/current-system/sw/bin/reboot
    '';

    services = {

    dbus = {
      enable = true;
    };

    fstrim = {
      enable = true;
    };

    journald.extraConfig = "SystemMaxUse=128M";

    nullmailer = {
      enable = true;
      config.allmailfrom = "postmaster.rob@gmail.com";
      remotesFile = "/etc/nullmailer.remotes";
    };

    openssh = {
      enable = true;
      challengeResponseAuthentication = false;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };

    pcscd.enable = true;

    printing = {
      drivers = [ gutenprint ];
      enable = true;
    };

    resolved.enable = true;

    spice-vdagentd.enable = true;
    vnstat.enable = true;

    xserver = {
      enable = true;
      layout = "us";
      displayManager.gdm.enable = true;
      desktopManager.gnome3 = {
        enable = true;
      };
    };
  };

  environment.homeBinInPath = true;
  environment.systemPackages = with pkgs; [
    adapta-gtk-theme
    alsaUtils
    binutils
    cdrkit
    chromium
    cifs-utils
    debootstrap
    dfu-programmer
    dnsutils
    dstat
    efibootmgr
    evince
    feh
    file
    firefox
    fontconfig
    gimp
    git
    gitAndTools.gitFull
    gnome3.adwaita-icon-theme
    gnome3.dconf
    gnome3.gnome-tweak-tool
    gnomeExtensions.appindicator
    gnumake
    gnupg
    gparted
    graphviz
    hicolor_icon_theme
    kvm
    linuxPackages.perf
    lshw
    nethogs
    nfs-utils
    nitrokey-app
    nix-prefetch-scripts
    nix-zsh-completions
    pandoc
    parted
    pass
    pavucontrol
    pciutils
    pcmanfm
    pdftk
    psmisc
    pwgen
    python3
    quilt
    rsync
    shotwell
    stdenv
    syslinux
    transmission_gtk
    tree
    unzip
    usbutils
    usermount
    vim
    virt-viewer
    virtmanager
    vnstat
    w3m
    wireshark
    wol
    zile
  ];
}
