{ pkgs, config, ... }:

with pkgs; {
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
    physlock.enable = true;

    printing = {
      drivers = [ gutenprint ];
      enable = true;
    };

    resolved.enable = false;
    stubby.enable = true;

    spice-vdagentd.enable = true;
    vnstat.enable = true;

    xserver = {
      enable = true;
      layout = "us";
      synaptics.enable = true;
      synaptics.twoFingerScroll = true;
      synaptics.tapButtons = false;

      displayManager.lightdm = {
        enable = true;
        extraConfig = ''
            sessions-directory=${sway}/share/wayland-sessions/

            [Seat:*]
            autologin-session=sway
            user-session=sway
            greeter-session = lightdm-gtk-greeter
            autologin-user = kai
            autologin-user-timeout = 0
          '';
      };
      windowManager = {
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
