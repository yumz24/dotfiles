local M = {}

function M.setup()
  print("LSP setup loaded")
  -- vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
  vim.opt.omnifunc = "v:lua.vim.lsp.omnifunc"

  -- 共通設定（全LSPに適用）
  vim.lsp.config("*", {
    flags = {
      debounce_text_changes = 150,
    },
  })

  -- =========================
  -- Lua (lua_ls)
  -- =========================
  vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = { ".git", ".luarc.json" },
    settings = {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
        },
      },
    },
  })

  -- =========================
  -- Python (pyright)
  -- =========================
  vim.lsp.config("pyright", {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {".git" },
  })

  -- vim.lsp.config("ruff", {
  --   cmd = { 'ruff', 'server' },
  --   filetypes = { 'python' },
  --   root_markers = { 'pyproject.toml' },
  -- })
  --
  -- vim.lsp.enable('ruff')

  -- 有効化
  vim.lsp.enable({ "lua_ls", "pyright" })
end

return M
