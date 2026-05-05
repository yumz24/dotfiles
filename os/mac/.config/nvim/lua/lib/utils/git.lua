local M = {}

-- Gitのブランチ名を取得
function M.get_git_branch()
  local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\\n'")
  return (branch ~= "") and branch or ""
end

-- 変更（Dirty）があるか確認
function M.is_dirty()
  local res = vim.fn.system("git status --porcelain 2> /dev/null")
  return res ~= ""
end

return M
