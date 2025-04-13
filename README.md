# About
These are my neovim config files. 
## main commands
- `<space>ff telescope find files`
- `<space><space> telescope find buffers`
- `<space>fg telescope grep`
- `<space>tds show most important item in todo list`
- `<space>tdr remove most important item in todo list`
- `<space>tda add an item in todo list`

# installation
If the folder is empty, you can install it in one command:

```bash
git clone https://github.com/abhinav-jay/nvim-config.git ~/.config/nvim
```

Otherwise, you will have to do this:

```bash
rm -rf ~/.config/nvim/
git clone https://github.com/abhinav-jay/nvim-config.git ~/.config/nvim
touch ~/.config/nvim/lua/todo/todo.txt
```

## Notes
The todo list is located in a file called ~/.config/nvim/lua/todo/data.json.
When adding an item to the todo list, you need to give a name to the task and also give a priority number from 0 to 1000 depending on its priority with 0 being the least and 1000 being the most important.
If you want to just install the todo plugin, install it at https://github.com/abhinav-jay/todo-manager.nvim.
