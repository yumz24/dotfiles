local M = {}
local git = require('lib.utils.git')

function _G.statusline_render()
  local branch = git.get_git_branch()
  local dirty = git.is_dirty() and "*" or ""
  local git_info = (branch ~= "") and string.format("  %s%s | ", branch, dirty) or " no Git | "

  return table.concat({
    "%#StatusLineMode# %{toupper(mode())} %*",
    "%#StatusLineGit#", git_info, "%*",
    " %F %m %r %=",
    " %y | L:%l/%L C:%c "
  }, "")
end

function M.setup()
  vim.opt.statusline = "%!v:lua.statusline_render()"
  vim.opt.showtabline = 2
  vim.opt.tabline = [[%!v:lua.require('lib.utils').tabline()]]
end

return M
