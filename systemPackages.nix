{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    adapta-gtk-theme
    alacritty
    alsaUtils
    aspell
    aspellDicts.de
    aspellDicts.en
    binutils
    blueman
    cdrkit
    chromium
    cifs-utils
    debootstrap
    dfu-programmer
    diffoscope
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
    graphviz
    hicolor_icon_theme
    kvm
    lbdb
    linuxPackages.perf
    lshw
    mc
    meld
    notmuch
    ncdu
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
    wol
    xcompmgr
    xorg.xbacklight
    xorg.xev
    xorg.xmessage
    zathura
    (haskellPackages.ghcWithPackages (self: with self; [
      alex
      cabal-install
      doctest
      happy
      hlint
      xmobar
      xmonad
      xmonad-contrib
      xmonad-extras
      zlib
    ]))
  ];
}
