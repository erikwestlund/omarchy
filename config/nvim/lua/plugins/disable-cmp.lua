return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      -- Disable auto-completion for .env files
      opts.enabled = function()
        local ft = vim.bo.filetype
        -- Disable for .env files and other sensitive config files
        if ft == "env" or ft == "dotenv" then
          return false
        end
        -- Also check filename patterns
        local fname = vim.fn.expand("%:t")
        if fname:match("^%.env") or fname:match("%.env%.") then
          return false
        end
        return true
      end
      return opts
    end,
  },
}
