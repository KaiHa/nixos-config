{ pkgs, ... }:

{
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
  ];

}
