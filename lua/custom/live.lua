local M = {}

local job_id = nil
local url = nil

local function notify(msg)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.INFO, { title = "LiveVim" })
  end)
end

local function copy(text)
  vim.schedule(function()
    vim.fn.setreg("+", text)
    vim.fn.setreg("*", text)
  end)
end

local function exists(path)
  return vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1
end

local function write(path, content)
  local f = io.open(path, "w")
  if f then
    f:write(content)
    f:close()
  end
end

local function strip_ansi(str)
  return str:gsub("\27%[[0-9;]*m", "")
end

local function ensure_vite()
  local cwd = vim.fn.getcwd()

  if not exists(cwd .. "/package.json") then
    notify("📦 package.json not found, initializing npm...")
    vim.fn.system("npm init -y")
  end

  if not exists(cwd .. "/node_modules/vite") then
    notify("⚡ Vite not found, installing...")
    vim.fn.system("npm install vite --save-dev")
  end

  if not exists(cwd .. "/vite.config.js") then
    write(
      cwd .. "/vite.config.js",
      [[
import { defineConfig } from "vite"
export default defineConfig({
  server: { port: 5173, open: false }
})
]]
    )
  end

  if not exists(cwd .. "/index.html") then
    write(
      cwd .. "/index.html",
      [[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>LiveVim 🚀</title>
  <style>
    body { font-family: system-ui, sans-serif; display: grid; place-items: center; height: 100vh; margin: 0; background: #0f172a; color: #f8fafc; }
    .card { text-align: center; padding: 2rem; border-radius: 1rem; background: #1e293b; box-shadow: 0 10px 15px -3px rgba(0,0,0,0.1); }
    h1 { color: #38bdf8; }
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 LiveVim is running</h1>
    <p>Vite + Neovim environment is ready.</p>
  </div>
</body>
</html>
]]
    )
  end
end

local function running()
  return job_id ~= nil
end

function M.start()
  if running() then
    notify("🟢 Live server is already running")
    return
  end

  url = nil
  ensure_vite()
  notify("🚀 Starting live server...")

  job_id = vim.fn.jobstart({ "npx", "vite", "--clearScreen", "false" }, {
    stdout_buffered = false,
    stderr_buffered = false,

    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if type(line) == "string" then
          line = strip_ansi(line)
          local found = line:match("http://localhost:%d+")
          if found and not url then
            url = found
            copy(url)
            notify("🌍 Server running at: " .. url)
            notify("📋 URL copied to clipboard")
            vim.fn.jobstart({ "xdg-open", url }, { detach = true })
          end
        end
      end
    end,

    on_exit = function()
      job_id = nil
      url = nil
      notify("🛑 Live server stopped")
    end,
  })

  if job_id <= 0 then
    job_id = nil
    notify("❌ Failed to start live server")
  end
end

function M.stop()
  if not running() then
    notify("⚠️ Live server is not running")
    return
  end

  vim.fn.jobstop(job_id)
  job_id = nil
  notify("🔌 Shutting down server...")
end

function M.restart()
  notify("🔄 Restarting live server...")
  M.stop()
  vim.defer_fn(M.start, 300)
end

function M.setup()
  vim.api.nvim_create_user_command("Live", M.start, {})
  vim.api.nvim_create_user_command("LiveStart", M.start, {})
  vim.api.nvim_create_user_command("LiveStop", M.stop, {})
  vim.api.nvim_create_user_command("LiveRestart", M.restart, {})
end

return M
