local orig_notify = vim.notify
vim.notify = function(msg, ...)
  if type(msg) == "string" and msg:match("Error executing vim.schedule Lua callback") then
    return
  end
  orig_notify(msg, ...)
end
