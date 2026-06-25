#!/usr/bin/env bash

if [[ "$1" != "ours" && "$1" != "theirs" ]]; then
    echo "❌ Erro: Use 'ours' ou 'theirs' como argumento." >&2
    exit 1
fi

STRATEGY=$1

# --- Verifica se há rebase ativo antes de tudo ---
if [ ! -d ".git/rebase-merge" ] && [ ! -d ".git/rebase-apply" ]; then
    echo "❌ Erro: Nenhum rebase ativo detectado neste repositório!" >&2
    exit 1
fi

# ---  Alerta e Confirmação do Usuário ---
echo "⚠️  AVISO DE SEGURANÇA ⚠️"
echo "1. Não use este script se o projeto contiver Git Submodules."
echo "2. Certifique-se de NÃO ter código não commitado (unstaged/staged) que você queira salvar."
echo "   O comando 'git checkout' irá sobrescrever arquivos modificados localmente de forma irreversível."
echo ""
read -p "Tem certeza que deseja prosseguir com '--$STRATEGY'? (s/N): " CONFIRMATION

if [[ ! "$CONFIRMATION" =~ ^[sS](im)?$ ]]; then
    echo "❌ Operação cancelada pelo usuário."
    exit 0
fi

echo "Iniando rebase CEGO..."
while [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]; do

    if ! git checkout --"$STRATEGY" .; then
        echo "❌ Erro: 'git checkout' falhou. Abortando script para evitar loop." >&2
        exit 1
    fi

    git add .
    OUTPUT=$(GIT_EDITOR=true git rebase --continue 2>&1)
    STATUS=$?

    if [ $STATUS -ne 0 ]; then
        if echo "$OUTPUT" | grep -qE "(No changes|did you forget to use 'git add')"; then
            echo "ℹ️  Commit vazio detectado. Pulando com 'git rebase --skip'..."
            git rebase --skip
        else

            echo "❌ Erro ao continuar o rebase. Mensagem do Git:" >&2
            echo "$OUTPUT" >&2
            exit 1
        fi
    fi

done

echo "🎉 Rebase finalizado com sucesso usando a estratégia: --$STRATEGY!"

