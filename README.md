# homebrew-kindling

Homebrew tap for [Kindling](https://github.com/samuelbanapour/kindling), a zsh framework.

```sh
brew tap samuelbanapour/kindling
brew install kindling
```

Then add to `~/.zshrc`:

```zsh
export KINDLING="$(brew --prefix)/opt/kindling/share/kindling"
kindling_plugins=(git jump zline extract)
KINDLING_THEME=spark
[ -r "$KINDLING/kindling.zsh" ] && source "$KINDLING/kindling.zsh"
```

`kindling off` stops it loading and restores whatever your shell did before;
`kindling on` brings it back.
