{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    configure = {
      customLuaRC = ''
        vim.opt.tabstop = 2
        vim.opt.expandtab = true
        vim.opt.shiftwidth = 2
        vim.opt.number = true
        vim.opt.signcolumn = 'number'
        vim.opt.termguicolors = false
        vim.opt.mouse = ""
        vim.opt.completeopt = { "menu", "popup", "fuzzy", "noinsert" }
        vim.api.nvim_command('set clipboard+=unnamedplus')

        require('nvim-treesitter.configs').setup({
          highlight = { enable = true },
          indent = { enable = true },
        })

        -- see https://github.com/neovim/nvim-lspconfig/tree/master/lsp
        vim.lsp.config('gopls', { cmd = {'${pkgs.gopls}/bin/gopls'} })
        vim.lsp.config('nil_ls', { cmd = {'${pkgs.nil}/bin/nil'} })
        vim.lsp.enable({'gopls', 'nil_ls'})

        vim.api.nvim_create_autocmd('LspAttach', { callback = function(ev)
          local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
          if client:supports_method('textDocument/completion') then 
            local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
            client.server_capabilities.completionProvider.triggerCharacters = chars
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          end
          if not client:supports_method('textDocument/willSaveWaitUntil') and client:supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = ev.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = ev.buf, id = client.id })
              end,
            })
          end
        end })

        vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
        vim.keymap.set('i', '<c-space>', vim.lsp.completion.get)

        require('trouble').setup()                        				
      '';
      packages.myVimPackage.start = with pkgs.vimPlugins; [
        nvim-treesitter.withAllGrammars # Provides treesitter syntax highlighting grammars.
        nvim-lspconfig # Provides default vim.lsp.config entries.
        trouble-nvim # Displays a LSP troubles nicely.
        vim-visual-multi # Adds a Visual-Multi mode.
        vim-surround # Adds various mappings for editing surrounding pairs of things.
        nerdcommenter # Adds comment/uncomment functionality and mappings.
      ];
    };
  };
}
