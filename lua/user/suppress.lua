vim.notify = function(msg, log_level, _opts)
  if type(msg) == "string" and msg:match("Error executing vim.schedule Lua callback") then
    return
  end
  if type(msg) == "string" and msg:match("stack traceback") then
    return
  end
  vim.api.nvim_echo({ { msg } }, true, {})
end
