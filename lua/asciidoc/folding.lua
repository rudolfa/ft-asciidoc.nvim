-- Copyright 2026 Andreas Rudolf <ardev@gmx.de>
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://apache.org
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local M = {}

-- Global functions for Neovim's evaluation of foldexpr and foldtext
_G._asciidoc_foldexpr = function()
  local lnum = vim.v.lnum
  local line = vim.fn.getline(lnum)

  local match = line:match("^(=+)%s")
  if match then
    return ">" .. tostring(#match)
  end
  return "="
end

_G._asciidoc_foldtext = function()
  local foldstart = vim.v.foldstart
  local foldend = vim.v.foldend
  local line = vim.fn.getline(foldstart)

  local lines_count = foldend - foldstart + 1
  local info = string.format(" (%d Zeilen) ", lines_count)

  local numberwidth = vim.wo.number and vim.wo.numberwidth or 0

  -- In Neovim, `foldcolumn` can also be a string like "auto:1", so be sure to back it up.
  local foldcolumn = 0
  if type(vim.wo.foldcolumn) == "string" then
    local match = vim.wo.foldcolumn:match("%d+")
    foldcolumn = match and tonumber(match) or 1
  else
    foldcolumn = tonumber(vim.wo.foldcolumn) or 0
  end

  local window_width = vim.fn.winwidth(0) - foldcolumn - numberwidth
  local text_len = vim.fn.strdisplaywidth(line)
  local info_len = vim.fn.strdisplaywidth(info)
  local fill_len = window_width - text_len - info_len

  if fill_len < 0 then
    fill_len = 0
  end

  return line .. string.rep("·", fill_len) .. info
end

-- Switch, calc and back to normal
local function update_folds()
  if vim.bo.filetype == "asciidoc" then
    local save_view = vim.fn.winsaveview()

    vim.wo.foldmethod = "expr"
    vim.cmd("redraw")
    vim.wo.foldmethod = "manual"

    vim.fn.winrestview(save_view)
  end
end

function M.setup()
  -- Setting Folding options (v:lua references the global functions)
  vim.opt_local.foldexpr = "v:lua._asciidoc_foldexpr()"
  vim.opt_local.foldtext = "v:lua._asciidoc_foldtext()"
  vim.opt_local.foldlevel = 1
  vim.opt_local.foldlevelstart = 1
  vim.opt_local.foldenable = true

  -- Automatisation
  local group = vim.api.nvim_create_augroup("AsciiDocFastFold", { clear = false })
  vim.api.nvim_clear_autocmds({ group = group, buffer = 0 })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = group,
    buffer = 0,
    callback = update_folds,
    desc = "Update AsciiDoc folds on read/write",
  })

  -- Initial call
  update_folds()

  -- Mappings
  vim.keymap.set("n", "<LocalLeader>z", update_folds, { buffer = true, silent = true })

  -- Supplement to the cleanup
  local current_undo = vim.b.undo_ftplugin or ""
  vim.b.undo_ftplugin = current_undo
      ..
      " | silent! nunmap <buffer> <LocalLeader>z | silent! autocmd! AsciiDocFastFold * <buffer> | setlocal foldmethod< foldexpr<"
end

return M
