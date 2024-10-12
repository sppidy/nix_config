# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "Ghosty";

  # Enable networking
  networking.networkmanager.enable = true;
  
  #Enable i2c
  hardware.i2c.enable = true;

  #Timezone.
  time.timeZone = "Asia/Kolkata";
  
  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.spidy = {
    isNormalUser = true;
    description = "spidy";
    extraGroups = [ "networkmanager" "wheel" "bluetooth" ];
    packages = with pkgs; [];
  };
  
  #Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  #services.desktopManager.gnome.enable = true;
  #services.desktopManager.cosmic.enable = true;
  #services.displayManager.cosmic-greeter.enable = true;
  #hardware.system76.enableAll = true;
  #services.xserver.enable = true;
  #services.desktopManager.plasma6.enable = true;
  #services.displayManager.sddm.enable = true;
  #services.displayManager.sddm.wayland.enable = true;
  hardware.pulseaudio.enable = false;
  #Hyprland
  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
  };
  security.polkit.enable = true;
  #Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];

  #ZRAM
  zramSwap = {
     enable = true;
     algorithm = "zstd";
     priority = 2;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true; 
  environment.systemPackages = with pkgs; [
     pkgs.curl
     pkgs.neovim
     pkgs.bluez
     pkgs.bluez-alsa
     pkgs.nettools
     pkgs.iproute2
     pkgs.ags
     pkgs.fd
     pkgs.kdeconnect
     pkgs.matugen
     pkgs.discord
     pkgs.hyprlock
  ];
  environment.variables = rec {NIXPKGS_ALLOW_UNFREE = 1;};
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "24.11";
  security.rtkit.enable = true;
  services.pipewire = {
 	enable = true;
  	alsa.enable = true;
  	alsa.support32Bit = true;
  	pulse.enable = true;
	# If you want to use JACK applications, uncomment this
  	#jack.enable = true;
  };
  services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
    "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" "a2dp_aac"];
    };
  };
}
