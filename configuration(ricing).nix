{ config, pkgs, ... }:{

  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader configuration for UEFI systems
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # This sets your boot menu delay
  boot.loader.timeout = 5; # changable to amount, 0 for faster boot

  # NixOS State Version safety rule
  system.stateVersion = "26.05";

  # Enable networking & NetworkManager
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ]; #The DNS
  networking.networkmanager.dns = "none";

  # Set your time zone
  time.timeZone = "Time Zones";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
 
  # Enable the X11 windowing system and GNOME Desktop Environment
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users."nixos" = {
    isNormalUser = true;
    description = "my-nixos"; #Change your name
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  # Enable experimental features for Nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Install Firefox
  programs.firefox.enable = true;

  # Ensures flatpak apps integrate nicely with desktop launchers
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gnome" "gtk" ];
        # Forces Niri to use the GTK file picker so sandboxed apps don't hang looking for Nautilus
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        # FIX: Explicitly pairs both portals so screenshare sessions don't drop out
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" "gtk" ];
      };
    };
  };


  # Enable XWayland explicitly for legacy apps like Steam
  programs.xwayland.enable = true;

  # Flatpak support
  services.flatpak.enable = true;

  # Enable Niri (wayland compositor)
  programs.niri.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable Podman containers
  virtualisation.podman.enable = true;

  # Status bar engine
  programs.waybar.enable = false;

  # Enable Polkit security service
  security.polkit.enable = true;

  # Global system software packages
  environment.systemPackages = with pkgs; [
    distrobox
    brave
    obs-studio
    fastfetch
    waypaper
    mpvpaper
    kitty
    wgcf
    wireguard-tools
    gnomeExtensions.appindicator
    btop
    cmatrix
    cava
    tmux
    exiftool
    ffmpeg
    ags
    wlogout
    git
    thunar
    p7zip
    wofi
    font-awesome
    overskride
    networkmanager_dmenu
    swaylock
    killall
    vesktop
    bottom
    xwayland-satellite
    awww
    swww
    vscode
    efibootmgr
    noctalia-shell
    gnome-extension-manager
    papirus-icon-theme
    papirus-folders
    eww
    vim
    playerctl
    polkit_gnome
    tty-clock
    cmatrix
    sl
    lavat     
    audacious
    sptlrx   
    steam-run
    python3
    
  ];

} # The closing of the whole config. #steam is working in this config
