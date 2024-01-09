local Job = require "plenary.job"

local M = {}

--- Path to im-select
---@type string
M.im_select = vim.fn.globpath(vim.o.rtp, "build/im-select")

local function switch_insert_im(buf)
  local insert_im = vim.b[buf].im_switch_insert_im
  if insert_im and insert_im ~= M.opts.normal_im then
    Job:new({
      command = M.im_select,
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
    command = M.im_select,
    args = { M.opts.normal_im },
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

---@class IMSwitchOptions
---@field normal_im string? IM to switch to in normal mode
---@field pattern string | string[] File patterns to enable IM switching for

---@type IMSwitchOptions
M.opts = {
  normal_im = "com.apple.keylayout.ABC",
  pattern = { "*.md", "*.txt" },
}

--- IM name to switch to in normal mode
--- @type string
--- @default "com.apple.keylayout.ABC"
M.opts.normal_im = "com.apple.keylayout.ABC"

---@param opts IMSwitchOptions
function M.setup(opts)
  if opts.normal_im then M.opts.normal_im = opts.normal_im end
  if opts.pattern then M.opts.pattern = opts.pattern end

  local group = vim.api.nvim_create_augroup("IMSwitch", { clear = true })

  vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    pattern = M.opts.pattern,
    callback = function(arg) switch_insert_im(arg.buf) end,
    group = group,
  })

  -- Switch to normal IM on leaving insert mode
  vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    pattern = M.opts.pattern,
    callback = function(arg) switch_normal_im(arg.buf) end,
    group = group,
  })
end

return M
