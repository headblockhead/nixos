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
      dotnet-sdk
    ];
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      # LSP, highlighting, and non-AI autocompletion.
      nvim-treesitter.withAllGrammars
      (pluginGit "stewartimel" "Metal-Vim-Syntax-Highlighting" "f2d69c2a048394bc47ad2b02dd9abc9cb89ee6c1" "sha256-XifdXHgTtGlKqk6oN8BbZku2eMGs8FQHID1Kh65DnFA=")
      lsp_signature-nvim
      nvim-lspconfig
      nvim-cmp
      luasnip
      cmp_luasnip
      cmp-nvim-lsp
      vim-nix
      (pluginGit "vrischmann" "tree-sitter-templ" "cf84ea53e2e2531f23009d676ac206090c1e2392" "sha256-CQ11t4beqkjhtZktrawuavgQPSFzbwJrU/aSbPsqBPA=")
      openscad-nvim
      (pluginGit "rafaelsq" "nvim-goc.lua" "7d23d820feeb30c6346b8a4f159466ee77e855fd" "1b9ri5s4mcs0k539kfhf5zd3fajcr7d4lc0216pbjq2bvg8987wn")

      # Errors, diagnostics, and debugging.
      trouble-nvim
      (pluginGit "sebdah" "vim-delve" "41d6ad294fb6dd5090f5f938318fc4ed73b6e1ea" "sha256-wMDTMMvtjkPaWtlV6SWlQ5B7YVsJ4gjPZKPactW8HAE=")

      # IDE features + helpful bits and bobs.
      nvim-tree-lua
      nerdcommenter
      vim-sleuth
      vim-surround
      vim-test
      vim-visual-multi
      targets-vim
      outline-nvim
      fzf-vim
      nvim-coverage
      (pluginGit "dkprice" "vim-easygrep" "d0c36a77cc63c22648e792796b1815b44164653a" "0y2p5mz0d5fhg6n68lhfhl8p4mlwkb82q337c22djs4w5zyzggbc")
      vim-lastplace
      nvim-test

      # UI + themes.
      nvim-web-devicons
      lualine-nvim
      dracula-nvim

      # Code time-tracking.
      vim-wakatime

      # VIM extras.
      plenary-nvim

      # AI features.
      copilot-vim
      CopilotChat-nvim
      codecompanion-nvim
    ];
    extraConfig = "lua require('init')";
  };
}
