{ pkgs, home-manager, username, terminal, theme-components, ... }:
let
  gnomeExtensionsList = with pkgs.gnomeExtensions; [
	  appindicator
	  arcmenu
    dash-to-dock
    desktop-icons-ng-ding
    fly-pie
    hide-activities-button
    pop-shell
    top-bar-organizer
    vitals
    window-title-is-back
  ];

  gnomeshellTheme = "${theme-components.gtk-theme}";
  backgroundTheme = "${theme-components.background}";

  fontList = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" "NerdFontsSymbolsOnly" ]; })
  ];
in
{
  # ---- System Configuration ----
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable=true;
  };

  # Adding this because probably the pathsToLink lines to "share" folder https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/services/x11/desktop-managers/gnome.nix#L369-L371 will be removed because "shared" directory is too broad to link. So, below we link only the needed subdirectories of "share" dir
  environment.pathsToLink = [
    "/share/backgrounds" # TODO: https://github.com/NixOS/nixpkgs/issues/47173
  ];

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  programs.dconf.enable = true;

  services.gnome = {
    evolution-data-server.enable = true;
    gnome-keyring.enable = true;
  };

  gtk.iconCache.enable = true;

  environment.systemPackages = with pkgs; [ gnome.eog gnome.gnome-tweaks gnome.gnome-screenshot ];

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos
    gnome-tour
    ]) ++ (with pkgs.gnome; [
    gnome-music
    epiphany
    geary
    evince
    gnome-characters
    totem
    tali
    iagno
    hitori
    atomix
  ]);

  # ---- Home Configuration ----

  home-manager.users.${username} = { pkgs, ...}: {
    home.packages = gnomeExtensionsList ++ fontList;

    dconf.settings = {
        "org/gnome/desktop/background" = {
            "picture-uri" = "file:///run/current-system/sw/share/backgrounds/athena/"+backgroundTheme;
        };
        "org/gnome/desktop/background" = {
            "picture-uri-dark" = "file:///run/current-system/sw/share/backgrounds/athena/"+backgroundTheme;
        };
        "org/gnome/desktop/background" = {
            "picture-options" = "stretched";
        };
        "org/gnome/shell/extensions/user-theme" = {
            "name" = gnomeshellTheme;
        };
    };

    # It copies "./config/menus/gnome-applications.menu" source file to the nix store, and then symlinks it to the location.
    xdg.configFile."menus/applications-merged/gnome-applications.menu".source = ./config/menus/applications-merged/gnome-applications.menu;

    dconf.settings = {
      "org/gnome/shell".disable-user-extensions = false;
      "org/gnome/shell".enabled-extensions = (map (extension: extension.extensionUuid) gnomeExtensionsList)
      ++
      [
        "appindicatorsupport@rgcjonas.gmail.com"
        "arcmenu@arcmenu.com"
        "dash-to-dock@micxgx.gmail.com"
        "ding@rastersoft.com"
        "flypie@schneegans.github.com"
        "Hide_Activities@shay.shayel.org"
        "pop-shell@system76.com"
        "top-bar-organizer@julian.gse.jsts.xyz"
        "Vitals@CoreCoding.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "window-title-is-back@fthx"
      ];

      "org/gnome/shell".disabled-extensions = [
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
      ];

      "org/gnome/shell".favorite-apps = [ "kali-mimikatz.desktop" "kali-powersploit.desktop" "seclists.desktop" "payloadsallthethings.desktop" "shell.desktop" "powershell.desktop" "cyberchef.desktop" "fuzzdb.desktop" "securitywordlist.desktop" "autowordlists.desktop" ];

      # /desktop/applications/terminal
      "org/gnome/desktop/applications/terminal" = {
        exec = "${terminal}";
      };

      # /desktop/interface
      "org/gnome/desktop/interface" = {
        document-font-name = "JetBrainsMono Nerd Font Mono 11";
        enable-hot-corners = false;
        font-antialiasing = "grayscale";
        font-hinting = "slight";
        monospace-font-name = "JetBrainsMono Nerd Font Mono 11";
        font-name = "JetBrainsMono Nerd Font Mono 11";
      };

      # /desktop/wm/keybindings
      "org/gnome/desktop/wm/keybindings" = {
        show-desktop = ["<Super>D"];
        toggle-message-tray = "disabled";
        close = ["<Super>w"];
        maximize = "disabled";
        minimize = "disabled";
        move-to-monitor-down = "disabled";
        move-to-monitor-left = "disabled";
        move-to-monitor-right = "disabled";
        move-to-monitor-up = "disabled";
        move-to-workspace-down = "disabled";
        move-to-workspace-up = "disabled";
        move-to-corner-nw = "disabled";
        move-to-corner-ne = "disabled";
        move-to-corner-sw = "disabled";
        move-to-corner-se = "disabled";
        move-to-side-n = "disabled";
        move-to-side-s = "disabled";
        move-to-side-e = "disabled";
        move-to-side-w = "disabled";
        move-to-center = "disabled";
        toggle-maximized = "disabled";
        unmaximize = "disabled";
      };

      # /desktop/wm/preferences
      "org/gnome/desktop/wm/preferences" = {
        action-middle-click-titlebar = "none";
        button-layout = "appmenu:minimize,maximize,close";
        num-workspaces = 6;
        resize-with-right-button = true;
        titlebar-font = "JetBrains Mono Bold 11";
        workspace-names = ["🕵️" "📖" "🍒" "🎸" "🎮" "🐝"];
      };
 
      # Keybindings
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
        home = ["<Super>E"];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Super>L";
        command = "dm-tool lock";
        name = "Lock Screen";
      };
    
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<CTRL><ALT>T";
        command = "kitty";
        name = "Terminal";
      };
  
      "org/gnome/mutter" = {   
        dynamic-workspaces = false;
      };
 
      # Configure Extensions
      "org/gnome/shell/extensions/Logo-menu" = {
        menu-button-icon-click-type = 2;
        menu-button-icon-image = 6;
        menu-button-icon-size = 25;
        show-power-options = false;
      };

      "org/gnome/shell/extensions/arcmenu" = {
        arc-menu-icon=69;
        dash-to-panel-standalone = false;
        directory-shortcuts-list = [["Home" "user-home-symbolic" "ArcMenu_Home"] ["Documents" ". GThemedIcon folder-documents-symbolic folder-symbolic folder-documents folder" "ArcMenu_Documents"] ["Downloads" ". GThemedIcon folder-download-symbolic folder-symbolic folder-download folder" "ArcMenu_Downloads"] ["Music" ". GThemedIcon folder-music-symbolic folder-symbolic folder-music folder" "ArcMenu_Music"] ["Pictures" ". GThemedIcon folder-pictures-symbolic folder-symbolic folder-pictures folder" "ArcMenu_Pictures"] ["Videos" ". GThemedIcon folder-videos-symbolic folder-symbolic folder-videos folder" "ArcMenu_Videos"]];
        menu-background-color = "rgba(48,48,49,0.98)";
        menu-border-color = "rgb(60,60,60)";
        menu-button-appearance = "Icon";
        menu-foreground-color = "rgb(223,223,223)";
        menu-item-active-bg-color = "rgb(25,98,163)";
        menu-item-active-fg-color = "rgb(255,255,255)";
        menu-item-hover-bg-color = "rgb(21,83,158)";
        menu-item-hover-fg-color = "rgb(255,255,255)";
        menu-layout = "Whisker";
        menu-separator-color = "rgba(255,255,255,0.1)";
        multi-monitor = false;
        #pop-folders-data = { "Library Home" = "Library Home"; "Utilities" = "Utilities"; };
        prefs-visible-page = 0;
        recently-installed-apps = ["alacarte-made.desktop" "ettercap.desktop" "guymager.desktop" "autopsy.desktop" "jshell-java11-openjdk.desktop" "jconsole-java11-openjdk.desktop" "minicom.desktop" "org.codeberg.dnkl.footclient.desktop" "nm-connection-editor.desktop" "org.codeberg.dnkl.foot.desktop" "org.codeberg.dnkl.foot-server.desktop" "linguist.desktop" "yad-icon-browser.desktop" "org.kde.klipper.desktop" "yad-settings.desktop" "assistant.desktop" "qdbusviewer.desktop" "designer.desktop" "org.kde.kuserfeedback-console.desktop" "jshell-java17-openjdk.desktop" "jconsole-java17-openjdk.desktop" "kali-assetfinder.desktop" "kali-dcfldd.desktop" "kali-ewfacquire.desktop" "kali-ssdeep.desktop" "kali-xplico-start.desktop" "kali-truecrack.desktop" "kali-xplico-stop.desktop" "kali-grokevt-builddb.desktop" "kali-pasco.desktop" "kali-clamav.desktop" "kali-dc3dd.desktop" "kali-regripper.desktop" "kali-apktool.desktop" "kali-nipper.desktop" "kali-bytecode-viewer.desktop" "kali-rkhunter.desktop" "kali-grokevt-addlog.desktop" "kali-ext3grep.desktop" "kali-rifiuti.desktop" "kali-sentrypeer.desktop" "kali-vinetto.desktop" "kali-unhide.desktop" "kali-fcrackzip.desktop" "kali-ghidra.desktop" "kali-galleta.desktop" "kali-pev.desktop" "kali-grokevt-ripdll.desktop" "kali-reglookup.desktop" "kali-extundelete.desktop" "kali-javasnoop.desktop" "kali-hb-honeypot.desktop" "kali-jadx-gui.desktop" "kali-grokevt-parselog.desktop" "kali-grokevt-findlogs.desktop" "kali-safecopy.desktop" "kali-ddrescue.desktop" "kali-witnessme.desktop" "kali-missidentify.desktop" "kali-affcat.desktop" "kali-readpst.desktop" "kali-osrframework.desktop" "kali-chkrootkit.desktop" "kali-recoverjpeg.desktop" "kali-mdb-sql.desktop" "kali-myrescue.desktop" "thunar-settings.desktop" "thunar.desktop" "kdesystemsettings.desktop" "org.kde.discover.desktop"];
        show-category-sub-menus = true;
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        apply-custom-theme = true;
        autohide-in-fullscreen = false;
        background-opacity = 0.9;
        custom-theme-shrink = true;
        dash-max-icon-size = 48;
        dock-position = "BOTTOM";
        height-fraction = 0.9;
        intellihide = true;
        intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
        multi-monitor = true;
        preferred-monitor = -2;
        preferred-monitor-by-connector = "Virtual-1";
        preview-size-scale = 0.2;
        require-pressure-to-show = false;
        show-trash = false;
        transparency-mode = "FIXED";
      };

      "org/gnome/shell/extensions/ding" = {
        check-x11wayland = true;
      };

      "org/gnome/shell/extensions/pop-shell" = {
        show-skip-taskbar = false;
      };

      "org/gnome/shell/extensions/top-bar-organizer" = {
        center-box-order = ["Workspace Indicator" "media-player" "Space Bar" "media-player-controls"];
        left-box-order = ["LogoMenu" "ArcMenu" "menuButton" "appMenu" "Notifications" "places-menu" "apps-menu" "dateMenu" "activities"];
        right-box-order = ["dash-button" "power-menu" "battery-bar" "vitalsMenu" "pop-shell" "screenRecording" "screenSharing" "dwellClick" "a11y" "keyboard" "quickSettings"];
      };

      "org/gnome/shell/extensions/window-title-is-back" = {
        colored-icon = true;
        show-title = false;
      };

      "org/gnome/shell/extensions/flypie" = {
        active-stack-child = "menu-editor-page";
        center-background-image = "";
        center-background-image-hover = "";
        center-icon-crop = 1.0;
        center-icon-crop-hover = 1.0;
        center-icon-scale = 0.55000000000000004;
        center-size = 109.0;
        child-background-image = "";
        child-background-image-hover = "";
        child-color-mode = "fixed";
        child-color-mode-hover = "auto";
        child-icon-crop = 1.0;
        child-icon-crop-hover = 1.0;
        child-offset = 106.0;
        child-size = 63.0;
        global-scale = 1.6000000000000001;
        grandchild-background-image = "";
        grandchild-background-image-hover = "";
        menu-configuration="[{\"name\":\"Cyber Menu\",\"icon\":\"/usr/share/icons/hicolor/scalable/apps/athenaos-blue-net.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Blue Team Menu\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/blueteam.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Identify\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-identify-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Maltego\",\"icon\":\"kali-maltego\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b maltego -g\"},\"angle\":-1},{\"name\":\"Wapiti\",\"icon\":\"kali-wapiti\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b wapiti -x '-h'\"},\"angle\":-1},{\"name\":\"spiderfoot\",\"icon\":\"kali-spiderfoot\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b spiderfoot -x '--help'\"},\"angle\":-1},{\"name\":\"Searchsploit\",\"icon\":\"kali-searchsploit\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b searchsploit -p exploitdb\"},\"angle\":-1},{\"name\":\"OWASP ZAP\",\"icon\":\"kali-zaproxy\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b zaproxy -g\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Protect\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-protect-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"ClamAV\",\"icon\":\"kali-clamav\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b clamscan -p clamav -x '-h'\"},\"angle\":-1},{\"name\":\"Firewall Builder\",\"icon\":\"/usr/share/icons/hicolor/scalable/apps/kali-fwbuilder.svg\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b fwbuilder\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Detect\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-detect-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"SentryPeer\",\"icon\":\"kali-sentrypeer\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b sentrypeer -x '-h'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Respond\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-respond-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Foremost\",\"icon\":\"kali-foremost\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b foremost -x '-h'\"},\"angle\":-1},{\"name\":\"Galleta\",\"icon\":\"kali-galleta\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b galleta\"},\"angle\":-1},{\"name\":\"Ghidra\",\"icon\":\"kali-ghidra\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b ghidra -g\"},\"angle\":-1},{\"name\":\"Guymager\",\"icon\":\"/usr/share/icons/hicolor/scalable/apps/kali-guymager.svg\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b guymager -g -r\"},\"angle\":-1},{\"name\":\"ICAT\",\"icon\":\"kali-icat\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b icat -p sleuthkit\"},\"angle\":-1},{\"name\":\"ILS\",\"icon\":\"kali-ils\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b ils -p sleuthkit\"},\"angle\":-1},{\"name\":\"Mactime\",\"icon\":\"kali-mactime\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b mactime -p sleuthkit\"},\"angle\":-1},{\"name\":\"netsniff-ng\",\"icon\":\"kali-netsniff-ng\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b netsniff-ng -x '-h'\"},\"angle\":-1},{\"name\":\"OllyDbg\",\"icon\":\"kali-ollydbg\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b ollydbg -g\"},\"angle\":-1},{\"name\":\"Wireshark\",\"icon\":\"/usr/share/icons/hicolor/scalable/apps/kali-wireshark.svg\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b wireshark -p wireshark-qt -g\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Recover\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-recover-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Scrounge NTFS\",\"icon\":\"kali-scrounge-ntfs\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b scrounge-ntfs -x '-h'\"},\"angle\":-1}],\"angle\":0,\"data\":{},\"showLabels\":false}],\"id\":2,\"shortcut\":\"<Control><Alt>a\",\"angle\":-1,\"data\":{},\"centered\":false,\"touchButton\":false,\"superRMB\":false,\"showLabels\":false},{\"name\":\"VSCodium\",\"icon\":\"/usr/share/icons/hicolor/scalable/apps/vscode.svg\",\"type\":\"Command\",\"data\":{\"command\":\"codium\"},\"angle\":-1},{\"name\":\"Terminal\",\"icon\":\"/usr/share/icons/hicolor/scalable/apps/terminal.svg\",\"type\":\"Command\",\"data\":{\"command\":\"kitty\"},\"angle\":0},{\"name\":\"Firefox ESR\",\"icon\":\"/usr/share/icons/hicolor/scalable/apps/firefox-logo.svg\",\"type\":\"Command\",\"data\":{\"command\":\"firefox-esr\"},\"angle\":-1},{\"name\":\"Red Team Menu\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/redteam.svg\",\"shortcut\":\"<Primary>space\",\"centered\":false,\"id\":0,\"children\":[{\"name\":\"Information Gathering\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-info-gathering-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"dmitry\",\"icon\":\"kali-dmitry\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b dmitry\"},\"angle\":-1},{\"name\":\"nmap\",\"icon\":\"kali-nmap\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b nmap\"},\"angle\":-1},{\"name\":\"spiderfoot\",\"icon\":\"kali-spiderfoot\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b spiderfoot -x '--help'\"},\"angle\":-1},{\"name\":\"TheHarvester\",\"icon\":\"kali-theharvester\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b theharvester -x '-h'\"},\"angle\":-1},{\"name\":\"enum4linux\",\"icon\":\"kali-enum4linux\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b enum4linux\"},\"angle\":-1},{\"name\":\"wafw00f\",\"icon\":\"kali-wafw00f\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b wafw00f -x '-h'\"},\"angle\":-1},{\"name\":\"fierce\",\"icon\":\"kali-fierce\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b fierce -x '-h'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Vulnerability Assessment\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-vuln-assessment-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"legion (root)\",\"icon\":\"kali-legion\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b legion -r\"},\"angle\":-1},{\"name\":\"nikto\",\"icon\":\"kali-nikto\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b nikto -x '-h'\"},\"angle\":-1},{\"name\":\"Unix Privesc Check\",\"icon\":\"kali-unix-privesc-check\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b unix-privesc-check\"},\"angle\":-1}],\"angle\":0,\"data\":{},\"showLabels\":false},{\"name\":\"Web Application Analysis\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-web-application-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Wpscan\",\"icon\":\"kali-wpscan\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b wpscan -x '--help'\"},\"angle\":-1},{\"name\":\"Burpsuite\",\"icon\":\"kali-burpsuite\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b burpsuite -g\"},\"angle\":-1},{\"name\":\"dirb\",\"icon\":\"kali-dirb\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b dirb\"},\"angle\":-1},{\"name\":\"dirbuster\",\"icon\":\"kali-dirbuster\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b dirbuster -g\"},\"angle\":-1},{\"name\":\"ffuf\",\"icon\":\"kali-ffuf\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b ffuf -x '-h'\"},\"angle\":-1},{\"name\":\"wfuzz\",\"icon\":\"kali-wfuzz\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b wfuzz\"},\"angle\":-1},{\"name\":\"SQLMap\",\"icon\":\"kali-sqlmap\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b sqlmap -x '--wizard'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Password Attacks\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-password-attacks-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"John\",\"icon\":\"kali-john\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b john\"},\"angle\":-1},{\"name\":\"Hashcat\",\"icon\":\"kali-hashcat\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b hashcat -x '-h'\"},\"angle\":-1},{\"name\":\"Hydra\",\"icon\":\"kali-hydra\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b hydra -x '| grep --color=auto \\\"^\\\\|Supported services:\\\"; hydra-wizard.sh'\"},\"angle\":-1},{\"name\":\"CeWL\",\"icon\":\"kali-cewl\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b cewl -x '--help'\"},\"angle\":-1},{\"name\":\"Crunch\",\"icon\":\"kali-crunch\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b crunch\"},\"angle\":-1},{\"name\":\"RSMangler\",\"icon\":\"kali-rsmangler\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b rsmangler -x '-h'\"},\"angle\":-1},{\"name\":\"Medusa\",\"icon\":\"kali-medusa\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b medusa -x '-h'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Sniffing\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-sniffing-spoofing-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"MITM Proxy\",\"icon\":\"kali-mitmproxy\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b mitmproxy -x '-h'\"},\"angle\":-1},{\"name\":\"Responder\",\"icon\":\"kali-responder\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b responder -x '-h'\"},\"angle\":-1},{\"name\":\"Wireshark\",\"icon\":\"/usr/share/icons/hicolor/scalable/apps/kali-wireshark.svg\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b wireshark -p wireshark-qt -g\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Wireless Attacks\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-wireless-attacks-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Aircrack-ng\",\"icon\":\"kali-aircrack-ng\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b aircrack-ng\"},\"angle\":-1},{\"name\":\"Kismet\",\"icon\":\"kali-kismet\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b kismet -x '-h'\"},\"angle\":-1},{\"name\":\"Reaver\",\"icon\":\"kali-reaver\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b reaver -x '-h'\"},\"angle\":-1},{\"name\":\"WiFite\",\"icon\":\"kali-wifite\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b wifite -x '--help'\"},\"angle\":-1},{\"name\":\"Fern WiFi Cracker\",\"icon\":\"kali-fern-wifi-cracker\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b fern-wifi-cracker -g -r\"},\"angle\":-1},{\"name\":\"spooftooph\",\"icon\":\"kali-spooftooph\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b spooftooph -x '-h'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Reverse Engineering\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-reverse-engineering-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"NASM\",\"icon\":\"kali-metasploit-framework\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b nasm -x '-h'\"},\"angle\":-1},{\"name\":\"radare2\",\"icon\":\"kali-radare2\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b radare2 -x '-h'\"},\"angle\":-1},{\"name\":\"Ghidra\",\"icon\":\"kali-ghidra\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b ghidra -g\"},\"angle\":-1},{\"name\":\"EDB Debugger\",\"icon\":\"/usr/share/icons/hicolor/scalable/apps/kali-edb-debugger.svg\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b edb -g\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Exploitation\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-exploitation-tools-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Searchsploit\",\"icon\":\"kali-searchsploit\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b searchsploit -p exploitdb\"},\"angle\":-1},{\"name\":\"Metasploit\",\"icon\":\"kali-metasploit-framework\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b msfconsole -p metasploit -x '-h'\"},\"angle\":-1},{\"name\":\"SET\",\"icon\":\"kali-set\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b setoolkit -r -p set\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Post Exploitation\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/athena-maintaining-access-trans.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Powersploit\",\"icon\":\"kali-powersploit\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b powersploit -d /usr/share/windows/powersploit\"},\"angle\":-1},{\"name\":\"Mimikatz\",\"icon\":\"kali-mimikatz\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b mimikatz -d /usr/share/windows/mimikatz\"},\"angle\":-1},{\"name\":\"Evil WinRM\",\"icon\":\"kali-evil-winrm\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b evil-winrm -x '-h'\"},\"angle\":-1},{\"name\":\"ProxyChains\",\"icon\":\"kali-proxychains\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b proxychains4 -p proxychains-ng\"},\"angle\":-1},{\"name\":\"Weevely\",\"icon\":\"kali-weevely\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b weevely -x 'terminal -h'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false}],\"type\":\"CustomMenu\",\"data\":{},\"touchButton\":false,\"superRMB\":false,\"showLabels\":false,\"angle\":-1},{\"name\":\"PWNage Menu\",\"icon\":\"/usr/share/icons/hicolor/scalable/categories/social.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Discurity\",\"icon\":\"/usr/share/pixmaps/discord-logo-icon-transparent.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"ArmCord\",\"icon\":\"/usr/share/pixmaps/discord-app.png\",\"type\":\"Command\",\"data\":{\"command\":\"armcord\"},\"angle\":0},{\"name\":\"CybeeSec\",\"icon\":\"/usr/share/pixmaps/cybee_logo.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://discord.gg/AHXqyJHhGc\"},\"angle\":-1},{\"name\":\"Hack The Box\",\"icon\":\"/usr/share/pixmaps/htb.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://discord.gg/hackthebox\"},\"angle\":-1},{\"name\":\"PWNX\",\"icon\":\"/usr/share/pixmaps/pwnx.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://discord.gg/nXakaZdvwm\"},\"angle\":-1},{\"name\":\"Root Me\",\"icon\":\"/usr/share/pixmaps/rootme.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://discord.gg/rootme\"},\"angle\":-1},{\"name\":\"TryHackMe\",\"icon\":\"/usr/share/pixmaps/tryhackme-blue.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://discord.gg/bmN49cwrn6\"},\"angle\":-1},{\"name\":\"Offensive Security\",\"icon\":\"/usr/share/pixmaps/offsec-red.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://discord.gg/2DRcAhH7Vn\"},\"angle\":-1},{\"name\":\"Security Cert\",\"icon\":\"/usr/share/pixmaps/securitycert.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://discord.gg/U3GccWKvzM\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Hack The Box\",\"icon\":\"/usr/share/pixmaps/htb.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Submit Flag\",\"icon\":\"/usr/share/icons/htb-toolkit/htb-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-f'\"},\"angle\":0},{\"name\":\"Starting Point Machines\",\"icon\":\"/usr/share/icons/htb-toolkit/startingpoint.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Tier 0\",\"icon\":\"/usr/share/icons/htb-toolkit/Tier-0.svg\",\"type\":\"CustomMenu\",\"children\":[],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Tier 1\",\"icon\":\"/usr/share/icons/htb-toolkit/Tier-1.svg\",\"type\":\"CustomMenu\",\"children\":[],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Tier 2\",\"icon\":\"/usr/share/icons/htb-toolkit/Tier-2.svg\",\"type\":\"CustomMenu\",\"children\":[],\"angle\":-1,\"data\":{},\"showLabels\":false}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Available Machines\",\"icon\":\"/usr/share/icons/htb-toolkit/htb-machines.png\",\"type\":\"CustomMenu\",\"children\":[],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Stop Active Machine\",\"icon\":\"/usr/share/icons/htb-toolkit/htb-stop.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-s'\"},\"angle\":-1},{\"name\":\"Reset Active Machine\",\"icon\":\"/usr/share/icons/htb-toolkit/htb-reset.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-r'\"},\"angle\":-1},{\"name\":\"Website\",\"icon\":\"/usr/share/icons/htb-toolkit/htb-website.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://app.hackthebox.com\"},\"angle\":-1},{\"name\":\"VPN Connection\",\"icon\":\"/usr/share/icons/htb-toolkit/vpn-icon.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Disconnect OVPN\",\"icon\":\"network-offline-symbolic\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -c \\\"echo \\\\\\\"Disconnecting all VPN sessions...\\\\\\\";sudo killall openvpn;htb-toolkit -s\\\"\"},\"angle\":-1},{\"name\":\"Starting Point\",\"icon\":\"/usr/share/icons/htb-toolkit/startingpoint.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"EU Starting Point Free 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUSPFree1'\"},\"angle\":-1},{\"name\":\"US Starting Point Free 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USSPFree1'\"},\"angle\":-1},{\"name\":\"US Starting Point VIP 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USSPVIP1'\"},\"angle\":-1},{\"name\":\"EU Starting Point VIP 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUSPVIP1'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"Machines\",\"icon\":\"/usr/share/icons/htb-toolkit/machines.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"Free\",\"icon\":\"/usr/share/icons/htb-toolkit/vpnfree.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"EU Free 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUFree1'\"},\"angle\":-1},{\"name\":\"EU Free 2\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUFree2'\"},\"angle\":-1},{\"name\":\"EU Free 3\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUFree3'\"},\"angle\":-1},{\"name\":\"US Free 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USFree1'\"},\"angle\":-1},{\"name\":\"US Free 2\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USFree2'\"},\"angle\":-1},{\"name\":\"US Free 3\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USFree3'\"},\"angle\":-1},{\"name\":\"AU Free 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/au-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v AUFree1'\"},\"angle\":-1},{\"name\":\"SG Free 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/sg-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v SGFree1'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"VIP+\",\"icon\":\"/usr/share/icons/htb-toolkit/ic-vip+-big.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"EU VIP+\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"EU VIP+ 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP+1'\"},\"angle\":-1},{\"name\":\"EU VIP+ 2\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP+2'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"US VIP+ 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP+1'\"},\"angle\":-1},{\"name\":\"SG VIP+ 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/sg-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v SGVIP+1'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"VIP\",\"icon\":\"/usr/share/icons/htb-toolkit/ic-vip-big.svg\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"AU VIP\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/au-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v AUVIP1'\"},\"angle\":-1},{\"name\":\"EU VIP\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"EU VIP 1-10\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"EU VIP 2\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP2'\"},\"angle\":-1},{\"name\":\"EU VIP 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP1'\"},\"angle\":-1},{\"name\":\"EU VIP 10\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP10'\"},\"angle\":-1},{\"name\":\"EU VIP 9\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP9'\"},\"angle\":-1},{\"name\":\"EU VIP 8\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP8'\"},\"angle\":-1},{\"name\":\"EU VIP 7\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP7'\"},\"angle\":-1},{\"name\":\"EU VIP 6\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP6'\"},\"angle\":-1},{\"name\":\"EU VIP 5\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP5'\"},\"angle\":-1},{\"name\":\"EU VIP 4\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP4'\"},\"angle\":-1},{\"name\":\"EU VIP 3\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP3'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"EU VIP 21-28\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"EU VIP 21\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP21'\"},\"angle\":-1},{\"name\":\"EU VIP 22\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP22'\"},\"angle\":-1},{\"name\":\"EU VIP 23\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP23'\"},\"angle\":-1},{\"name\":\"EU VIP 24\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP24'\"},\"angle\":-1},{\"name\":\"EU VIP 25\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP25'\"},\"angle\":-1},{\"name\":\"EU VIP 26\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP26'\"},\"angle\":-1},{\"name\":\"EU VIP 27\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP27'\"},\"angle\":-1},{\"name\":\"EU VIP 28\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP28'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"EU VIP 11-20\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"EU VIP 11\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP11'\"},\"angle\":-1},{\"name\":\"EU VIP 12\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP12'\"},\"angle\":-1},{\"name\":\"EU VIP 13\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP13'\"},\"angle\":-1},{\"name\":\"EU VIP 14\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP14'\"},\"angle\":-1},{\"name\":\"EU VIP 15\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP15'\"},\"angle\":-1},{\"name\":\"EU VIP 16\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP16'\"},\"angle\":-1},{\"name\":\"EU VIP 17\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP17'\"},\"angle\":-1},{\"name\":\"EU VIP 18\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP18'\"},\"angle\":-1},{\"name\":\"EU VIP 19\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP19'\"},\"angle\":-1},{\"name\":\"EU VIP 20\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/eu-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v EUVIP20'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"US VIP\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"US VIP 1-10\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"US VIP 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP1'\"},\"angle\":-1},{\"name\":\"US VIP 2\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP2'\"},\"angle\":-1},{\"name\":\"US VIP 3\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP3'\"},\"angle\":-1},{\"name\":\"US VIP 4\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP4'\"},\"angle\":-1},{\"name\":\"US VIP 5\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP5'\"},\"angle\":-1},{\"name\":\"US VIP 6\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP6'\"},\"angle\":-1},{\"name\":\"US VIP 7\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP7'\"},\"angle\":-1},{\"name\":\"US VIP 8\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP8'\"},\"angle\":-1},{\"name\":\"US VIP 9\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP9'\"},\"angle\":-1},{\"name\":\"US VIP 10\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP10'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"US VIP 21-27\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"US VIP 21\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP21'\"},\"angle\":-1},{\"name\":\"US VIP 27\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP27'\"},\"angle\":-1},{\"name\":\"US VIP 26\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP26'\"},\"angle\":-1},{\"name\":\"US VIP 25\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP25'\"},\"angle\":-1},{\"name\":\"US VIP 24\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP24'\"},\"angle\":-1},{\"name\":\"US VIP 23\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP23'\"},\"angle\":-1},{\"name\":\"US VIP 22\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP22'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"US VIP 11-20\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"US VIP 11\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP11'\"},\"angle\":-1},{\"name\":\"US VIP 12\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP12'\"},\"angle\":-1},{\"name\":\"US VIP 13\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP13'\"},\"angle\":-1},{\"name\":\"US VIP 14\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP14'\"},\"angle\":-1},{\"name\":\"US VIP 15\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP15'\"},\"angle\":-1},{\"name\":\"US VIP 16\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP16'\"},\"angle\":-1},{\"name\":\"US VIP 17\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP17'\"},\"angle\":-1},{\"name\":\"US VIP 18\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP18'\"},\"angle\":-1},{\"name\":\"US VIP 19\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP19'\"},\"angle\":-1},{\"name\":\"US VIP 20\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/us-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v USVIP20'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"SG VIP\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/sg-flag.png\",\"type\":\"CustomMenu\",\"children\":[{\"name\":\"SG VIP 1\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/sg-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v SGVIP1'\"},\"angle\":-1},{\"name\":\"SG VIP 2\",\"icon\":\"/usr/share/icons/htb-toolkit/flags/sg-flag.png\",\"type\":\"Command\",\"data\":{\"command\":\"shell-rocket -b htb-toolkit -x '-v SGVIP2'\"},\"angle\":-1}],\"angle\":-1,\"data\":{},\"showLabels\":false}],\"angle\":-1,\"data\":{},\"showLabels\":false}],\"angle\":-1,\"data\":{},\"showLabels\":false}],\"angle\":-1,\"data\":{},\"showLabels\":false}],\"angle\":-1,\"data\":{},\"showLabels\":false},{\"name\":\"PWNX\",\"icon\":\"/usr/share/pixmaps/pwnx.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://pwnx.io\"},\"angle\":-1},{\"name\":\"Proving Grounds\",\"icon\":\"/usr/share/pixmaps/offsec-red.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://www.offensive-security.com/labs\"},\"angle\":-1},{\"name\":\"PortSwigger\",\"icon\":\"/usr/share/pixmaps/portswigger.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://portswigger.net/web-security/all-labs\"},\"angle\":-1},{\"name\":\"Root Me\",\"icon\":\"/usr/share/pixmaps/rootme.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://www.root-me.org/?lang=en\"},\"angle\":-1},{\"name\":\"PentesterLab\",\"icon\":\"/usr/share/pixmaps/pentesterlab.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://pentesterlab.com\"},\"angle\":-1},{\"name\":\"TryHackMe\",\"icon\":\"/usr/share/pixmaps/tryhackme-blue.png\",\"type\":\"Uri\",\"data\":{\"uri\":\"https://tryhackme.com\"},\"angle\":-1}],\"id\":1,\"shortcut\":\"<Shift><Control>space\",\"angle\":-1,\"data\":{},\"centered\":false,\"touchButton\":false,\"superRMB\":false,\"showLabels\":false}],\"id\":3,\"shortcut\":\"<Control>space\",\"angle\":-1}]";
        trace-color = "rgba(51,0,79,0)";
      };
    };
  };
}
