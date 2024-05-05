{
  config,
  pkgs,
  lib,
  ...
}: let
  menuscript =
    pkgs.writeShellScript "menu"
    ''
      #!/bin/sh -eu

      in_pipe="$XDG_RUNTIME_DIR/menu-in.$$.pipe"
      out_pipe="$XDG_RUNTIME_DIR/menu-out.$$.pipe"

      mkfifo "$in_pipe" "$out_pipe"
      trap "rm -f $in_pipe $out_pipe" EXIT

      app_id=menu
      chooser="${pkgs.fzf}/bin/fzf <$in_pipe >$out_pipe"
      foot -W40x40 --app-id "$app_id" -- sh -c "$chooser" &
      cat >"$in_pipe"
      cat <"$out_pipe"
    '';
  sel =
    pkgs.writeShellApplication {
    name = "sel";
    text =''
      swaymsg -t get_tree | \
      ${pkgs.jq}/bin/jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | \
      ${pkgs.slurp}/bin/slurp
    '';
    };
  patchedSway = pkgs.sway;
in {
  config = {
    security.pam.services.swaylock = {};
    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs;
    [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
    xdg.portal.config = {
      common = {
        default = [ "gtk" ];
      };
      sway = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Screencast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      };
    };

    home-manager.users.sam = { pkgs, config, ...}@hm: {

    xdg.configFile."i3status-rust/config.toml".source = ./i3status-rs.toml;
    services.mako.enable = true;
    home.packages = with pkgs; [
      grim
      sel
      slurp
      wf-recorder
      pamixer
      pavucontrol
      playerctl
      font-awesome
    ];
    home.sessionVariables = {
      "XDG_CURRENT_DESKTOP" = "sway";
      "NIXOS_OZONE_WL" = "1";
    };
    services.swayidle = let
      pgrep = "${pkgs.procps}/bin/pgrep";
      dpms_check = s:
        pkgs.writeShellScript "dpms_check_${s}" ''
          set -x
          if ${pgrep} swaylock; then ${patchedSway}/bin/swaymsg 'output * dpms ${s}'; fi
        '';
      dpms_set = s:
        pkgs.writeShellScript "dpms_set_${s}" ''
          set -x
          "${patchedSway}/bin/swaymsg" 'output * dpms ${s}'
        '';
      fadelock = pkgs.writeShellScript "fadelock.sh" ''
        set -x
        exec "${pkgs.swaylock}/bin/swaylock"
      '';
    in {
      enable = false;
      systemdTarget = "graphical-session.target";
      timeouts = [
        # auto-lock after 30 seconds
        {
          timeout = 30;
          command = fadelock.outPath;
        }
      ];
      events = [
        {
          event = "before-sleep";
          command = fadelock.outPath;
        }
      ];
      extraArgs = [
        "idlehint 30"
      ];
    };
    wayland.windowManager.sway = {
      enable = true;
      systemd.enable = true;
      wrapperFeatures = {
        base = false;
        gtk = true;
      };
      
      config = rec {
        fonts = {
          names = ["Go Mono"];
          # names = ["Iosevka Comfy Fixed"];
          style = "Regular";
          size = 11.0;
        };
        output."eDP-1".scale = "1.75";
        bars = [
          {
            fonts = {
              names = ["Go Mono For Powerline" "Font Awesome 6 Free"];
              # names = ["Iosevka Comfy Fixed" "Font Awesome 6 Free"];
              style = "Regular";
              size = 10.0;
            };
            position = "top";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs";
            colors = {
              statusline = "#ffffff";
              background = "#323232FA";
              inactiveWorkspace = {
                background = "#323232FA";
                border = "#323232";
                text = "#5c5c5c";
              };
            };
          }
        ];

        modifier = "Mod4";
        left = "h";
        down = "n";
        up = "e";
        right = "i";
        keybindings = {
          "${modifier}+Return" = "exec $term";
          "${modifier}+q" = "kill";
          "${modifier}+space" = "exec ${pkgs.dmenu}/bin/dmenu_path | ${menuscript} | xargs swaymsg exec --";
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+q" = "exit";
          "${modifier}+Shift+p" = "exec systemctl poweroff";
          "${modifier}+Shift+s" = "exec systemctl suspend";
          "${modifier}+${left}" = "focus left";
          "${modifier}+${down}" = "focus down";
          "${modifier}+${up}" = "focus up";
          "${modifier}+${right}" = "focus right";
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";
          "${modifier}+Shift+${left}" = "move left";
          "${modifier}+Shift+${down}" = "move down";
          "${modifier}+Shift+${up}" = "move up";
          "${modifier}+Shift+${right}" = "move right";
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";
          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";
          "${modifier}+0" = "workspace number 10";
          "${modifier}+Tab" = "workspace back_and_forth";
          "${modifier}+Shift+1" = "move container to workspace number 1";
          "${modifier}+Shift+2" = "move container to workspace number 2";
          "${modifier}+Shift+3" = "move container to workspace number 3";
          "${modifier}+Shift+4" = "move container to workspace number 4";
          "${modifier}+Shift+5" = "move container to workspace number 5";
          "${modifier}+Shift+6" = "move container to workspace number 6";
          "${modifier}+Shift+7" = "move container to workspace number 7";
          "${modifier}+Shift+8" = "move container to workspace number 8";
          "${modifier}+Shift+9" = "move container to workspace number 9";
          "${modifier}+Shift+0" = "move container to workspace number 10";
          "${modifier}+b" = "splith";
          "${modifier}+v" = "splitv";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+k" = "layout toggle split";
          "${modifier}+f" = "fullscreen";
          "${modifier}+r" = "mode resize";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+t" = "focus mode_toggle";
          "${modifier}+a" = "focus parent";
          "${modifier}+shift+a" = "focus child";
          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";
          "${modifier}+m" = "mode notifications";
          "${modifier}+Alt+s" = "sticky toggle";
        };
        input = {
          "type:keyboard" = {
            xkb_layout = "us";
            # this is managed in mixins/kanata.nix
            # xkb_variant = "colemak_dh";
            # xkb_options = "altwin:swap_lalt_lwin,caps:backspace";
          };
          "type:touchpad" = {
            tap = "enabled";
            natural_scroll = "enabled";
          };
        };
      };
      extraConfig = ''
        exec "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP XDG_SESSION_TYPE NIXOS_OZONE_WL; ${pkgs.systemd}/bin/systemctl --user start sway-session.target"
        exec ${pkgs.swayidle}/bin/swayidle -w \
        	timeout 300 '${pkgs.swaylock}/bin/swaylock -f -c 000000' \
        	timeout 600 'swaymsg "output * dpms off"' \
        	resume 'swaymsg "output * dpms on"' \
        	before-sleep '${pkgs.swaylock}/bin/swaylock -f -c 000000'
        exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1

        #set $mod Alt
        set $mod Mod4
        set $left h
        set $down n
        set $up e
        set $right i
        set $term ${pkgs.foot}/bin/foot

        default_border pixel
        hide_edge_borders smart
        smart_borders on

        #output * bg ~/images/wallpaper/graveyard.png fill

        floating_modifier $mod normal
        mode notifications {
        	bindsym Escape mode default
        	bindsym Return exec ${pkgs.mako}/bin/makoctl invoke; exec ${pkgs.mako}/bin/makoctl dismiss; mode default
        	bindsym d exec ${pkgs.mako}/bin/makoctl dismiss; mode default
        	bindsym Shift+d exec ${pkgs.mako}/bin/makoctl dismiss -a; mode default
        }

        bindsym $mod+p exec passmenu $menu_args
        bindsym --locked XF86AudioMute exec ${pkgs.pamixer}/bin/pamixer -t
        bindsym --locked XF86AudioLowerVolume exec ${pkgs.pamixer}/bin/pamixer -d 5
        bindsym --locked XF86AudioRaiseVolume exec ${pkgs.pamixer}/bin/pamixer -i 5
        bindsym --locked XF86AudioMicMute exec ${pkgs.pamixer}/bin/pamixer --default-source -t

        bindsym --locked XF86AudioNext exec ${pkgs.playerctl}/bin/playerctl next
        bindsym --locked XF86AudioPlay exec ${pkgs.playerctl}/bin/playerctl play-pause
        bindsym --locked XF86AudioPrev exec ${pkgs.playerctl}/bin/playerctl previous
        bindsym --locked XF86AudioStop exec ${pkgs.playerctl}/bin/playerctl stop

        for_window [app_id="^menu$"] floating enable, border none
        for_window [app_id="mpv"] sticky enable
        for_window [floating] border csd
        for_window [app_id="firefox" title="Picture-in-Picture"] floating enable, sticky enable, border none
        for_window [app_id="imv"] floating enable
        for_window [app_id="imv"] floating enable
        for_window [class="PacketTracer"] floating enable

        bindsym XF86MonBrightnessUp exec ${pkgs.light}/bin/light -A 5
        bindsym XF86MonBrightnessDown exec ${pkgs.light}/bin/light -U 5

        bindsym Print exec ${pkgs.grim}/bin/grim - | tee $(${pkgs.xdg-user-dirs}/bin/xdg-user-dir PICTURES)/screenshots/$(date +'%s.png') | wl-copy
        bindsym Shift+Print exec ${pkgs.grim}/bin/grim -g "$(${sel}/bin/sel)" - | tee $(${pkgs.xdg-user-dirs}/bin/xdg-user-dir PICTURES)/screenshots/$(date +'%s.png') | wl-copy
        bindsym Ctrl+Print exec ${pkgs.grim}/bin/grim -g "$(swaymsg -t get_tree | jq -j '.. | select(.type?) | select(.focused).rect | "\(.x),\(.y) \(.width)x\(.height)"')" - |tee $(${pkgs.xdg-user-dirs}/bin/xdg-user-dir PICTURES)/screenshots/$(date +'%s.png') | wl-copy

        bindsym $mod+l exec ${pkgs.swaylock}/bin/swaylock -c 070D0D

        exec ${pkgs.mako}/bin/mako >/tmp/mako.log 2>&1
        exec_always kanshi >/tmp/kanshi.log 2>&1
        
        include /etc/sway/d/*
      '';
    };
    };
  };
}
