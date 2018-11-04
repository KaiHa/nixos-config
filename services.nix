{ pkgs, config, ... }:

with pkgs; {
  services = {

    dbus = {
      enable = true;
    };

    emacs = {
      enable = true;
      package = (emacsWithPackages (p: [ ghostscript p.org ]));
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
    physlock.enable = true;

    printing = {
      drivers = [ gutenprint ];
      enable = true;
    };

    radicale = {
      enable = true;
      config = ''
        [server]
        hosts = 0.0.0.0:5232
        [storage]
        filesystem_folder = /var/lib/radicale
        [auth]
        type = htpasswd
        htpasswd_filename = /etc/radicale.users
        htpasswd_encryption = bcrypt
        [rights]
        type = from_file
        file = /etc/radicale.rights
      '';
    };

    spice-vdagentd.enable = true;
    vnstat.enable = true;

    xserver = {
      enable = true;
      layout = "us";
      synaptics.enable = true;
      synaptics.twoFingerScroll = true;
      synaptics.tapButtons = false;

      displayManager.slim = {
        enable = true;
        defaultUser = "kai";
        autoLogin = true;
        extraConfig = ''
          sessionstart_cmd    ${xorg.sessreg}/bin/sessreg -a -l tty7 %user
          sessionstop_cmd     ${xorg.sessreg}/bin/sessreg -d -l tty7 %user
        '';
      };
      desktopManager.default = "none";
      windowManager = {
        default = "xmonad";
        xmonad.enable = true;
      };
    };
  };

### modemmanager is not yet needed
#  systemd.services.wwan = {
#    description = "Start ModemManager";
#    serviceConfig = {
#      Type = "oneshot";
#      ExecStart = "${dbus}/bin/dbus-send --system --print-reply --reply-timeout=120000 --type=method_call --dest='org.freedesktop.ModemManager1' '/org/freedesktop/ModemManager1' org.freedesktop.ModemManager1.ScanDevices";
#    };
#    wantedBy = [ "default.target" ];
#    after = [ "network-manager.service" ];
#  };
}
