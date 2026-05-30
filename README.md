# ft-asciidoc.nvim

Enhance suport for gf,gx and gp and include efficient folding support.

## Prerequisite

neovim

## 🚀 Features

**Follow links**

- **gf** goto file. Support for include and xref macro.
- **gp** preview file. Open as textfile. Use [Asciidoctor.js](https://docs.asciidoctor.org/asciidoctor.js/latest/extend/extensions/) to render it. (Ensure to set relfileprefix. See [Mapping references to a different structure](https://docs.asciidoctor.org/asciidoc/latest/macros/inter-document-xref/#mapping-references-to-a-different-structure)
- **gx** open link. Support http,https,link, ftp macros.

**Folding**

## 📦 Installation

Use your preferred package manager to install the plugin.

### [lazy.nvim](https://github.com)

```lua
-- ft-asciidoc.lua
return { 
    {
      "rudolfa/ft-asciidoc.nvim",
      name = "ft-asciidoc",
      ft = "asciidoc",
      config = function()
        vim.g.asciidoc_folding = 1
        vim.g.asciidoc_browser = "firefox"
      end,
    }
}
```

## Usage
See
```vim
:h asciidoc-ft.txt
```

## License
Apache Licence 2.0
