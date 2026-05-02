local M = {}
local git = require('modules.utils.git')

-- ステータスラインの内容を動的に生成する関数
function _G.statusline_render()
  local branch = git.get_git_branch()
  local branch_display = ""
    if branch ~= "" then
      local dirty = git.is_dirty() and "*" or ""
      branch_display = string.format("  %s%s | ", branch, dirty)
    else
      branch_display = " no Git | "
    end  

  return table.concat({
    "%#StatusLineMode#", " %{toupper(mode())} ", "%*",
    "%#StatusLineGit#", branch_display, "%*",
    "%#StatusLineFile#", " %F ", " %m", " %r",
    "%=",                -- 左寄せ・中央の区切り
    " %{&fileencoding} ",
    " %y ",
    "%#StatusLinePos#", " | L:%l/%L ", " C:%c ", " %*",
  }, "")
end

function M.setup()
  -- 関数を呼び出す形式（%!v:lua...）に設定する
  vim.opt.statusline = "%!v:lua.statusline_render()"

  -- タブラインの設定
  vim.opt.showtabline = 2
  vim.opt.tabline = [[%!v:lua.require('modules.utils').tabline()]]
end

return M
