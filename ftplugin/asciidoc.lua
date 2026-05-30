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

if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = 1

-- ---------------------------------------------------------
-- Support asciidoc file references for gf (Open file)
-- ---------------------------------------------------------
vim.opt_local.isfname:append(":,#,[")

-- includeexpr expects a classic Vimscript expression
vim.opt_local.includeexpr = [[substitute(v:fname,'\(link:\|include::\|xref:\)\(.\{-}\)\([#\[].*\)','\2','g')]]

-- ---------------------------------------------------------
-- OS Platform-independent call of browser
-- ---------------------------------------------------------
local browser = vim.g.asciidoc_browser
if not browser or browser == "" then
  if vim.fn.has("mac") == 1 then
    browser = "open"
  elseif vim.fn.has("win32") == 1 then
    browser = "rundll32 url.dll,FileProtocolHandler"
  else
    -- Fallback für Linux (z.B. openSUSE Tumbleweed)
    browser = "xdg-open"
  end
  vim.g.asciidoc_browser = browser
end

-- ---------------------------------------------------------
-- Helperfunction for gx (Open Link )
-- ---------------------------------------------------------
local function open_asciidoc_link()
  local raw_word = vim.fn.expand("<cWORD>")
  local url = vim.split(raw_word, "%[")[1]
  url = string.gsub(url, "^link:", "")

  if url:match("^https?://") or url:match("^file://") or url:match("^ftp://") then
    vim.fn.jobstart({ vim.g.asciidoc_browser, url })
  else
    vim.notify("Found no valid URL: " .. url, vim.log.levels.WARN)
  end
end

-- ---------------------------------------------------------
-- Cleanup
-- ---------------------------------------------------------
vim.b.undo_ftplugin = "setlocal isfname< includeexpr< | silent! nunmap <buffer> gp | silent! nunmap <buffer> gx"

-- ---------------------------------------------------------
-- Mappings
-- ---------------------------------------------------------
vim.keymap.set("n", "gp", function()
  vim.fn.jobstart({ vim.g.asciidoc_browser, vim.fn.expand("%") })
end, { buffer = true, silent = true, desc = "Open current AsciiDoc file in browser" })

vim.keymap.set("n", "gx", open_asciidoc_link, { buffer = true, silent = true, desc = "Open AsciiDoc link" })

-- ---------------------------------------------------------
-- Folding activate by default
-- ---------------------------------------------------------
if vim.fn.has("folding") == 1 and vim.g.asciidoc_folding == 1 then
  require("asciidoc.folding").setup()
end
