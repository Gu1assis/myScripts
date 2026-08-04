#! /usr/bin/env bash

set -euo pipefail

CUR_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

get_metadata(){
  local path=$1
  local tag=$2
  sed -n "1,20s/^# *@${tag}: *//p" "$path" | xargs
}

notify_missing_deps(){
  local deps=$1
  local script=$2
  beautiful_deps=$(echo "$deps" | awk '{
    resultado = $1
    for (i = 2; i < NF; i++) {
        resultado = resultado ", " $i
    }
    if (NF >= 2) {
        resultado = resultado " e " $NF
    }
    print resultado
  }')
  echo "O script $script depende de $beautiful_deps"
  hint_package_manager
}

hint_package_manager(){
  echo ""
  echo "Use o seu gerenciador de pacotes para instalar as dependencias"
  echo "Exemplo:"
  if command -v brew >/dev/null 2>&1 || [ "$(uname -s)" = "Darwin" ]; then
        echo "brew install"
    elif [ -f /etc/debian_version ]; then
        echo "sudo apt install"
    elif [ -f /etc/arch-release ]; then
        echo "sudo pacman -S"
    elif [ -f /etc/fedora-release ]; then
        echo "sudo dnf install"
    else
        echo "<seu-gerenciador-de-pacotes> install"
    fi
}

select_rc(){
  local -n all_alias_ref=$1
  echo ""
  echo "[INFO] Verficação concluída!"
  echo "Iniciando definição de alias..."
  echo "Você prefere que os alias seja salvos no .zhrc ou .bashrc?"
  echo ""
  local target_files=()
  options=(".bashrc" ".zshrc" "Ambos" "Cancelar")

  select opt in "${options[@]}"; do
    case $opt in
      ".bashrc")  target_files=("$HOME/.bashrc"); break ;;
      ".zshrc")   target_files=("$HOME/.zshrc"); break ;;
      "Ambos")    target_files=("$HOME/.bashrc" "$HOME/.zshrc"); break ;;
      "Cancelar") exit 0 ;;
      *) echo "Opção inválida, tente novamente." ;;
    esac
  done 

  for rc_file in "${target_files[@]}"; do
    touch "$rc_file"
    has_block=$(grep -q "# --- BEGIN SCRIPTS GU1ASSIS ---" "$rc_file" && echo 1 || echo 0)
    if [[ "$has_block" == 1 ]]; then
      echo "Arquivo $rc_file já possui alias registrados. Ignorando..."
      continue
    fi

    echo "# --- BEGIN SCRIPTS GU1ASSIS ---" # >> "$rc_file"
    for script in "${!all_alias_ref[@]}"; do
      echo "alias ${all_alias_ref[$script]}=$CUR_DIR/$script"
    done # >> "$rc_file"
    echo "# --- END SCRIPTS GU1ASSIS ---" #>> "$rc_file"
  done
}

declare -A deps_missing
deps_check=0
declare -A all_alias

for script in ./bash/*.sh; do
  [ -f "$script" ] || continue

  alias_name=$(get_metadata "$script" "alias")
  dependencies=$(get_metadata "$script" "dependencies")
 
  if [ -z "$alias_name" ]; then
    echo "AVISO: Script $script sem alias definido"
    continue
  fi
  
  # DEBUG
  echo "Script: $script"
  echo "  -> Alias: $alias_name"
  echo "  -> Dependencies:  $dependencies"
  echo "---"

  clean_deps=$(echo "$dependencies" | tr ',' ' ')
  script_has_all_deps=0
  for dep in $clean_deps; do
    if command -v  "$dep" >/dev/null 2>&1; then
      echo "[OK] Dependencia $dep encontrada!"
    else 
      echo "[ERRO] Dependencia $dep ausente! "
      deps_missing["$script"]+=" $dep"
      script_has_all_deps=1
      deps_check=1
    fi
  done

  if [[ "$script_has_all_deps" == 0 ]]; then
    all_alias["$script"]="$alias_name"
  fi
done

if [[ "$deps_check" == 1 ]]; then
  echo ""
  echo "[ATENÇÃO!] Dependencias não instaladas foram encotradas!"
  for script in "${!deps_missing[@]}"; do
    notify_missing_deps "${deps_missing[$script]}" "$script"
    exit 1
  done
fi

echo "${all_alias[@]}"
select_rc all_alias


# TODO
# Colocar alias de help dando echo dos alias e descriçoes,fazer script proprio
