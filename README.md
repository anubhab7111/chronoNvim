# ⏳ ChronoNvim

Track time spent on files in Neovim effortlessly!

ChronoNvim is a lightweight Neovim plugin that helps you track how much time you spend on each file. It automatically starts a timer when you open a buffer and stops it when you leave, saving the total time spent across sessions.

## 🚀 Features

- Automatic time tracking per file
- Saves session time persistently
- Displays time spent in HH:MM:SS format
- Simple commands to check tracked time

## 📦 Installation

Using **lazy.nvim**:

```lua
{
  "ushtro/chronoNvim",
  config = function()
    require("chronoNvim")
  end
}
```

Using **packer.nvim**:

```lua
use {
  "ushtro/chronoNvim",
  config = function()
    require("chronoNvim")
  end
}
```

## 📌 Usage

### Start Tracking

The plugin automatically starts tracking time when you enter a file in Neovim.

### Show Tracked Time

Run the following command to check the time spent on the current file:

```vim
:Chrono
```

Example output:

```
⏰ Time on /path/to/file:
