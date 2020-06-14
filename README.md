# Zettelkasten ZSH plugin

## Dependencies

```bash
brew install bat fzf the_silver_searcher
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
