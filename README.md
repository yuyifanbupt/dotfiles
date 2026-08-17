# dotfiles

My Personal dotfiles configuration repo.


## Usage

```bash
git clone https://github.com/yuyifanbupt/dotfiles ~/dotfiles
cd ~/dotfiles

# sync configuration for nvim
./sync.sh nvim

# sync configuration for multiple software
./sync.sh nvim tmux

# sync all
./sync.sh all
```

Check usage

```bash
./sync.sh --help
```


## Notes

The sync script does not back up existing configurations. It removes the target before creating a symbolic link to this repository:

- `zsh`, `tmux`, and `codex` remove the corresponding configuration file or symbolic link.
- `nvim` recursively removes the entire `~/.config/nvim` directory, file, or symbolic link.
- `codex/config.toml` contains codex configurations.

Back up your existing configurations before the first sync, for example:

```bash
mv ~/.zshrc ~/.zshrc.backup
mv ~/.tmux.conf ~/.tmux.conf.backup
mv ~/.codex/config.toml ~/.codex/config.toml.backup
mv ~/.config/nvim ~/.config/nvim.backup
```

After syncing, verify the links with:

```bash
ls -l ~/.zshrc ~/.tmux.conf ~/.codex/config.toml ~/.config/nvim
```

## TODO
- [x] nvim spell check configuration
- [x] ghostty
- [x] fzf
- [x] karabiner
- [ ] raycast
- [x] [OSC 52 copy](https://share.google/aimode/i5J8ULSlGPhGieeQR)
- [x] opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus" -- Sync with system clipboard
- [ ] 再想想codex的配置怎么搞
- [x] [notification over ssh](https://share.google/aimode/zXvzIcr0MRA5TCHDS)
- [ ] nvim dashboard (bochi the rock, eva, Lycoris, minato aqua, miku), try this [dot-art-generator](https://emojicombos.com/dot-art-generator)
