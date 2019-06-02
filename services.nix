{ pkgs, config, ... }:

with pkgs; {
  services = {

    dbus = {
      enable = true;
    };

    fstrim = {
      enable = true;
    };

    gvfs.enable = true;
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

    spice-vdagentd.enable = true;

    tor = {
      enable = true;
      client.enable = true;
      client.dns.enable = true;
    };

    vnstat.enable = true;
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
