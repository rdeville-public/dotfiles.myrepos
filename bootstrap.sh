#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

NODES=(
  ".mrconfig"
)

source "${SCRIPTPATH}/lib/_mr_log.sh"

for i_node in "${NODES[@]}"
do
  src="${SCRIPTPATH}/${i_node}"
  dest="${HOME}/${i_node}"
  if [[ -e "${dest}" ]] && ! [[ -L "${HOME}/.mrconfig" ]]
  then
    mr_log "INFO" "Bootstrap: Backup **${dest}**."
    mv -v "${dest}" "${dest}.bak"
    mr_log "INFO" "Bootstrap: Create symlinks to **${dest}**."
    ln -s "${src}" "${dest}"
  elif ! [[ -L "${HOME}/.mrconfig" ]]
  then
    mr_log "INFO" "Bootstrap: Create symlink to **${dest}**."
    ln -s "${src}" "${dest}"
  else
    mr_log "INFO" "Bootstrap: Symlink to **${dest}** already exists."
  fi
done
