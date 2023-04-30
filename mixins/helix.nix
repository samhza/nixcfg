{ pkgs, config, inputs, ... }:

let
  tomlFormat = pkgs.formats.toml { };
  gen = cfg: (tomlFormat.generate "helix-languages.toml" cfg);
  #helixUnstable = inputs.helix.outputs.packages.${pkgs.hostPlatform.system}.helix;
  helixUnstable = pkgs.helix;
in
{
  config = {
    home-manager.users.sam = { pkgs, ... }: {
      xdg.configFile."helix/languages.toml".source = gen {
        nix = { auto-format = true; };
      };
      programs.helix = {
        enable = true;
        package =
          if pkgs.hostPlatform.system == "x86_64-linux"
          then helixUnstable
          else pkgs.helix;

        settings = {
          theme = "dracula";
          keys = let
            motion = {
              I = "insert_at_line_start";
              a = "insert_at_line_end";
              A = "append_mode";
              E = "keep_selections";
              A-E = "remove_selections";
              j = "move_next_word_end";
              J = "move_next_long_word_end";
              N = "join_selections";
              A-N = "join_selections_space";
              l = "jump_backward";
              L = "jump_forward";
              g = goto;
              r = {
                t = "find_till_char";
              };
              space = spc;
              C-w = window;
              C-3 = window;
              t = window;
            };
            window = {
              n="jump_view_down";
              e="jump_view_up";
              i="jump_view_right";
              C-n="jump_view_down";
              C-e="jump_view_up";
              C-i="jump_view_right";
              N="swap_view_down";
              E="swap_view_up";
              I="swap_view_left";
              "'"="vsplit";
              minus="hsplit";
            };
            spc = {
              "w" = window;
            };
            goto = {
              h="goto_line_start";
              i="goto_line_end";
            };
          in {
            normal = {
              n="move_line_down";
              e="move_line_up";
              k="search_next";
              K="search_prev";
            } // motion;
            select = {
              n="extend_line_down";
              e="extend_line_up";
              k="extend_search_next";
              K="extend_search_prev";
            } // motion;
          };
          editor = {
            line-number = "relative";
            mouse = true;
            cursorline = true;
            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };
            gutters = [ "diagnostics" "line-numbers" "spacer" ];
            true-color = true;
            lsp = {
              display-messages = true;
            };
          };
        };
      };
    };
  };
}
