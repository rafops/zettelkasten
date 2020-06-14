# Zettelkasten ZSH plugin

## Dependencies

- zsh, oh-my-zsh
- vim, git, bat, fzf, ag (silver searcher)
- Docker

```bash
brew install zsh vim git bat fzf the_silver_searcher
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
brew cask install docker
```

## Installation

Clone plugin to custom plugins:

```bash
cd ${HOME}/.oh-my-zsh/custom/plugins && git clone https://github.com/rafops/zettelkasten.git
```

Add plugin to your load list in `~/.zshrc`:

```
plugins=(zettelkasten)
```

Set `$ZK_HOME` directory in `~/.zshrc` (default is ~/Documents):

```bash
export ZK_HOME="${HOME}/Documents"
```

## Usage

```
zk -h
```

## Zettlr

This tool works better when paired with [Zettlr](https://www.zettlr.com)
