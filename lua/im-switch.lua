local Job = require "plenary.job"

local M = {}

--- Path to im-select
---@type string
local im_select = vim.fn.globpath(vim.o.rtp, "build/im-select")

---@class IMSwitchOptions
---@field normal_im? string IM to switch to in normal mode
---@field filter? IMSwitchFilter|boolean Filter to enable IM switching for
---@field command? boolean Whether to create command to toggle IM switching

---@class IMSwitchFilter
---@field pattern? string | string[] File patterns to enable IM switching for
---@field bo? table<string, any> Buffer options to enable IM switching for

---@type IMSwitchOptions
local opts = {
  normal_im = "com.apple.keylayout.ABC",
  filter = {
    pattern = { "*.md", "*.txt" },
    bo = {
      readonly = false,
      buftype = "",
    },
  },
  command = true,
}

M.opts = opts

local function switch_insert_im(buf)
  local insert_im = vim.b[buf].im_switch_insert_im
  if insert_im and insert_im ~= opts.normal_im then
    Job:new({
      command = im_select,
      args = { insert_im },
      on_exit = function(_, return_val)
        if return_val ~= 0 then
          vim.notify("Failed to switch input method", vim.log.levels.ERROR)
        end
      end,
    }):start()
  end
end

local function switch_normal_im(buf)
  Job:new({
    command = im_select,
    args = { opts.normal_im },
    on_exit = function(j, return_val)
      if return_val == 0 then
        local insert_im = j:result()[1]
        vim.b[buf].im_switch_insert_im = insert_im
      else
        vim.notify("Failed to switch input method", vim.log.levels.ERROR)
      end
    end,
  }):start()
end

local autogroup = vim.api.nvim_create_augroup("IMSwitch", { clear = true })

--- Attach im-switch autocommands to given buffer
---@param buffer number Buffer number
function M.attach(buffer)
  vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    buffer = buffer,
    callback = function(arg) switch_insert_im(arg.buf) end,
    group = autogroup,
  })

  vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    buffer = buffer,
    callback = function(arg) switch_normal_im(arg.buf) end,
    group = autogroup,
  })

  vim.b[buffer].im_switch_attached = true
end

--- Detach im-switch autocommands from given buffer
---@param buffer number Buffer number
function M.detach(buffer)
  vim.api.nvim_clear_autocmds {
    event = { "InsertEnter", "InsertLeave" },
    buffer = buffer,
    group = autogroup,
  }

  vim.b[buffer].im_switch_attached = false
end

--- Create command to toggle im-switch for current buffer
function M.create_command()
  vim.api.nvim_create_user_command("IMSwitch", function()
    local buffer = vim.api.nvim_get_current_buf()
    if vim.b[buffer].im_switch_attached then
      M.detach(buffer)
    else
      M.attach(buffer)
    end
    vim.b[buffer].im_switch_manual = true
  end, {
    nargs = 0,
    desc = "Toggle im-switch for current buffer",
  })
end

--- Check if buffer matches given buffer options
---@param buf number Buffer number
---@param name string Buffer option name
---@param expected any|any[] Expected value(s)
---@return boolean
local function match_bo(buf, name, expected)
  if type(expected) == "table" then
    return vim.tbl_contains(expected, vim.bo[buf][name])
  else
    return vim.bo[buf][name] == expected
  end
end

---@param user_opts IMSwitchOptions
function M.setup(user_opts)
  if user_opts then opts = vim.tbl_extend("force", opts, user_opts) end

  if opts.filter then
    if type(opts.filte) == "boolean" then
      vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
        callback = function(arg)
          local buffer = arg.buf
          if vim.b[buffer].im_switch_manual or vim.b[buffer].im_switch_attached then
            return
          end
          M.attach(buffer)
        end,
        group = autogroup,
      })
    else
      vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
        pattern = opts.filter.pattern,
        callback = function(arg)
          local buffer = arg.buf
          if vim.b[buffer].im_switch_manual or vim.b[buffer].im_switch_attached then
            return
          end

          if opts.filter.bo then
            for name, expected in pairs(opts.filter.bo) do
              if not match_bo(buffer, name, expected) then return end
            end
          end
          M.attach(buffer)
        end,
        group = autogroup,
      })
    end
  end

  if opts.command then M.create_command() end
end

return M
