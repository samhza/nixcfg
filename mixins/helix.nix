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
      # xdg.configFile."helix/languages.toml".source = gen {
      #   nix = { auto-format = true; };
      # };
      programs.helix = {
        enable = true;
        package =
          if pkgs.hostPlatform.system == "x86_64-linux"
          then helixUnstable
          else pkgs.helix;

        settings = {
          theme = "gruvbox_dark_hard";
          keys = let
            motion = {
              I = "insert_at_line_start";
              E = "keep_selections";
              A-E = "remove_selections";
              j = "move_next_word_end";
              J = "move_next_long_word_end";
              N = "join_selections";
              A-N = "join_selections_space";
              l = "jump_backward";
              L = "jump_forward";
              g = goto;
              x = "extend_to_line_bounds";
            } // window;
            window = {
              "C-n" = "rotate_view";
              "C-p" = "rotate_view_reverse";
              "C-'" = "hsplit";
              "C-w" = "wclose";
              "A-w" = ":bclose";
              "C-," = "goto_last_accessed_file";
            };
            goto = {
            };
          in {
            insert = window;
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
            jump-label-alphabet = "arstneiodhwfuy";
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
