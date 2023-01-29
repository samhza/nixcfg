{
  config,
  pkgs,
  lib,
  ...
}:
pkgs.sway.override {
  sway-unwrapped = pkgs.sway-unwrapped.override {
    wlroots_0_16 =
      (pkgs.wlroots_0_16.overrideAttrs (oa: {
         postPatch = (oa.postPatch or "") + ''
           sed -i '/^uint32_t wlr_output_preferred_read_format/a return DRM_FORMAT_XRGB8888;' types/output/render.c
           substituteInPlace render/gles2/renderer.c --replace "glFlush();" "glFinish();"
         '';
       }));
  };
}
