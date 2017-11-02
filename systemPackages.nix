{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    adapta-gtk-theme
    aspell
    aspellDicts.de
    aspellDicts.en
    binutils
    blueman
    cdrkit
    cifs-utils
    debootstrap
    dfu-programmer
    dmenu
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
    gmailieer
    gmrun
    gnome3.adwaita-icon-theme
    gnome3.dconf
    gnumake
    gnupg
    gparted
    hicolor_icon_theme
    kvm
    lbdb
    linuxPackages.perf
    mc
    meld
    notmuch
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
    pcmanfm
    psmisc
    pwgen
    python3
    rsync
    rxvt_unicode-with-plugins
    shotwell
    stalonetray
    stdenv
    syslinux
    transmission_gtk
    tree
    unclutter-xfixes
    unzip
    usbutils
    usermount
    vim
    virt-viewer
    virtmanager
    vnstat
    w3m
    weechat
    wireshark
    xcompmgr
    xorg.xbacklight
    xorg.xev
    xorg.xmessage
    zathura
    (haskellPackages.ghcWithHoogle (self: with self; [
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
}
