# Zettelkasten ZSH plugin

## Pre-requisites

- Ruby with `activesupport` gem installed


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
export ZK_HOME="${HOME}/Documents/Notes"
```
