{ config, lib, pkgs, ... }: {
  config.services.kanata = {
    enable = true;
    keyboards.colemak.config = ''

(defsrc
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
  caps a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
)

(deflayer colemak-dh
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    f    p    b    j    l    u    y    ;    [    ]    \
  @ext a    r    s    t    g    m    n    e    i    o    '    ret
  lsft x    c    d    v    z    k    h    ,    .    /    rsft
  lctl lalt lmet           spc            ralt rmet rctl
)

(deflayer qwerty
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
  @ext a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lalt lmet           spc            ralt rmet rctl)

(defalias
  ext (layer-toggle extend)
  cmk (layer-switch colemak-dh)
  qwe (layer-switch qwerty)
  lpr S-9
  rpr S-0
  lbr S-[
  rbr S-]
  lan S-,
  ran S-.)

(deflayer extend
  lrld @cmk @qwe _    _    _    _    _    _    _    _    _    _    _    
  _    [    ]    @lbr @rbr _    esc  bspc home end  _    _    _    _
  _    @lan @ran @lpr @rpr 5    7    down up   rght pgup _    _    
  _    1    2    3    4    6    pgdn left 8    9    0    _    
  _    _    _              _              _    _    _)

    '';
  };
}
