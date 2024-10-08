{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
# Run the nvidia-offload command to run a program with gpu
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in {
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  # Supergfxd (command: supergfxctl) helps manage switching from the descrete and integrated gpus.
  services.supergfxd = {
    enable = true;
    settings = {
      vfio_enable = true;
      vfio_save = true;
      always_reboot = false;
      no_logind = false;
      logout_timeout_s = 20;
      hotplug_type = "Asus";
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_zen;
  systemd.services.supergfxd.path = [pkgs.kmod pkgs.pciutils];
  # Even if you use Wayland, this is still requirered or else the driver
  # won't install
  services.udev.packages = with pkgs; [linuxPackages.nvidia_x11];
  services.xserver.videoDrivers = ["nvidia"];
  boot.kernel.sysctl."vm.max_map_count" = 2147483642;
  services.power-profiles-daemon.enable = true;
  services.acpid.enable = true;
  boot.initrd.kernelModules = ["amdgpu" "nvidia" "nvidia_uvm" "nvidia_drm" "nvidia_modeset"];
  boot.kernelParams = ["nvidia-drm.modeset=1"];
  # boot.extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
  boot.blacklistedKernelModules = ["noveau"];
  programs.corectrl.enable = true;
  services.auto-cpufreq.enable = false;
  services.upower.enable = true;
  environment.systemPackages = [nvidia-offload];
  programs.rog-control-center.enable = true;

  hardware.amdgpu.initrd.enable = lib.mkDefault true;

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaPersistenced = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      sync.enable = false;
      amdgpuBusId = "PCI:10:0:0";
	  nvidiaBusId = "PCI:1:0:0";
    };
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "550.120";
      sha256_64bit = "sha256-gBkoJ0dTzM52JwmOoHjMNwcN2uBN46oIRZHAX8cDVpc=";
      sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
      openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
      settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
      persistencedSha256 = "sha256-ztEemWt0VR+cQbxDmMnAbEVfThdvASHni4SJ0dTZ2T4=";
    };
  };

  hardware.opengl = {
    enable = true;
    #driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };
}
