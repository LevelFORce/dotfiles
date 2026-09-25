s configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
      [ # Include the results of the hardware scan. Do NOT delete this line!
            ./hardware-configuration.nix
	        ];

		  # Bootloader setup (Standard UEFI systemd-boot)
		    boot.loader.systemd-boot.enable = true;
		      boot.loader.efi.canTouchEfiVariables = true;

		        networking.hostName = "hp-pavilion-nixos";
			  networking.networkmanager.enable = true; # Enables easy Wi-Fi management

			    # Set your time zone.
			      time.timeZone = "America/New_York"; # Change to your actual location!

			        # Select internationalisation properties.
				  i18n.defaultLocale = "en_US.UTF-8";

				    # Enable the X11 windowing system & GNOME Desktop Environment
				      # (Feel free to change to KDE Plasma if you prefer it)
				        services.xserver.enable = true;
					  services.xserver.displayManager.gdm.enable = true;
					    services.xserver.desktopManager.gnome.enable = true;

					      # Enable sound with Pipewire
					        services.pulse.enable = false;
						  security.rtkit.enable = true;
						    services.pipewire = {
						        enable = true;
							    alsa.enable = true;
							        alsa.support32Bit = true;
								    pulse.enable = true;
								      };

								        # Enable display brightness control backend (via 'light' utility)
									  programs.light.enable = true;

									    # Define your user account
									      users.users.yourusername = { # <-- Change "yourusername" to your preferred login name!
									          isNormalUser = true;
										      description = "Primary User";
										          extraGroups = [ "networkmanager" "wheel" "video" ]; # "video" gives hardware permissions to adjust brightness keys
											      packages = with pkgs; [
											            # User apps can go here
												        ];
													  };

													    # Allow proprietary/unfree drivers (Required for NVIDIA)
													      nixpkgs.config.allowUnfree = true;

													        # =========================================================================
														  # GRAPHICS ACCELERATION (AMD iGPU + NVIDIA dGPU PRIME Offload)
														    # =========================================================================
														      hardware.graphics.enable = true;
														        services.xserver.videoDrivers = [ "nvidia" ];

															  hardware.nvidia = {
															      modesetting.enable = true;
															          powerManagement.enable = true; # Shuts the NVIDIA GPU completely off when not gaming
																      open = false; # Set to true if you prefer the open-source kernel modules (or stick to false for stability)

																          prime = {
																	        offload = {
																		        enable = true;
																			        enableOffloadCmd = true; # Generates the handy `nvidia-offload` CLI command wrapper
																				      };
																				            
																					          # Precise Bus IDs for your HP 15-ec1xxx (AMD Renoir APU + GTX 1650/1650Ti)
																						        amdgpuBusId = "PCI:5:0:0";
																							      nvidiaBusId = "PCI:1:0:0";
																							          };
																								    };

																								      # =========================================================================
																								        # CONTAINER VIRTUALIZATION & DISTROBOX
																									  # =========================================================================
																									    virtualisation.podman = {
																									        enable = true;
																										    dockerCompat = true; # Mocks docker commands safely using rootless podman
																										      };

																										        # System packages profile
																											  environment.systemPackages = with pkgs; [
																											      git
																											          vim
																												      wget
																												          distrobox # The container application for running your Accops Client
																													      onlyoffice-bin # Your pristine Microsoft Office replacement!
																													        ];

																														  # Do NOT change this value. It is the version of the software state your system started on.
																														    system.stateVersion = "24.11"; 
																														    }
																														    
