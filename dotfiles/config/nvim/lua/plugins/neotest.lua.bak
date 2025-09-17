return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    'nvim-neotest/neotest-jest',
    "nvim-neotest/nvim-nio",
    "nvim-neotest/neotest-plenary",
    'nvim-neotest/neotest-vim-test',
    "marilari88/neotest-vitest",
  },
  config = function ()
      require("neotest").setup({
          adapters = {
              require('neotest-jest')({
                  jestCommand = "npm test --",
                  jestConfigFile = "custom.jest.config.ts",
                  env = { CI = true },
                  cwd = function(path)
                      return vim.fn.getcwd()
                  end,
              }),
              require("neotest-plenary"),
              require("neotest-vim-test")({
                  ignore_file_types = { "python", "vim", "lua" },
              }),
              require('neotest-vitest')
          },
      })

  end
}
