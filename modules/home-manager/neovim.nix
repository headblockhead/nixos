{ pkgs, account, ... }:

let
  pluginGit = owner: repo: ref: sha:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${repo}";
      version = ref;
      src = pkgs.fetchFromGitHub {
        owner = owner;
        repo = repo;
        rev = ref;
        sha256 = sha;
      };
      doCheck = false;
    };
in
{
  systemd.user.tmpfiles.rules = [
    "d /home/${account.username}/.vim 700 ${account.username} users - -"
    "d /home/${account.username}/.vim/backup 700 ${account.username} users - -"
    "d /home/${account.username}/.vim/swap 700 ${account.username} users - -"
    "d /home/${account.username}/.vim/undo 700 ${account.username} users - -"
    "L+ /home/${account.username}/.config/nvim/lua - - - - ${../../neovim}"
  ];

  home.packages = with pkgs;
    [
      silver-searcher
      cmake-language-server
      sumneko-lua-language-server
      nodePackages.prettier
      nixpkgs-fmt
      wl-clipboard
      nil
      wakatime
      openscad-lsp
      omnisharp-roslyn
      mono
      msbuild
    ];
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      # OpenSCAD
      openscad-nvim
      # HACKATIME
      vim-wakatime
      # Theming plugins
      lualine-nvim
      dracula-nvim
      # Everything else
      # Metal syntax highlighting.
      (pluginGit "tklebanoff" "metal-vim"
        "6970494a5490a17033650849f0a1ad07506cef2e"
        "14i8q9ikp3v4q7mpid9ir1azfqfm7fbksc65cpp51424clnqcapl")
      # Omnisharp
      (pluginGit "OmniSharp" "omnisharp-vim" "cdbf65bc4385d7026428d2f392b40a317725cc9c" "mM1ePRbjp0bqQMm2KBLZ4zdlKlUF14Pod6jM82Z28L8=")
      # Add fuzzy searching (Ctrl-P to search file names, space-p to search content).
      fzf-vim
      # Maintain last location in files.
      vim-lastplace
      # Syntax highlighting for Nix files.
      vim-nix
      # Github Copilot
      copilot-vim
      # Colour scheme.
      # Use :TSHighlightCapturesUnderCursor to see the syntax under cursor.
      playground
      nvim-treesitter.withAllGrammars
      # Go test coverage highlighting.
      (pluginGit "rafaelsq" "nvim-goc.lua"
        "7d23d820feeb30c6346b8a4f159466ee77e855fd"
        "1b9ri5s4mcs0k539kfhf5zd3fajcr7d4lc0216pbjq2bvg8987wn")
      # General test coverage highlighting.
      (pluginGit "ruanyl" "coverage.vim"
        "1d4cd01e1e99d567b640004a8122be8105046921"
        "1vr6ylppwd61rj0l7m6xb0scrld91wgqm0bvnxs54b20vjbqcsap")
      # Grep plugin to improve grep UX.
      (pluginGit "dkprice" "vim-easygrep"
        "d0c36a77cc63c22648e792796b1815b44164653a"
        "0y2p5mz0d5fhg6n68lhfhl8p4mlwkb82q337c22djs4w5zyzggbc")
      # Templ highlighting.
      (pluginGit "Joe-Davidson1802" "templ.vim"
        "2d1ca014c360a46aade54fc9b94f065f1deb501a"
        "1bc3p0i3jsv7cbhrsxffnmf9j3zxzg6gz694bzb5d3jir2fysn4h")
      # Add function signatures to autocomplete.
      lsp_signature-nvim
      # Configure autocomplete.
      nvim-cmp
      # Configure autocomplete.
      nvim-lspconfig
      # Snippets manager.
      luasnip
      # Add snippets to the autocomplete.
      cmp_luasnip
      # Show diagnostic errors inline.
      trouble-nvim
      # Go debugger.
      (pluginGit "sebdah" "vim-delve" "5c8809d9c080fd00cc82b4c31900d1bc13733571"
        "01nlzfwfmpvp0q09h1k1j5z82i925hrl9cg9n6gbmcdqsvdrzy55")
      # Replacement for netrw.
      nvim-web-devicons
      nvim-tree-lua
      # \c to toggle commenting out a line.
      nerdcommenter # preservim/nerdcommenter
      # Work out tabs vs spaces etc. automatically.
      vim-sleuth # tpope/vim-sleuth
      # Change surrounding characters, e.g. cs"' to change from double to single quotes.
      vim-surround # tpope/vim-surround
      vim-test # janko/vim-test
      vim-visual-multi # mg979/vim-visual-multi
      cmp-nvim-lsp
      targets-vim # https://github.com/wellle/targets.vim
    ];
    extraConfig = "lua require('init')";
  };
}
