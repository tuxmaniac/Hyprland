{
  lib,
  version,
  src,
  wlroots,
  hwdata,
  libdisplay-info,
  libliftoff,
  enableXWayland ? true,
  enableNvidiaPatches ? false,
  fetchFromGitLab
}:
wlroots.overrideAttrs (old: {
  inherit version enableXWayland;

  pname = "${old.pname}-hyprland${lib.optionalString enableNvidiaPatches "-nvidia"}";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "wlroots";
    repo = "wlroots";
    rev = "c74f89d4f84bfed0284d3908aee5d207698c70c5";
    hash = "sha256-LlxE3o3UzRY7APYVLGNKM30DBMcDifCRIQiMVSbYLIc=";
  };

  patches =
    (old.patches or [])
    ++ (lib.optionals enableNvidiaPatches [
      ./patches/wlroots-nvidia.patch
    ])
    ++ [
      # https://gitlab.freedesktop.org/wlroots/wlroots/-/merge_requests/4154
      ./patches/wlr_output_group.patch
    ];

  buildInputs = old.buildInputs ++ [hwdata libliftoff libdisplay-info];

  NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=maybe-uninitialized"
  ];
})
