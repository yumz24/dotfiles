local M = {}
local fn = vim.fn
local keymap_opts = { noremap = true, silent = true }
local window = require("modules.utils.window")

function M.run_lint(lang, lint_fn, label)
  if not lint_fn then
      vim.notify(label .. "lint関数が未定義です。", vim.log.levels.ERROR)
      return
  end
  vim.notify(label .. "解析を開始しました...", vim.log.levels.INFO, { title = "Linter" })
  local qf_list = lint_fn()
  if qf_list and #qf_list > 0 then
      window.open_qf_at_bottom()
      vim.notify(label .. "エラーが見つかりました。", vim.log.levels.WARN, { title = "Linter" })
  else
      vim.cmd("cclose")
      vim.notify(label .. "エラーは見つかりませんでした。", vim.log.levels.INFO, { title = "Linter" })
  end
end

return M
