let nixpkgs = import <nixpkgs> {};
in nixpkgs.buildFHSUserEnv {
   name = "fhs";
   targetPkgs = pkgs: [];
   multiPkgs = pkgs: [ 
	 		pkgs.dpkg
      pkgs.alsa-lib
      pkgs.dbus
      pkgs.fontconfig
      pkgs.libGL
      pkgs.libpulseaudio
      pkgs.libxkbcommon
      pkgs.makeWrapper
      pkgs.mesa
      pkgs.patchelf
      pkgs.speechd
      pkgs.udev
      pkgs.vulkan-loader
      pkgs.xorg.libX11
      pkgs.xorg.libXcursor
      pkgs.xorg.libXext
      pkgs.xorg.libXfixes
      pkgs.xorg.libXi
      pkgs.xorg.libXinerama
      pkgs.xorg.libXrandr
      pkgs.xorg.libXrender
	 ];
   runScript = "bash";
}
