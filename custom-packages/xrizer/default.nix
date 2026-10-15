{
  fetchFromGitHub,
  lib,
  libGL,
  libxkbcommon,
  nix-update-script,
  openxr-loader,
  pkg-config,
  rustPlatform,
  shaderc,
  vulkan-loader,
  stdenv,
  cmake,
  python3,
  vulkan-headers,
  libx11,
  libxxf86vm,
  libxrandr,
  wayland,
}:
let
  platformPaths = {
    "aarch64-linux" = "bin/linuxarm64";
    "i686-linux" = "bin";
    "x86_64-linux" = "bin/linux64";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xrizer";
  version = "unstable-2026-09-15";

  src = fetchFromGitHub {
    owner = "Supreeeme";
    repo = "xrizer";
    rev = "0989a7fac2d1efb7ea82f5fe1a8ed30c3eeb9596";
    hash = "sha256-Rb1pssAq6Zx6VmQVQtGcThkA6zCwi5X7G7aHmdsDrJo=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = finalAttrs.src + "/Cargo.lock";
    allowBuiltinFetchGit = true;
  };
  cargoHash = null;

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
    shaderc
    cmake
    python3
  ];

  buildInputs = [
    libxkbcommon
    vulkan-loader
    openxr-loader

    vulkan-headers
    libx11
    libxxf86vm
    libxrandr
    wayland
  ];

  cargoBuildFlags = [
    "--features"
    "static-openxr"
  ];

  postPatch = ''
    substituteInPlace src/graphics_backends/gl.rs \
      --replace-fail 'libGLX.so.0' '${lib.getLib libGL}/lib/libGLX.so.0'
  '';

  postInstall = ''
    mkdir -p $out/lib/xrizer/$platformPath
    mv "$out/lib/libxrizer.so" "$out/lib/xrizer/$platformPath/vrclient.so"
    touch $out/lib/xrizer/bin/version.txt
  '';

  platformPath = platformPaths."${stdenv.hostPlatform.system}";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "XR-ize your favorite OpenVR games";
    homepage = "https://github.com/Supreeeme/xrizer";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Scrumplex ];
    platforms = builtins.attrNames platformPaths;
  };
})
