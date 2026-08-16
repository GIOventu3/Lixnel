# ASUS TUF F15 LAPTOP

{ config, pkgs, ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  # -----------------------------------------------------------------
  # SYSTEM CORE & PERFORMANCE (Zen Kernel, ZRAM, Ananicy)
  # -----------------------------------------------------------------
  boot.kernelPackages = pkgs.linuxPackages_zen;
  
  # Merged initrd & runtime kernel modules cleanly
  boot.initrd.availableKernelModules = [ "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "rtsx_pci_sdmmc" ];
  boot.kernelParams = [ 
    "nvidia-drm.modeset=1" 
    "pcie_port_pm=off" 
  ];
  
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };

  # ZRAM Memory Compression
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  # Bootloader setup
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;

  system.stateVersion = "26.05";

  # -----------------------------------------------------------------
  # NETWORKING & SECURITY
  # -----------------------------------------------------------------
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.networkmanager.dns = "none";
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 41641 ]; # Tailscale direct peer-to-peer connection
  };

  # Network Daemons & VPNs
  services.cloudflare-warp.enable = true;
  services.cloudflare-warp.openFirewall = true; 
  services.netbird.enable = true;
  services.tailscale.enable = true;

  # Localisation
  time.timeZone = "Asia/Yangon";
  i18n.defaultLocale = "en_US.UTF-8";

  # -----------------------------------------------------------------
  # GRAPHICS, DISPLAY & COMPOSITORS (GNOME + Niri Wayland)
  # -----------------------------------------------------------------
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Niri Wayland Compositor & Xwayland
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  # Mouse Input Tuning
  services.libinput = {
    enable = true;
    mouse.accelProfile = "flat";
    touchpad.accelProfile = "flat";
  };

  # Wayland Environment Variables (NVIDIA + Ozone)
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "0";
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # XDG Portals (Single unified config preventing conflicts)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" "gtk" ];
    };
  };

  # Hardware Acceleration & NVIDIA Setup
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # Hardware accelerated video decoding for Intel iGPU
      vaapiVulkan
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      sync.enable = false;
      intelBusId = "PCI:0:2:0";   
      nvidiaBusId = "PCI:1:0:0";  
    };
  };

  # Hardware integrations
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; 
  };
  hardware.steam-hardware.enable = true;

  # ASUS Laptop Daemons
  services.asusd.enable = true;
  services.supergfxd.enable = true;  

  # -----------------------------------------------------------------
  # AUDIO & AUDIO PRODUCTION
  # -----------------------------------------------------------------
  services.pulseaudio.enable = false;
  security.rtkit.enable = true; # Essential for low-latency audio scheduling
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true; # Low-latency routing for audio workflows / JamesDSP
  };

  # -----------------------------------------------------------------
  # HARDENED FIREFOX (Security + 144Hz Video Performance)
  # -----------------------------------------------------------------
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      Preferences = {
        # 144Hz & Video Acceleration Fixes
        "layout.frame_rate" = 144;
        "media.hardware-video-decoding.enabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "gfx.webrender.all" = true;
        "widget.dmabuf.force-enabled" = true;
        "gfx.canvas.accelerated" = true;
        "dom.ipc.processCount" = 8;

        # Security & Privacy Hardening
        "browser.tabs.unloadOnLowMemory" = true;
        "network.cookie.cookieBehavior" = 1;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "dom.private-attribution.submission.enabled" = false;
        "privacy.donottrackheader.enabled" = true;
        "privacy.fingerprintingProtection" = true;
        "browser.discovery.enabled" = false;

        # TLS / WARP / Connection Fixes
        "network.dns.disablePrefetch" = false;
        "network.dns.echconfig.enabled" = false;
        "network.prefetch-next" = false;
      };
    };
  };

  # -----------------------------------------------------------------
  # GAMING, VIRTUALIZATION & DEVELOPMENT
  # -----------------------------------------------------------------
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
  programs.gamescope = {
    enable = true;
    capSysNice = true; 
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  # Virtualization & Containers
  virtualisation.podman.enable = true;
  virtualisation.docker.enable = true; 
  virtualisation.virtualbox.host.enable = true;

  # AppImage Support
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Mobile / iOS Device Bridge
  services.usbmuxd.enable = true;

  # System Utilities & Printing
  services.printing.enable = true;
  services.udisks2.enable = true;
  security.polkit.enable = true;

  # Polkit Gnome Auth Agent Fix
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # -----------------------------------------------------------------
  # USERS & NIX SYSTEM MAINTENANCE
  # -----------------------------------------------------------------
  users.users."gio" = {
    isNormalUser = true;
    description = "GIO";
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "video" 
      "audio" 
      "power" 
      "docker" 
      "vboxusers" # Cleanly merged from top of script
    ];
  };

  # Automatic Nix Garbage Collection & Store Optimization
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-40.10.5"
    ];
    virtualbox.enableExtensionPack = true; 
  };

  # Fast Systemd Shutdown Timeouts
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
    DefaultTimeoutAbortSec = "10s";
  };

  # -----------------------------------------------------------------
  # FONTS & SYSTEM PACKAGES
  # -----------------------------------------------------------------
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
    # Terminal & Shell Utilities
    kitty
    tmux
    git
    vim
    helix
    wget
    fastfetch
    btop
    bottom
    cmatrix
    cava
    tty-clock
    sl
    lavat
    p7zip
    exiftool
    killall
    efibootmgr
    qdirstat
    mission-center

    # Development & Scripting
    vscode
    vscodium
    direnv
    python3
    python3Packages.pygobject3
    gtk4

    # Web, VPNs & Communication
    brave
    zoom-us
    ayugram-desktop
    riseup-vpn
    wgcf
    wireguard-tools
    netbird-ui
    cloudflare-warp
    (discord.override { withVencord = true; })

    # Gaming & Emulation
    lutris
    wine
    mangohud
    gamescope
    steam-run
    prismlauncher
    winboat

    # Audio & Video Production
    pipewire # Runtime utils
    pavucontrol
    jamesdsp
    obs-studio
    mpv
    audacious
    spotify
    sptlrx
    cmus
    termusic
    ffmpeg
    yt-dlp
    parabolic

    # Graphics, Themes & Desktop Components
    gimp
    thunar
    wofi
    waypaper
    swaybg
    mpvpaper
    swww
    awww
    linux-wallpaperengine
    ags
    eww
    wlogout
    swaylock
    noctalia-shell
    gnome-extension-manager
    gnomeExtensions.appindicator
    overskride
    networkmanager_dmenu
    brightnessctl
    asusctl
    playerctl
    polkit_gnome

    # System & Hardware Drivers
    distrobox
    qemu
    exfat
    ntfs3g
    libimobiledevice
    idevicerestore
    usbmuxd

    # Theme overrides
    (papirus-icon-theme.override { color = "violet"; })
  ];
}
