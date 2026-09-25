# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
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

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."max" = {
    isNormalUser = true;
    description = "max";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.flatpak.enable = true;

  nix.nixPath = [
  "nixos-config=/etc/nixos/configuration.nix"
  "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
  "/nix/var/nix/profiles/per-user/root/channels"
  "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
  ];

  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    wget
    celluloid
    amberol
    kitty
    clang-tools
    gcc
    ntfs3g
    fastfetch
    curl
    nnn
    imagemagick 

    # gnome extensions below! >_<
    ##########################################
    # Add your GNOME Extensions here!
    gnomeExtensions.dash-to-panel
    gnomeExtensions.dash-to-dock
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    gnomeExtensions.gtk4-desktop-icons-ng-ding
    # Add your GNOME Extensions here!
    ##########################################
    # gnome extensions above! >_<

    gnome-software
    gnome-tweaks
    nodejs
    flatpak
    git
  ((vim-full.override {}).customize {
    name = "vim";
    
    # 1. Nix pulls down and installs all your plugins here
    vimrcConfig.packages.myplugins = {
      start = with vimPlugins; [ 
        vim-nix        # Native Nix language highlighting & indenting
        nerdtree       # Standard file tree
        vim-airline    # Standard status bar
        nnn-vim
        vim-sensible
        coc-nvim
        vim-airline-themes
        coc-basedpyright
        coc-clangd
      ]; 
    };

    # 2. Your custom keymaps and settings go here (NO plug#begin lines!)
    vimrcConfig.customRC = ''
      syntax on
      filetype plugin indent on

      " Set global indentation preferences
      set tabstop=2
      set shiftwidth=2
      set softtabstop=2
      set expandtab
      set autoindent
      set termguicolors
      set smartindent
      set number
      set relativenumber

      " Keymaps
      let mapleader = " "
      nnoremap <C-n> :NERDTreeToggle<CR>
      let g:airline#extensions#tabline#enabled = 1
      let g:airline_theme='distinguished'

      colorscheme habamax

      " Cursor configuration
      " Change cursor shape based on Vim mode for modern terminals (like Kitty)
      let &t_SI = "\e[5 q" " Enter Insert mode: Thin vertical line
      let &t_SR = "\e[4 q" " Enter Replace mode: Underline
      let &t_EI = "\e[2 q" " Exit to Normal mode: Block cursor

    '';
    })
  ];

  hardware.graphics.extraPackages = with pkgs; [
    nvidia-vaapi-driver
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware.graphics = {
	  enable = true;
  	enable32Bit = true; # Required for 32-bit games and legacy apps
  };
  # 3. Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Modesetting is required for most modern Wayland/X11 compositors
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking up.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs.
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not Nouveau).
    # Set to true for Turing or newer architectures (RTX 20-series, GTX 16-series, and above).
    # Set to false if you are running older GPUs.
    open = false;

    # Enable the Nvidia settings menu (nvidia-settings)
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?

}
