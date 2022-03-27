# :telescope: telescope-ports.nvim

Shows ports that are open on your system and gives you the ability to kill their process.(linux only)

# Installation

### Vim-Plug

```viml
Plug "rcarriga/nvim-notify"
Plug "nvim-telescope/telescope.nvim"
Plug "LinArcX/telescope-ports.nvim"
```

### Packer

```lua
use { 'rcarriga/nvim-notify', branch = "master" }
use { "nvim-telescope/telescope.nvim" }
use { "LinArcX/telescope-ports.nvim" }
```

# Setup and Configuration

```lua
require('telescope').load_extension('ports')
```

# Usage
`:Telescope ports`

## SUDO_ASKPASS
telescope-ports.nvim uses `sudo` internally, so we need to setup an __askpass helper__ for it.

I use **gnome-ssh-askpass** but you can use other alternatives like: **lxqt-openssh-askpass**

Just add this line into your `.bashrc` or `.zshrc`:

`export SUDO_ASKPASS=/usr/bin/gnome-ssh-askpass`

## Open ports for testing
You can use this python script to open a specific port:

``` python
import socket;

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM);

s.bind(('0.0.0.0', 1013));
s.listen(1);

conn, addr = s.accept();

print('Connected with ' + addr[0] + ':' + str(addr[1]))

```

# Contribution
If you have any idea to improve this project, please create a pull-request for it. To make changes consistent, i have some rules:
1. Before submit your work, please format it with [StyLua](https://github.com/JohnnyMorganz/StyLua).
    1. Just go to root of the project and call: `stylua .`

2. There should be a one-to-one relation between features and pull requests. Please create separate pull-requests for each feature.
3. Please use [snake_case](https://en.wikipedia.org/wiki/Snake_case) for function names ans local variables
4. If your PR have more than one commit, please squash them into one.
5. Use meaningful name for variables and functions. Don't use abbreviations as far as you can.
