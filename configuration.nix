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
      sway = super.sway.overrideAttrs (oldAttrs: rec { separateDebugInfo = true; });
      wlroots = super.wlroots.overrideAttrs (oldAttrs: rec { separateDebugInfo = true; });
      zathura = super.zathura.override { synctexSupport = false; };
    })];
  };

  nix.useSandbox = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";


  systemd = {
    mounts = [
      { where = "/media/KAI";
        what = "192.168.1.1:/mnt/sda1/PRIVATE/KAI";
        type = "nfs4";
        options = "";
        after = ["network-online.target"]; }
      { where = "/media/PUBLIC";
        what = "192.168.1.1:/mnt/sda1/PUBLIC";
        type = "nfs4";
        options = "";
        after = ["network-online.target"]; }
      { where = "/media/PUBLIC_RW";
        what = "192.168.1.1:/mnt/sda1/PUBLIC_RW";
        type = "nfs4";
        options = "";
        after = ["network-online.target"]; }
    ];

    automounts = [
      { wantedBy = ["multi-user.target"];
        where = "/media/KAI"; }
      { wantedBy = ["multi-user.target"];
        where = "/media/PUBLIC"; }
      { wantedBy = ["multi-user.target"];
        where = "/media/PUBLIC_RW"; }
    ];

    network = {
      enable = true;
      networks =
        let
          not_required_for_online = ''
             [Link]
             RequiredForOnline=no
          '';
        in {
          "10-lo" = {
            name = "lo";
            address = ["127.0.0.1/8" "::1/128"];
          };
          "10-wlp3s0" = {
            name = "wlp3s0";
            DHCP = "yes";
          };
          "10-wwp0s20u4i6" = {
            name = "wwp0s20u4i6";
            extraConfig = not_required_for_online;
          };
          "10-enp0s25" = {
            name = "enp0s25";
            DHCP = "yes";
            extraConfig = not_required_for_online;
          };
          "11-virbr" = {
            name = "virbr*";
            extraConfig = not_required_for_online;
          };
       };
    };

    services.tunePowermanagement = {
      enable = true;
      script = ''
          echo 'min_power' > '/sys/class/scsi_host/host4/link_power_management_policy' || true
          echo 'min_power' > '/sys/class/scsi_host/host5/link_power_management_policy' || true
          echo 'min_power' > '/sys/class/scsi_host/host3/link_power_management_policy' || true
          echo 'min_power' > '/sys/class/scsi_host/host1/link_power_management_policy' || true
          echo 'min_power' > '/sys/class/scsi_host/host2/link_power_management_policy' || true
          echo 'min_power' > '/sys/class/scsi_host/host0/link_power_management_policy' || true
          echo '1'         > '/sys/module/snd_hda_intel/parameters/power_save' || true
          echo 'auto'      > '/sys/bus/i2c/devices/i2c-1/device/power/control' || true
          echo 'auto'      > '/sys/bus/usb/devices/2-4/power/control' || true
          echo 'auto'      > '/sys/bus/i2c/devices/i2c-6/device/power/control' || true
          echo 'auto'      > '/sys/bus/usb/devices/1-1.4/power/control' || true
          echo 'auto'      > '/sys/bus/i2c/devices/i2c-3/device/power/control' || true
          echo 'auto'      > '/sys/bus/i2c/devices/i2c-4/device/power/control' || true
          echo 'auto'      > '/sys/bus/i2c/devices/i2c-2/device/power/control' || true
          echo 'auto'      > '/sys/bus/i2c/devices/i2c-5/device/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:1d.0/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:03:00.0/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:1f.2/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:1c.0/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:1f.0/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:02:00.0/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:16.0/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:1a.0/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:19.0/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:02.0/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:14.0/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:1c.2/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:00.0/power/control' || true
          echo 'auto'      > '/sys/bus/pci/devices/0000:00:1b.0/power/control' || true
      '';
      serviceConfig = {
        Type = "oneshot";
      };
      wantedBy = ["default.target"];
    };
    user.services.jackpa = {
      enable = true;
      script = ''
                            ${pulseaudio}/bin/pactl load-module module-jack-sink channels=2
                            ${pulseaudio}/bin/pactl load-module module-jack-source channels=2
                            ${pulseaudio}/bin/pacmd set-default-sink jack_out
                            '';
      serviceConfig = {
        Type = "oneshot";
      };
      wantedBy = ["default.target"];
    };

    user.services.pulseaudio.environment = {
      JACK_PROMISCUOUS_SERVER = "jackaudio";
    };
  };

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = false;
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
    cpuFreqGovernor = "powersave";
    powertop.enable = false;
  };

  boot = {
    kernelPackages = linuxPackages_latest_hardened;
    cleanTmpDir = true;
    kernelModules = [ "snd-seq" "snd-rawmidi" ];

    kernel.sysctl = {
      "vm.dirty_writeback_centisecs" = 1500;
    };

    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
      timeout = 60;
      # GRUB was only enabled to create a legacy boot option to boot
      # from ISO images. If GRUB is enabled, then systemd-boot is not
      # updated. Therfore do not enable it permanently.
      # If you need to fix the boot-order then use `efibootmgr`. Eg
      #    $ sudo efibootmgr -o 0018,0019,0000,...
      grub = {
        #enable = true;
        memtest86.enable = true;
        version = 2;
        default = 1;
        efiSupport = true;
        device = "/dev/sda";
        extraFiles = { "memdisk" = "${syslinux}/share/syslinux/memdisk"; };
        extraEntries = ''
          menuentry "Bootable ISO Image: Debian Stretch" {
              insmod part_gpt
              insmod fat
              set root='hd0,3'
              set isofile='/images/stretch.iso'
              loopback loop $isofile
              linux (loop)/live/vmlinuz boot=live config fromiso=/dev/sda3/$isofile
              initrd (loop)/live/initrd.img
          }
          menuentry "Bootable ISO Image: Tails 3" {
              insmod part_gpt
              insmod fat
              set root='hd0,3'
              set isofile='/images/tails3.iso'
              loopback loop $isofile
              linux (loop)/live/vmlinuz boot=live config findiso=/images/tails3.iso apparmor=1 security=apparmor nopersistence noprompt timezone=Etc/UTC block.events_dfl_poll_msecs=1000 noautologin module=Tails kaslr slab_nomerge slub_debug=FZP mce=0 vsyscall=none page_poison=1 union=aufs
              initrd (loop)/live/initrd.img
          }
          '';
      };
    };
    initrd.luks.devices."crypted".allowDiscards = true;
    supportedFilesystems = [ "nfs4" ];
  };

  fileSystems = {
    "/".options     = ["defaults" "noatime" "nodiratime" "nodiscard"];
    "/boot".options = ["defaults" "noatime" "nodiratime" "discard"];
  };

  networking = {
    hostName = "nix230";
    wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    useDHCP = false;  # Provided by networkd
    useNetworkd = true;
    firewall = {
      allowPing = false;
      checkReversePath = false;
    };
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
      extraTmuxConf = ''
        run-shell ${pkgs.tmuxPlugins.urlview}/share/tmux-plugins/urlview/urlview.tmux
        run-shell ${pkgs.tmuxPlugins.open}/share/tmux-plugins/open/open.tmux
      '';
    };
    vim.defaultEditor = true;
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
    extraGroups = [ "wheel" "audio" "jackaudio" "networkmanager" "nitrokey" "libvirtd" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKeT9XLuhzUU4k4gd8URDS3gQIZemTqXSvlVy5nYXJ4gMfJ0sYVMrI9KBBU2Ukkb0Cl8Rmfzblf1iE6IUMrat4Cb9RGIbzjiAzC2XaLUsDC5W87Qv5bgV0t83nWQFjWPWy38Ybjcp8+WuvJNaX9ECc8t+xwtUdVNZ5TszblEqE5wKfOAqJZNGO8uwX2ZY7hOLr9C9a/AM74ouHqR7iDaujMNdLuOA6XmHAnWI6aiA6Lu3NOpGO6UXIudUCIUQ+ymSCCfu99xaAs5aXw/XQLS2f8W8C4q45m/V+uozdqYOK2wrFQlhFa/7TZwi5s3XPeG0d7t5HnxymSIHO7HudP0E7 cardno:00050000351F"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNRoiSl7xkHoHyytkeqhRMeVblZv35Nt8xppfCglFa9LC97fxxDAxoFDK5CTyqRa6PUV1/kD4pLKrP2euhj5GY6m14mvkJxvXpY/SuRN11yp+ATCNC3GeQgTt/jWThhohnZW8OLNXi7lqf6OMIBLUvxajMpqVDCreAU40CYp9E4A+yVTahQCusO/O6ivlURaqqiQ8O0zOCkY5ZPc6KZRoE1VRnX9K7fTL3XrMIPcw27WvSycD9v6cTKSew3eN+SM2BO/AMqaCPpFPegpKpRGK/yrLJwVZTg9YrFav0410ffQ+XvEs7rlVup4eaeeCaWB1tu/mqVxwUFhRkdeDq8vfj JuiceSSH"
    ];
  };

  environment = {
    etc = {
      "tmpfiles.d/xmonad.conf".text = ''
          r! /home/kai/.xmonad/xmonad.state
        '';
    };
    extraOutputsToInstall = [ "debug" ];
    systemPackages = [
      alsaUtils
      binutils
      blueman
      bluez-tools
      cdrkit
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
      gnome3.dconf
      gnumake
      gnupg
      gparted
      graphviz
      (haskellPackages.ghcWithPackages (p: with p; [
        alex
        cabal-install
        doctest
        happy
      ]))
      kvm
      light
      linuxPackages.perf
      lshw
      nitrokey-app
      nixops
      nix-prefetch-scripts
      nix-zsh-completions
      pandoc
      parted
      pass
      pavucontrol
      pciutils
      pdftk
      psmisc
      pulsemixer
      pwgen
      python3
      qt5.qtwayland
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
    ];
  };

  security = {
    apparmor.enable = true;
    sudo.extraConfig =''
                      kai ALL = NOPASSWD : /run/current-system/sw/bin/light
                      kai ALL = NOPASSWD : /run/current-system/sw/bin/physlock -d
                      kai ALL = NOPASSWD : /run/current-system/sw/bin/poweroff
                      kai ALL = NOPASSWD : /run/current-system/sw/bin/reboot
                      '';
  };

  services = {

    blueman.enable = true;

    dbus = {
      enable = true;
      packages = [ blueman bluez dbus gvfs jack2 polkit pulseaudio
                   rtkit wpa_supplicant
                 ];
    };

    fstrim = {
      enable = true;
    };

    gvfs.enable = true;

    jack = {
      jackd.enable = true;
      alsa.enable = false;
      loopback = {
        enable = true;
        dmixConfig = ''
        period_size 2048
      '';
      };
    };

    journald.extraConfig = "SystemMaxUse=128M";
    mingetty.autologinUser = "kai";

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
    physlock.enable = true;

    printing = {
      drivers = [ gutenprint ];
      enable = true;
    };

    resolved.enable = false;
    stubby.enable = true;
    spice-vdagentd.enable = true;

    tor = {
      enable = true;
      client.enable = true;
      client.dns.enable = true;
    };

    vnstat.enable = true;
  };
}
