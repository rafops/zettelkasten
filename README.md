# Zettelkasten ZSH plugin

## Pre-requisites

```bash
brew install fzf the_silver_searcher
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

Set `$ZK_HOME` directory in `~/.zshrc`:

```bash
export ZK_HOME="${HOME}/Documents"
```

## Usage

To create a new document:

```
zk A new document
```

To find and edit existing documents:

```
zkf A document
```
