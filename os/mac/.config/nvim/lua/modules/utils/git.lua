local M = {}

-- Gitのブランチ名を取得
function M.get_git_branch()
  local branch = vim.fn.system("git branch --show-current 2> /dev/null | tr -d '\\n'")

  if branch ~= "" then
    return branch
  else
    return ""
  end
end

-- 変更があるかの確認
function M.is_dirty()
  local res = vim.fn.system("git status --porcelain 2> /dev/null")
  -- 結果が空でなければ、何らかの変更（修正・削除・未追記）がある
  return res ~= ""
end

return M
