# gofmt.vim

A Vim plugin that runs `gofmt` when you save.  The cursor position and folds
are retained without causing a full screen redraw.


## Installation

Follow your package manager's instructions.


## Usage

Edit a `.go` file, then save it.  Alternatively, use `:Gofmt`.


## Config

| Name              | Default | Description                                                                                                   |
|-------------------|---------|---------------------------------------------------------------------------------------------------------------|
| `g:gofmt_exe`     | `gofmt` | Sets the executable to use when saving a file.                                                                |
| `g:gofmt_on_save` | `1`     | Enables or disables running `gofmt` on save.  Setting this to an empty string effectively disables the plugin |

If you want to use `goimports` instead of `gofmt`:

```vim
let g:gofmt_exe = 'goimports'
```
