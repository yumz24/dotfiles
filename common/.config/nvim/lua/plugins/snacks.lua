return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      hidden = true, -- hiddenファイルを表示する
      ignore = true, -- ignoredファイルを表示する
      sources = {
        explorer = {
          layout = {
            layout = {
              position = "right",
            },
          },
        },
      },
    },
  },
}
