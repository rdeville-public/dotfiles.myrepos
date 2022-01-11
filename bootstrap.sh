#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

declare -A NODES

NODES["${SCRIPTPATH}/.mrconfig"]="${HOME}/.mrconfig"
NODES["${HOME}/.local/share/mr/repos"]="repos"
NODES["${HOME}/.local/share/mr/hosts"]="hosts"

source "${SCRIPTPATH}/lib/_mr_log.sh"

for i_node in "${!NODES[@]}"
do
  src="${i_node}"
  dest="${NODES[${i_node}]}"

  if ! [[ -d "$(dirname "${dest}")" ]]
  then
    mkdir -p "$(dirname "${dest}")"
  fi

  if ! [[ -e "${src}" ]]
  then
    mr_log "WARNING" "Bootstrap: Symlink source **${src}** does not exists."
    mr_log "WARNING" "Bootstrap: Will create symlink anyway as you may setup source later."
  fi

  if ! [[ -L "${dest}" ]]
  then
    mr_log "INFO" "Bootstrap: Create symlink to **${dest}**."
    ln -s "${src}" "${dest}"
  else
    mr_log "INFO" "Bootstrap: Symlink to **${dest}** already exists."
  fi
done
