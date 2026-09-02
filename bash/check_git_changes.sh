check_git_upstream() {
    # Verifica se estamos em um repositório git
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        # Busca atualizações em segundo plano sem travar o terminal
        git fetch &>/dev/null &
        
        # Compara a branch local com a remota
        LOCAL=$(git rev-parse @ 2>/dev/null)
        REMOTE=$(git rev-parse @{u} 2>/dev/null)
        BASE=$(git merge-base @ @{u} 2>/dev/null)

        if [ "$LOCAL" = "$BASE" ] && [ "$LOCAL" != "$REMOTE" ]; then
            echo -e "\n\033[1;33m⚠️  Atenção: Este repositório possui mudanças pendentes! Use 'git pull'.\033[0m\n"
        fi
    fi
}

# Coloque isso no seu zhsrc/bashrc
#cd() {
#    builtin cd "$@" && check_git_upstream
#}

