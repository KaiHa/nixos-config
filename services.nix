{ pkgs, config, ... }:

with pkgs; {
  services = {
    emacs = {
      enable = true;
      package = (emacsWithPackages (p: [ p.notmuch p.org ]));
    };

    fstrim = {
      enable = true;
    };

    journald.extraConfig = "SystemMaxUse=128M";

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
        xmonad.enableContribAndExtras = true;
        xmonad.extraPackages = self: [ self.MissingH ];
      };
    };
  };

  systemd.user.services = {
    fetch-mail = {
      description = "Fetch mail";
      serviceConfig = {
        Type = "oneshot";
        WorkingDirectory = "%h/.mail/account.gmail/";
        ExecStart = [
          "${gmailieer}/bin/gmi sync"
          "${notmuch}/bin/notmuch new"
        ];
      };
      path = [ bash notmuch ];
      after = [ "wait-for-network.service" ];
      requires = [ "wait-for-network.service" ];
      wantedBy = [ "default.target" ];
    };

    # Add a user service that waits for the network, because the
    # network-online.target is not available from a user service
    wait-for-network = {
      description = "Wait for the network to become online";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = [
          "${bash}/bin/bash -c 'while ! curl --silent http://google.com >/dev/null; do sleep 1; done'"
        ];
        TimeoutStartSec = "30s";
      };
      path = [ bash curl ];
    };
  };

  systemd.user.timers = {
    fetch-mail = {
      timerConfig = {
        OnCalendar = "*-*-* *:0/5:00";
        Unit = "fetch-mail.service";
      };
      wantedBy = [ "default.target" ];
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
