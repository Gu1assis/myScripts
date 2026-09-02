#! /usr/bin/env bash
# Essa funçao permite pesquisar seus projetos nas pastas fornecidas em dir
# para abrir o neovim dentro do tmux nesse projeto.
# Para mais comodidade, usei fzf para pesquisa.
# Crie um link simbolico para poder chamar esse script como comando tp:
# sudo ln -s <caminho-para-este-script> /usr/local/bin/tp

dir=$(
find ~/developer ~/.config/ \
  -mindepth 1 -maxdepth 1 -type d \
  | fzf
)

[ -z "$dir" ] && return

project=$(basename "$dir")

if tmux has-session -t "$project" 2>/dev/null; then
  tmux attach -t "$project"
else 
  tmux new-session -s "$project" -c "$dir" "nvim ."
fi
